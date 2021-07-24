﻿CREATE PROCEDURE [dal].[LookupDefinitions__Delete]
	@Ids [dbo].[IndexedIdList] READONLY
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM @Ids I JOIN [dbo].[LookupDefinitions] D ON I.[Id] = D.[Id] WHERE D.[State] <> N'Hidden')
		UPDATE [dbo].[Settings] SET [DefinitionsVersion] = NEWID();

	DELETE [dbo].[LookupDefinitions]
	WHERE [Id] IN (SELECT [Id] FROM @Ids);
END;