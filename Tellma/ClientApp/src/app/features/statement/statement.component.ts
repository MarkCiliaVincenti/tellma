// tslint:disable:member-ordering
// tslint:disable:max-line-length
import { Component, OnInit, Input, OnDestroy, ViewChild, TemplateRef, OnChanges, SimpleChanges } from '@angular/core';
import { ActivatedRoute, Router, ParamMap, Params } from '@angular/router';
import { Subscription, Subject, Observable, of } from 'rxjs';
import { TranslateService } from '@ngx-translate/core';
import { WorkspaceService, ReportStore, ReportStatus } from '~/app/data/workspace.service';
import { tap, catchError, switchMap } from 'rxjs/operators';
import { Resource, metadata_Resource } from '~/app/data/entities/resource';
import { Account } from '~/app/data/entities/account';
import { metadata_Contract } from '~/app/data/entities/contract';
import { AccountType } from '~/app/data/entities/account-type';
import { CustomUserSettingsService } from '~/app/data/custom-user-settings.service';
import { Entity } from '~/app/data/entities/base/entity';
import { DetailsEntry } from '~/app/data/entities/details-entry';
import { formatDate, formatNumber } from '@angular/common';
import { LineForQuery } from '~/app/data/entities/line';
import { Document, metadata_Document } from '~/app/data/entities/document';
import { SerialPropDescriptor } from '~/app/data/entities/base/metadata';
import { ApiService } from '~/app/data/api.service';
import { FriendlyError, mergeEntitiesInWorkspace, isSpecified, formatAccounting, csvPackage, downloadBlob } from '~/app/data/util';
import { StatementArguments } from '~/app/data/dto/statement-arguments';
import { Currency } from '~/app/data/entities/currency';
import { StatementResponse } from '~/app/data/dto/statement-response';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { SettingsForClient } from '~/app/data/dto/settings-for-client';

@Component({
  selector: 't-statement',
  templateUrl: './statement.component.html',
  styles: []
})
export class StatementComponent implements OnInit, OnChanges, OnDestroy {

  private _subscriptions: Subscription;
  private notifyFetch$ = new Subject<void>();
  private notifyDestruct$ = new Subject<void>();
  private api = this.apiService.detailsEntriesApi(this.notifyDestruct$); // Only for intellisense

  private numericKeys = ['account_id', 'segment_id', 'contract_id', 'resource_id', 'entry_type_id', 'center_id'];
  private stringKeys = ['from_date', 'to_date', 'currency_id'];
  private booleanKeys = ['include_completed'];

  public actionErrorMessage: string;

  @Input()
  type: 'account' | 'contract';

  @ViewChild('errorModal', { static: true })
  public errorModal: TemplateRef<any>;

  constructor(
    private route: ActivatedRoute, private router: Router, private customUserSettings: CustomUserSettingsService,
    private translate: TranslateService, private workspace: WorkspaceService, private apiService: ApiService,
    private modalService: NgbModal) { }

  ngOnInit(): void {

    // Initialize the api service
    this.api = this.apiService.detailsEntriesApi(this.notifyDestruct$);

    // Set up all the subscriptions
    this._subscriptions = new Subscription();

    // Subscribe to fetch requests
    this._subscriptions.add(this.notifyFetch$.pipe(
      switchMap(() => this.doFetch())
    ).subscribe());

    // Subscribe to changing URL param
    this._subscriptions.add(this.route.paramMap.subscribe((params: ParamMap) => {

      // Copy all report arguments from URL

      let fetchIsNeeded = false;
      const s = this.state;
      const args = s.arguments;

      if (this.isAccount) {
        for (const key of this.stringKeys) {
          const paramValue = params.get(key) || undefined;
          if (args[key] !== paramValue) {
            args[key] = paramValue;
            fetchIsNeeded = true;
          }
        }

        for (const key of this.numericKeys) {
          const paramValue = (+params.get(key)) || undefined;
          if (args[key] !== paramValue) {
            args[key] = paramValue;
            fetchIsNeeded = true;
          }
        }

        for (const key of this.booleanKeys) {
          const paramValue: boolean = (params.get(key) || false).toString() === 'true';
          if (args[key] !== paramValue) {
            args[key] = paramValue;
            fetchIsNeeded = true;
          }
        }
      }

      if (this.isContract) {
        // TODO
      }

      // Other screen parameters
      // Skip
      const skipParam = +params.get('skip') || 0;
      if (s.skip !== skipParam) {
        s.skip = skipParam;
        fetchIsNeeded = true;
      }

      // Collapse Parameters
      const collapseParamsValue = (params.get('collapse_params') || false).toString() === 'true';
      if (this._collapseParameters !== collapseParamsValue) {
        this._collapseParameters = collapseParamsValue;
      }

      if (fetchIsNeeded) {
        this.fetch();
      }
    }));
  }

  ngOnDestroy(): void {
    this.notifyDestruct$.next();
    this._subscriptions.unsubscribe();
  }

  ngOnChanges(changes: SimpleChanges) {
    // Using our famous pattern
    const screenDefProperties = [changes.type];
    const screenDefChanges = screenDefProperties.some(prop => !!prop && !prop.isFirstChange());
    if (screenDefChanges) {
      this.ngOnDestroy();
      this.ngOnInit();
    }
  }

  private urlStateChanged(): void {
    // We wish to store part of the page state in the URL
    // This method is called whenever that part of the state has changed
    // Below we capture the new URL state, and then navigate to the new URL

    const s = this.state;
    const args = s.arguments;
    const params: Params = {};

    // Add the arguments
    for (const key of this.stringKeys.concat(this.numericKeys).concat(this.booleanKeys)) {
      const value = args[key] || undefined;
      if (!!value) {
        params[key] = value;
      }
    }

    // Add skip
    if (!!s.skip) {
      params.skip = s.skip;
    }

    if (!!this._collapseParameters) {
      params.collapse_params = true;
    }

    // navigate to the new url
    this.router.navigate(['.', params], { relativeTo: this.route, replaceUrl: true });
  }

  private parametersChanged(): void {

    // Update the URL
    this.urlStateChanged();

    // Force refresh the columns
    this._columnsParametersHaveChanged = true;

    // Save the arguments in user settings
    const argsString = JSON.stringify(this.state.arguments);
    this.customUserSettings.save('account-statement/arguments', argsString);

    // Refresh the results
    this.fetch();
  }

  public get ws() {
    return this.workspace.currentTenant;
  }

  private get isAccount() {
    return this.type === 'account';
  }

  private get isContract() {
    return this.type === 'contract';
  }

  public fetch() {
    this.notifyFetch$.next();
  }

  /**
   * Computes select from all columns, without repetition of select atoms
   */
  private computeSelect(): string {
    const resultHash: { [key: string]: true } = {};
    const resultArray: string[] = [];
    for (const column of this.columns) {
      for (const atom of column.select) {
        if (!resultHash[atom]) {
          resultHash[atom] = true;
          resultArray.push(atom);
        }
      }
    }

    return resultArray.join(',');
  }

  private computeStatementArguments(s?: ReportStore): StatementArguments {
    s = s || this.state;
    const select = this.computeSelect();
    const top = this.DEFAULT_PAGE_SIZE;
    const skip = s.skip;

    // Prepare the query filter
    const args: StatementArguments = {
      select, top, skip,
      fromDate: formatDate(this.fromDate, 'yyyy-MM-dd', 'en-GB'),
      toDate: formatDate(this.toDate, 'yyyy-MM-dd', 'en-GB'),
      accountId: this.accountId
    };

    if (!!this.segmentId && this.showSegmentParameter) {
      args.segmentId = this.segmentId;
    }

    if (!!this.contractId && this.showContractParameter) {
      args.contractId = this.contractId;
    }

    if (!!this.resourceId && this.showResourceParameter) {
      args.resourceId = this.resourceId;
    }

    if (!!this.entryTypeId && this.showEntryTypeParameter) {
      args.entryTypeId = this.entryTypeId;
    }

    if (!!this.centerId && this.showCenterParameter) {
      args.centerId = this.centerId;
    }

    if (!!this.currencyId && this.showCurrencyParameter) {
      args.currencyId = this.currencyId;
    }

    if (!!this.includeCompleted) {
      args.includeCompleted = true;
    }

    return args;
  }

  private doFetch(): Observable<void> {
    const s = this.state;

    if (this.missingRequiredParameters) {
      s.reportStatus = ReportStatus.information;
      s.information = () => this.translate.instant('FillRequiredFields');
      return of();
    } else if (this.loadingRequiredParameters) {
      // Wait until required parameters have loaded
      // They will call fetch again once they load
      s.reportStatus = ReportStatus.loading;
      s.result = [];
      return of();
    } else {
      // For robustness grab a reference to the state object, in case it changes later
      s.reportStatus = ReportStatus.loading;
      s.result = [];

      // Prepare the query params
      const args = this.computeStatementArguments();
      return this.api.statement(args).pipe(
        tap(response => {
          // Result is loaded
          s.reportStatus = ReportStatus.loaded;

          // Add the result to the state
          s.result = response.Result;
          s.top = response.Top;
          s.skip = response.Skip;
          s.total = response.TotalCount;
          s.extras = {
            opening: response.Opening,
            openingQuantity: response.OpeningQuantity,
            openingMonetaryValue: response.OpeningMonetaryValue,
            closing: response.Closing,
            closingQuantity: response.ClosingQuantity,
            closingMonetaryValue: response.ClosingMonetaryValue
          };

          // Merge the related entities and Notify everyone
          mergeEntitiesInWorkspace(response.RelatedEntities, this.workspace);
          this.workspace.notifyStateChanged();
        }),
        catchError((friendlyError: FriendlyError) => {
          s.reportStatus = ReportStatus.error;
          s.errorMessage = friendlyError.error;
          return of(null);
        })
      );
    }
  }

  private get missingRequiredParameters(): boolean {
    const args = this.state.arguments;
    if (this.isAccount) {
      return !args.from_date || !args.to_date || !args.account_id || (this.showSegmentParameter && !args.segment_id);
    }

    if (this.isContract) {
      // TODO
    }
  }

  private get loadingRequiredParameters(): boolean {
    // Some times the account Id or resource Id from the Url refer to entities that are not loaded
    // Given that computing the statement query requires knowledge of these entities (not just their Ids)
    // We have to wait until the details pickers have loaded the entities for us, until then this
    // property returns true, and the statement query is not executed
    if (!!this.accountId && !this.account()) {
      return true;
    }

    if (this.showResourceParameter && !this.readonlyResource_Manual && !!this.resourceId && !this.ws.get('Resource', this.resourceId)) {
      return true;
    }

    return false;
  }

  public onParameterLoaded(): void {
    if (this.state.reportStatus === ReportStatus.loading) {
      this._columnsParametersHaveChanged = true;
      this.fetch(); // ???
    }
  }

  // UI Bindings

  public get title() {
    if (this.isAccount) {
      return this.translate.instant('AccountStatement');
    } else if (this.isContract) {
      // TODO
    } else {
      return '???';
    }
  }

  public get actionsDropdownPlacement() {
    return this.workspace.ws.isRtl ? 'bottom-right' : 'bottom-left';
  }

  public get flip() {
    // this is to flip the UI icons in RTL
    return this.workspace.ws.isRtl ? 'horizontal' : null;
  }

  public showExportSpinner = false;

  private normalize(arr: string[], length: number): string[] {
    while (arr.length < length) {
      arr.push('');
    }

    return arr;
  }

  private displayErrorModal(error: string) {
    this.actionErrorMessage = error;
    this.modalService.open(this.errorModal);
  }

  public onExport(): void {

    const columns = this.columns;
    const args = this.computeStatementArguments();
    delete args.top; // we export everything

    this.showExportSpinner = true;

    this.api.statement(args).pipe(
      tap((response: StatementResponse) => {
        this.showExportSpinner = false;

        if (response.Result.length !== response.TotalCount) {
          this.displayErrorModal('Too many rows');
          return;
        }

        // Merge the related entities and Notify everyone
        mergeEntitiesInWorkspace(response.RelatedEntities, this.workspace);
        this.workspace.notifyStateChanged();

        const data: string[][] = [];

        // (1) Add the parameters
        data.push(this.normalize([this.translate.instant('FromDate'), formatDate(args.fromDate, 'yyyy-MM-dd', 'en-GB')], columns.length));
        data.push(this.normalize([this.translate.instant('ToDate'), formatDate(args.toDate, 'yyyy-MM-dd', 'en-GB')], columns.length));
        if (!!args.segmentId) {
          data.push(this.normalize([this.translate.instant('Document_Segment'), this.ws.getMultilingualValue('Center', args.segmentId, 'Name')], columns.length));
        }
        data.push(this.normalize([this.translate.instant('Entry_Account'), this.ws.getMultilingualValue('Account', args.accountId, 'Name')], columns.length));
        if (!!args.currencyId) {
          data.push(this.normalize([this.translate.instant('Entry_Currency'), this.ws.getMultilingualValue('Currency', args.currencyId, 'Name')], columns.length));
        }
        if (!!args.contractId) {
          data.push(this.normalize([this.labelContract_Manual, this.ws.getMultilingualValue('Contract', args.contractId, 'Name')], columns.length));
        }
        if (!!args.resourceId) {
          data.push(this.normalize([this.labelResource_Manual, this.ws.getMultilingualValue('Resource', args.resourceId, 'Name')], columns.length));
        }
        if (!!args.entryTypeId) {
          data.push(this.normalize([this.translate.instant('Entry_EntryType'), this.ws.getMultilingualValue('EntryType', args.entryTypeId, 'Name')], columns.length));
        }
        if (!!args.centerId) {
          data.push(this.normalize([this.translate.instant('Entry_Center'), this.ws.getMultilingualValue('Center', args.centerId, 'Name')], columns.length));
        }
        if (!!args.includeCompleted) {
          data.push(this.normalize([this.translate.instant('IncludeCompleted'), this.translate.instant('Yes')], columns.length));
        }

        // Gap between parameters and grid
        data.push(this.normalize([], columns.length));

        // (2) Add column headers
        const headersRow: string[] = [];
        for (const col of columns) {
          headersRow.push(col.label());
        }
        data.push(headersRow);

        // (3) Add the opening row and prepare the closing row
        const openingRow: string[] = [];
        const closingRow: string[] = [];
        for (const col of columns) {
          switch (col.id) {
            case 'PostingDate':
              openingRow.push(formatDate(args.fromDate, 'yyyy-MM-dd', 'en-GB'));
              closingRow.push(formatDate(args.toDate, 'yyyy-MM-dd', 'en-GB'));
              break;
            case 'SerialNumber':
              openingRow.push(this.translate.instant('OpeningBalance'));
              closingRow.push(this.translate.instant('ClosingBalance'));
              break;
            case 'QuantityAccumulation':
              openingRow.push(this.openingQuantityDisplay);
              closingRow.push(this.closingQuantityDisplay);
              break;
            case 'MonetaryValueAccumulation':
              openingRow.push(this.openingMonetaryValueDisplay);
              closingRow.push(this.closingMonetaryValueDisplay);
              break;
            case 'Accumulation':
              openingRow.push(this.openingDisplay);
              closingRow.push(this.closingDisplay);
              break;
            default:
              openingRow.push('');
              closingRow.push('');
          }
        }
        data.push(openingRow);

        // (4) Add the movements
        for (const entry of response.Result) {
          const dataRow: string[] = [];
          for (const col of columns) {
            dataRow.push(col.display(entry));
          }
          data.push(dataRow);
        }

        // (5) Add the closing row
        data.push(closingRow);

        // Prepare a friendly file name
        const reportName = this.translate.instant('AccountStatement');
        // const fromDate = formatDate(args.fromDate, 'yyyy-MM-dd', 'en-GB');
        // const toDate = formatDate(args.toDate, 'yyyy-MM-dd', 'en-GB');
        const fileName = `${reportName}.csv`;

        // Download the blob
        const blob = csvPackage(data);
        downloadBlob(blob, fileName);
      }),
      catchError((friendlyError: FriendlyError) => {
        this.showExportSpinner = false;
        this.displayErrorModal(friendlyError.error || friendlyError);
        return of();
      })
    ).subscribe();
  }

  public get canExport(): boolean {
    return this.isLoaded;
  }

  public onRefresh(): void {
    // The if statement to deal with incessant button clickers (Users who hit refresh repeatedly)
    if (this.state.reportStatus !== ReportStatus.loading) {
      this.fetch();
    }
  }

  DEFAULT_PAGE_SIZE = 60;

  public get stateKey(): string {
    if (this.isAccount) {
      return 'account-statement';
    } else {
      // TODO
    }
  }

  public get state(): ReportStore {

    if (!this.workspace.currentTenant.reportState[this.stateKey]) {
      this.workspace.currentTenant.reportState[this.stateKey] = new ReportStore();
    }

    return this.workspace.currentTenant.reportState[this.stateKey];
  }

  get from(): number {
    return Math.min(this.state.skip + 1, this.total);
  }

  get to(): number {
    const s = this.state;
    return Math.min(s.skip + this.DEFAULT_PAGE_SIZE, s.total);
  }

  get total(): number {
    return this.state.total;
  }

  onPreviousPage() {
    const s = this.state;
    s.skip = Math.max(s.skip - this.DEFAULT_PAGE_SIZE, 0);

    this.urlStateChanged(); // to update the URL state
    this.fetch();
  }

  get canPreviousPage(): boolean {
    return this.state.skip > 0;
  }

  onNextPage() {
    const s = this.state;
    s.skip = s.skip + this.DEFAULT_PAGE_SIZE;

    this.urlStateChanged(); // to update the URL state
    this.fetch();
  }

  get canNextPage(): boolean {
    return this.to < this.total;
  }

  public link(finalSegment: string): string {
    if (this.isAccount) {
      return `../${finalSegment}`;
    }

    if (this.isContract) {
      return `../../${finalSegment}`;
    }
  }

  // Include Completed
  public get includeCompleted(): boolean {
    return this.state.arguments.include_completed;
  }

  public set includeCompleted(v: boolean) {
    const args = this.state.arguments;
    if (args.include_completed !== v) {
      args.include_completed = v;
      this.parametersChanged();
    }
  }

  // From Date
  public get fromDate(): string {
    return this.state.arguments.from_date;
  }

  public set fromDate(v: string) {
    const args = this.state.arguments;
    if (args.from_date !== v) {
      args.from_date = v;
      this.parametersChanged();
    }
  }

  // To Date
  public get toDate(): string {
    return this.state.arguments.to_date;
  }

  public set toDate(v: string) {
    const args = this.state.arguments;
    if (args.to_date !== v) {
      args.to_date = v;
      this.parametersChanged();
    }
  }

  // Account
  public accountAdditionalSelect = '$DocumentDetails';

  public get accountId(): number {
    return this.state.arguments.account_id;
  }

  public set accountId(v: number) {
    const args = this.state.arguments;
    if (args.account_id !== v) {
      args.account_id = v;
      this.parametersChanged();
    }
  }

  private account(id?: number): Account {
    id = id || this.accountId;
    return this.ws.get('Account', id);
  }

  private accountType(): AccountType {
    const account = this.account();
    if (!!account && account.AccountTypeId) {
      return this.ws.get('AccountType', account.AccountTypeId) as AccountType;
    }

    return null;
  }

  // Segment
  public get segmentId(): number {
    return this.state.arguments.segment_id;
  }

  public set segmentId(v: number) {
    const args = this.state.arguments;
    if (args.segment_id !== v) {
      args.segment_id = v;
      this.parametersChanged();
    }
  }

  /**
   * Whether or not to show the segment parameter
   */
  public get showSegmentParameter(): boolean {
    return this.ws.settings.IsMultiSegment;
  }

  // Currency
  public currencyAdditionalSelect = 'E';

  public get currencyId(): string {
    return this.state.arguments.currency_id;
  }

  public set currencyId(v: string) {
    const args = this.state.arguments;
    if (args.currency_id !== v) {
      args.currency_id = v;
      this.parametersChanged();
    }
  }

  /**
   * Returns the currency Id from the selected account or from the selected resource if any
   */
  private getAccountResourceCurrencyId(): string {
    const account = this.account();
    const resource = this.ws.get('Resource', this.resourceId) as Resource;

    const accountCurrencyId = !!account ? account.CurrencyId : null;
    const resourceCurrencyId = !!resource ? resource.CurrencyId : null;

    return accountCurrencyId || resourceCurrencyId;
  }

  /**
   * Whether or not to show the currency parameter
   */
  public get showCurrencyParameter(): boolean {
    // Show the editable currency parameter
    const account = this.account();
    return !!account && !this.getAccountResourceCurrencyId();
  }

  /**
   * Returns the Id of the currency to show as a postfix to the monetary value column header
   */
  public get readonlyValueCurrencyId(): string {
    const accountResourceCurrencyId = this.getAccountResourceCurrencyId();
    return accountResourceCurrencyId || this.currencyId;
  }

  /**
   * Syntactic sugar to get the functional currency Id
   */
  public get functionalId(): string {
    return this.ws.settings.FunctionalCurrencyId;
  }

  // Contract
  public get contractId(): number {
    return this.state.arguments.contract_id;
  }

  public set contractId(v: number) {
    const args = this.state.arguments;
    if (args.contract_id !== v) {
      args.contract_id = v;
      this.parametersChanged();
    }
  }

  public get showContractParameter(): boolean {
    const account = this.account();
    return !!account && !!account.ContractDefinitionId;
  }

  public get readonlyContract_Manual(): boolean {
    const account = this.account();
    return !!account && !!account.ContractId;
  }

  public get readonlyValueContractId_Manual(): number {
    const account = this.account();
    return !!account ? account.ContractId : null;
  }

  public get labelContract_Manual(): string {
    const account = this.account();
    const defId = !!account ? account.ContractDefinitionId : null;

    return metadata_Contract(this.workspace, this.translate, defId).titleSingular();
  }

  public get definitionIdsContract_Manual(): number[] {
    const account = this.account();
    return [account.ContractDefinitionId];
    // return !!account && !!account.ContractDefinitions ? account.ContractDefinitions.map(e => e.ContractDefinitionId) : [];
  }

  // Noted Contract

  public get showNotedContract_Manual(): boolean {
    const account = this.account();
    return !!account && !!account.NotedContractDefinitionId;
  }

  public get labelNotedContract_Manual(): string {
    const account = this.account();
    const defId = !!account ? account.NotedContractDefinitionId : null;

    return metadata_Contract(this.workspace, this.translate, defId).titleSingular();
  }

  // Resource
  public resourceAdditionalSelect = '$DocumentDetails';

  public get resourceId(): number {
    return this.state.arguments.resource_id;
  }

  public set resourceId(v: number) {
    const args = this.state.arguments;
    if (args.resource_id !== v) {
      args.resource_id = v;
      this.parametersChanged();
    }
  }

  /**
   * Returns the resource specified in the parameter
   */
  private resource(): Resource {
    // id = id || this.resourceId;
    // return this.ws.get('Resource', id);

    const account = this.account();
    const accountResourceId = !!account ? account.ResourceId : null;
    const resourceId = accountResourceId || this.resourceId;
    return this.ws.get('Resource', resourceId) as Resource;
  }

  public get showResourceParameter(): boolean {
    const account = this.account();
    return !!account && !!account.ResourceDefinitionId;
  }

  public get readonlyResource_Manual(): boolean {
    const account = this.account();
    return !!account && !!account.ResourceId;
  }

  public get readonlyValueResourceId_Manual(): number {
    const account = this.account();
    return !!account ? account.ResourceId : null;
  }

  public get labelResource_Manual(): string {
    const account = this.account();
    const defId = !!account ? account.ResourceDefinitionId : null;

    return metadata_Resource(this.workspace, this.translate, defId).titleSingular();
  }

  public get definitionIdsResource_Manual(): number[] {
    const account = this.account();
    return [account.ResourceDefinitionId];
  }

  // Entry Type

  public get entryTypeId(): number {
    return this.state.arguments.entry_type_id;
  }

  public set entryTypeId(v: number) {
    const args = this.state.arguments;
    if (args.entry_type_id !== v) {
      args.entry_type_id = v;
      this.parametersChanged();
    }
  }

  public get showEntryTypeParameter(): boolean {
    // Show entry type when the account's type has an entry type parent Id
    const at = this.accountType();
    if (!!at) {
      const entryTypeParent = this.ws.get('EntryType', at.EntryTypeParentId);
      return !!entryTypeParent && entryTypeParent.IsActive;
    }

    return false;
  }

  public get readonlyEntryType_Manual(): boolean {
    const account = this.account();
    return !!account && !!account.EntryTypeId;
  }

  public get readonlyValueEntryTypeId_Manual(): number {
    const account = this.account();
    return !!account ? account.EntryTypeId : null;
  }

  public get filterEntryType_Manual(): string {
    const accountType = this.accountType();
    return `IsAssignable eq true and Node descof ${accountType.EntryTypeParentId}`;
  }

  // Center

  public get centerId(): number {
    return this.state.arguments.center_id;
  }

  public set centerId(v: number) {
    const args = this.state.arguments;
    if (args.center_id !== v) {
      args.center_id = v;
      this.parametersChanged();
    }
  }

  public get showCenterParameter(): boolean {
    const account = this.account();
    return !!account;
  }

  public get readonlyCenter_Manual(): boolean {
    const account = this.account();
    return !!account && !!account.CenterId;
  }

  public get readonlyValueCenterId_Manual(): number {
    const account = this.account();
    return !!account ? account.CenterId : null;
  }
  // Error Message
  public get showErrorMessage(): boolean {
    return this.state.reportStatus === ReportStatus.error;
  }

  public get errorMessage(): string {
    return this.state.errorMessage;
  }

  // Information
  public get showInformation(): boolean {
    return this.state.reportStatus === ReportStatus.information;
  }

  public information(): string {
    return this.state.information();
  }

  // Spinner
  public get showSpinner(): boolean {
    return this.state.reportStatus === ReportStatus.loading;
  }

  // Result
  public get showNoItemsFound(): boolean {
    const s = this.state;
    return s.reportStatus === ReportStatus.loaded && (!s.result || s.result.length === 0);
  }

  private get isLoaded(): boolean {
    return this.state.reportStatus === ReportStatus.loaded;
  }

  public get showOpeningBalance(): boolean {
    return this.isLoaded && !this.state.skip;
  }

  public get showClosingBalance(): boolean {
    return this.isLoaded && this.to === this.total;
  }

  public get openingDisplay(): string {
    const s = this.state;
    if (s.extras) {
      const opening = s.extras.opening || 0;
      return formatAccounting(opening, this.functionalDigitsInfo);
    }

    return '';
  }

  public get openingQuantityDisplay(): string {
    const s = this.state;
    if (s.extras) {
      const opening = s.extras.openingQuantity || 0;
      return formatAccounting(opening, '1.0-4');
    }

    return '';
  }

  public get openingMonetaryValueDisplay(): string {
    const s = this.state;
    if (s.extras) {
      const opening = s.extras.openingMonetaryValue || 0;
      const currencyId = this.getAccountResourceCurrencyId() || this.currencyId || this.functionalId;
      const digitsInfo = this.digitsInfo(currencyId);
      return formatAccounting(opening, digitsInfo);
    }

    return '';
  }

  public get closingDisplay(): string {
    const s = this.state;
    if (s.extras) {
      const closing = s.extras.closing || 0;
      return formatAccounting(closing, this.functionalDigitsInfo);
    }

    return '';
  }

  public get closingQuantityDisplay(): string {
    const s = this.state;
    if (s.extras) {
      const closing = s.extras.closingQuantity || 0;
      return formatAccounting(closing, '1.0-4');
    }

    return '';
  }

  public get closingMonetaryValueDisplay(): string {
    const s = this.state;
    if (s.extras) {
      const closing = s.extras.closingMonetaryValue || 0;
      const currencyId = this.getAccountResourceCurrencyId() || this.currencyId || this.functionalId;
      const digitsInfo = this.digitsInfo(currencyId);
      return formatAccounting(closing, digitsInfo);
    }

    return '';
  }

  public get entities(): Entity[] {
    return this.state.result;
  }

  private get functionalDigitsInfo(): string {
    const settings = this.ws.settings;
    const functionalDecimals = settings.FunctionalCurrencyDecimals;
    return `1.${functionalDecimals}-${functionalDecimals}`;
  }

  private digitsInfo(currencyId: string): string {
    const currency = this.ws.get('Currency', currencyId) as Currency;
    if (!currency) {
      return this.functionalDigitsInfo;
    } else {
      const e = currency.E || 0;
      return `1.${e}-${e}`;
    }
  }

  private _columnsAccount: Account;
  private _columnsAccountType: AccountType;
  private _columnsResource: Resource;
  private _columnsSettings: SettingsForClient;
  private _columnsParametersHaveChanged = false;
  private _columns: ColumnInfo[];
  public get columns(): ColumnInfo[] {
    const account = this.account();
    const accountType = this.accountType();
    const resource = this.resource();
    const settings = this.ws.settings;
    if (this._columnsAccount !== account ||
      this._columnsAccountType !== accountType ||
      this._columnsResource !== resource ||
      this._columnsSettings !== settings ||
      this._columnsParametersHaveChanged) {

      // console.log('------- Column Refresh -------');
      // if (this._columnsAccount !== account) {
      //   console.log('New Account!', account);
      // }
      // if (this._columnsAccountType !== accountType) {
      //   console.log('New Account Type!', accountType);
      // }
      // if (this._columnsResource !== resource) {
      //   console.log('New Resource!', resource);
      // }
      // if (this._columnsSettings !== settings) {
      //   console.log('New Settings!', settings);
      // }
      // if (this._columnsParametersHaveChanged) {
      //   console.log('Params Have Changed!');
      // }

      this._columnsAccount = account;
      this._columnsAccountType = accountType;
      this._columnsResource = resource;
      this._columnsSettings = settings;
      this._columnsParametersHaveChanged = false;


      const locale = 'en-GB';

      this._columns = [
        // PostingDate
        {
          id: 'PostingDate',
          select: ['Line/PostingDate'],
          label: () => this.translate.instant('Line_PostingDate'),
          display: (entry: DetailsEntry) => {
            const line = this.ws.get('LineForQuery', entry.LineId) as LineForQuery;
            return formatDate(line.PostingDate, 'yyyy-MM-dd', locale);
          },
          weight: 1
        },

        // SerialNumber
        {
          id: 'SerialNumber',
          select: ['Line/Document/SerialNumber', 'Line/Document/DefinitionId'],
          label: () => this.translate.instant('Document_SerialNumber'),
          display: (entry: DetailsEntry) => {
            const line = this.ws.get('LineForQuery', entry.LineId) as LineForQuery;
            const doc = this.ws.get('Document', line.DocumentId) as Document;
            const desc = metadata_Document(this.workspace, this.translate, doc.DefinitionId);
            const prop = desc.properties.SerialNumber as SerialPropDescriptor;
            return prop.format(doc.SerialNumber);
          },
          weight: 1
        }];

      // Memo
      this._columns.push({
        id: 'Memo',
        select: ['Line/Memo'],
        label: () => this.translate.instant('Memo'),
        display: (entry: DetailsEntry) => {
          const line = this.ws.get('LineForQuery', entry.LineId) as LineForQuery;
          return line.Memo;
        },
        weight: 1
      });

      // Contract
      if (this.showContractParameter && !this.readonlyContract_Manual && !this.contractId) {
        // If a parameter is visible, editable and not selected yet, show it as a column below
        this._columns.push({
          select: ['Contract/Name,Contract/Name2,Contract/Name3'],
          label: () => this.labelContract_Manual,
          display: (entry: DetailsEntry) => {
            return this.ws.getMultilingualValue('Contract', entry.ContractId, 'Name');
          },
          weight: 1
        });
      }

      // NotedContract
      if (this.showNotedContract_Manual) {
        this._columns.push({
          select: ['NotedContract/Name,NotedContract/Name2,NotedContract/Name3'],
          label: () => this.labelNotedContract_Manual,
          display: (entry: DetailsEntry) => {
            return this.ws.getMultilingualValue('Contract', entry.NotedContractId, 'Name');
          },
          weight: 1
        });
      }

      // EntryType
      if (this.showEntryTypeParameter && !this.readonlyEntryType_Manual && !this.entryTypeId) {
        // If a parameter is visible, editable and not selected yet, show it as a column below
        this._columns.push({
          select: ['EntryType/Name,EntryType/Name2,EntryType/Name3'],
          label: () => this.translate.instant('Entry_EntryType'),
          display: (entry: DetailsEntry) => {
            return this.ws.getMultilingualValue('EntryType', entry.EntryTypeId, 'Name');
          },
          weight: 1
        });
      }

      // Center
      if (this.showCenterParameter && !this.readonlyCenter_Manual && !this.centerId) {
        // If a parameter is visible, editable and not selected yet, show it as a column below
        this._columns.push({
          select: ['Center/Name,Center/Name2,Center/Name3'],
          label: () => this.translate.instant('Entry_Center'),
          display: (entry: DetailsEntry) => {
            return this.ws.getMultilingualValue('Center', entry.CenterId, 'Name');
          },
          weight: 1
        });
      }

      // All dynamic properties from account type label
      if (!!accountType) {
        // DueDate
        if (!!accountType.DueDateLabel) {
          this._columns.push({
            select: ['DueDate'],
            label: () => this.ws.getMultilingualValueImmediate(accountType, 'DueDateLabel'),
            display: (entry: DetailsEntry) => !!entry.DueDate ? formatDate(entry.DueDate, 'yyyy-MM-dd', locale) : '',
            weight: 1
          });
        }

        // Time1
        if (!!accountType.Time1Label) {
          this._columns.push({
            select: ['Time1'],
            label: () => this.ws.getMultilingualValueImmediate(accountType, 'Time1Label'),
            display: (entry: DetailsEntry) => !!entry.Time1 ? formatDate(entry.Time1, 'yyyy-MM-dd HH:mm', locale) : '',
            weight: 1
          });
        }

        // Time2
        if (!!accountType.Time2Label) {
          this._columns.push({
            select: ['Time2'],
            label: () => this.ws.getMultilingualValueImmediate(accountType, 'Time2Label'),
            display: (entry: DetailsEntry) => !!entry.Time2 ? formatDate(entry.Time2, 'yyyy-MM-dd HH:mm', locale) : '',
            weight: 1
          });
        }

        // ExternalReference
        if (!!accountType.ExternalReferenceLabel) {
          this._columns.push({
            select: ['ExternalReference'],
            label: () => this.ws.getMultilingualValueImmediate(accountType, 'ExternalReferenceLabel'),
            display: (entry: DetailsEntry) => entry.ExternalReference,
            weight: 1
          });
        }

        // AdditionalReference
        if (!!accountType.AdditionalReferenceLabel) {
          this._columns.push({
            select: ['AdditionalReference'],
            label: () => this.ws.getMultilingualValueImmediate(accountType, 'AdditionalReferenceLabel'),
            display: (entry: DetailsEntry) => entry.AdditionalReference,
            weight: 1
          });
        }

        // NotedAgentName
        if (!!accountType.NotedAgentNameLabel) {
          this._columns.push({
            select: ['NotedAgentName'],
            label: () => this.ws.getMultilingualValueImmediate(accountType, 'NotedAgentNameLabel'),
            display: (entry: DetailsEntry) => entry.NotedAgentName,
            weight: 1
          });
        }

        // NotedDate
        if (!!accountType.NotedDateLabel) {
          this._columns.push({
            select: ['NotedDate'],
            label: () => this.ws.getMultilingualValueImmediate(accountType, 'NotedDateLabel'),
            display: (entry: DetailsEntry) => !!entry.NotedDate ? formatDate(entry.NotedDate, 'yyyy-MM-dd', locale) : '',
            weight: 1
          });
        }
      }

      // Resource
      if (this.showResourceParameter && !this.readonlyResource_Manual && !this.resourceId) {
        // If a parameter is visible, editable and not selected yet, show it as a column below
        this._columns.push({
          select: ['Resource/Name,Resource/Name2,Resource/Name3'],
          label: () => this.labelResource_Manual,
          display: (entry: DetailsEntry) => {
            return this.ws.getMultilingualValue('Resource', entry.ResourceId, 'Name');
          },
          weight: 1
        });
      }

      // Quantity + Unit
      if (this.showResourceParameter) {
        // Determine whether the resource specifies a single well defined unit
        const singleUnitDefined = !!resource && !!resource.Units && resource.Units.length === 1;

        this._columns.push({
          select: ['Direction', 'Quantity'],
          label: () => {
            let label = this.translate.instant('Entry_Quantity');
            if (singleUnitDefined) {
              const unitId = resource.Units[0].UnitId;
              label = `${label} (${this.ws.getMultilingualValue('Unit', unitId, 'Name')})`;
            }
            return label;
          },
          display: (entry: DetailsEntry) => {
            return formatAccounting(entry.Direction * entry.Quantity, '1.0-4');
          },
          isRightAligned: true,
          weight: 1
        });

        if (singleUnitDefined) {

          // Quantity Acc.
          this._columns.push({
            id: 'QuantityAccumulation',
            select: ['Quantity', 'Direction'],
            label: () => {
              const unitId = resource.Units[0].UnitId;
              return `${this.translate.instant('DetailsEntry_QuantityAccumulation')} (${this.ws.getMultilingualValue('Unit', unitId, 'Name')})`;
            },
            display: (entry: DetailsEntry) => {
              if (isSpecified(entry.QuantityAccumulation)) {
                return formatAccounting(entry.QuantityAccumulation, '1.0-4');
              } else {
                return '';
              }
            },
            isRightAligned: true,
            weight: 1
          });
        }

        if (!singleUnitDefined) {
          this._columns.push({
            select: ['Unit/Name', 'Unit/Name2', 'Unit/Name3'],
            label: () => this.translate.instant('Entry_Unit'),
            display: (entry: DetailsEntry) => this.ws.getMultilingualValue('Unit', entry.UnitId, 'Name'),
            weight: 1
          });
        }
      }

      const definedCurrencyId = this.getAccountResourceCurrencyId() || this.currencyId;
      if (!!this.account() && definedCurrencyId !== this.functionalId) {

        // Monetary Value
        this._columns.push({
          select: ['MonetaryValue', 'Direction'],
          label: () => {
            let label = this.translate.instant('Entry_MonetaryValue');
            if (!!definedCurrencyId) {
              label = `${label} (${this.ws.getMultilingualValue('Currency', definedCurrencyId, 'Name')})`;
            }
            return label;
          },
          display: (entry: DetailsEntry) => {
            const currencyId = definedCurrencyId || entry.CurrencyId;
            return formatAccounting(entry.Direction * entry.MonetaryValue, this.digitsInfo(currencyId));
          },
          isRightAligned: true,
          weight: 1
        });

        if (!!definedCurrencyId) {
          // MonetaryValue Acc.
          this._columns.push({
            id: 'MonetaryValueAccumulation',
            select: ['MonetaryValue', 'Direction'],
            label: () => {
              return `${this.translate.instant('DetailsEntry_MonetaryValueAccumulation')} (${this.ws.getMultilingualValue('Currency', definedCurrencyId, 'Name')})`;
            },
            display: (entry: DetailsEntry) => {
              if (isSpecified(entry.MonetaryValueAccumulation)) {
                return formatAccounting(entry.MonetaryValueAccumulation, this.digitsInfo(definedCurrencyId));
              } else {
                return '';
              }
            },
            isRightAligned: true,
            weight: 1
          });

        } else {
          // Currency
          this._columns.push({
            select: ['Currency/Name', 'Currency/Name2', 'Currency/Name3', 'Currency/E'], // The E is to format the values correctly
            label: () => this.translate.instant('Entry_Currency'),
            display: (entry: DetailsEntry) => this.ws.getMultilingualValue('Currency', entry.CurrencyId, 'Name'),
            weight: 1
          });
        }
      }

      // Debit
      this._columns.push({
        select: ['Value', 'Direction'],
        label: () => `${this.translate.instant('Debit')} (${this.ws.getMultilingualValueImmediate(settings, 'FunctionalCurrencyName')})`,
        display: (entry: DetailsEntry) => {
          if (entry.Direction > 0 && isSpecified(entry.Value)) {
            return formatNumber(entry.Value, locale, this.functionalDigitsInfo);
          } else {
            return '';
          }
        },
        isRightAligned: true,
        weight: 1
      });

      // Credit
      this._columns.push({
        select: ['Value', 'Direction'],
        label: () => `${this.translate.instant('Credit')} (${this.ws.getMultilingualValueImmediate(settings, 'FunctionalCurrencyName')})`,
        display: (entry: DetailsEntry) => {
          if (entry.Direction < 0 && isSpecified(entry.Value)) {
            return formatNumber(entry.Value, locale, this.functionalDigitsInfo);
          } else {
            return '';
          }
        },
        isRightAligned: true,
        weight: 1
      });

      // Acc.
      this._columns.push({
        id: 'Accumulation',
        select: ['Value', 'Direction'],
        label: () => `${this.translate.instant('DetailsEntry_Accumulation')} (${this.ws.getMultilingualValueImmediate(settings, 'FunctionalCurrencyName')})`,
        display: (entry: DetailsEntry) => {
          if (isSpecified(entry.Accumulation)) {
            return formatAccounting(entry.Accumulation, this.functionalDigitsInfo);
            // return formatNumber(entry.Accumulation, locale, this.functionalDigitsInfo);
          } else {
            return '';
          }
        },
        isRightAligned: true,
        weight: 1
      });
    }

    return this._columns;
  }

  public fromWeight(weight: number) {
    const totalWeight = this.columns.map(e => e.weight).reduce((acc, v) => acc + v);
    if (totalWeight === 0) { // Impossible but added for robustness
      return '100%';
    }

    return ((weight / totalWeight) * 100) + '%';
  }

  public onSelectRow(entry: DetailsEntry) {
    const line = this.ws.get('LineForQuery', entry.LineId) as LineForQuery;
    const doc = this.ws.get('Document', line.DocumentId) as Document;
    const docId = doc.Id;
    const definitionId = doc.DefinitionId;
    const params = { state_key: 'from_statement', tab: -10 }; // fake state key to hide forward and backward navigation in details screen
    this.router.navigate(['../documents', definitionId, docId, params], { relativeTo: this.route });
  }

  // Collapse parameters
  private _collapseParameters = false;

  public get collapseParameters(): boolean {
    return this._collapseParameters;
  }

  public set collapseParameters(v: boolean) {
    if (this._collapseParameters !== v) {
      this._collapseParameters = v;
      this.urlStateChanged();
    }
  }

  onToggleCollapseParameters() {
    this.collapseParameters = !this.collapseParameters;
  }
}

interface ColumnInfo {
  id?: string;
  select: string[];
  label: () => string;
  display: (entry: DetailsEntry) => string;
  weight: number;
  isRightAligned?: boolean;
}
