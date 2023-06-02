<h2>Simple tests</h2>
<cfparam name="action" default="">

<cfset menuItems = QueryNew("item", "varchar", [
	["insertFile"],	["listFiles" ], ["deleteFileById"], ["getSignedUrl"], ["getFile"], ["downloadFile"] 
])>

<p>
	Methods:
	<cfoutput query="#menuItems#">
		<a href="?action=#item#">#item#</a> |
	</cfoutput>
</p>

<cfif action is "downloadFile">

	<cfset storage = loadStorage()>

	<cfabort>
	
	<cfset result = storage.downloadFile( 
		fileId=fileId,
		type="image/png"
	)>
	
	<cfdump var="#result#">
	<cfabort>
	
	<cfset fileId = "test#randRange(1,199)#">
	<cfset path = "folder/folder2">
	
	<cfdump var="#storage.listFiles(fileId=fileId, path=path)#">

</cfif>

<cfif action is "getSignedUrl">

	<cfset storage = loadStorage()>

	<cfset fileName = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(fileName, '\')#">
	
	<cfset result = storage.insertFile( 
		filename=filename,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfset uri = storage.getSignedUrl( result.name, 10 )>

	<cfdump var="#uri#">

</cfif>

<cfif action IS "deleteFileById">

	<cfset storage = loadStorage()>

	<cfset fileName = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(fileName, '\')#">
	
	<cfset result = storage.insertFile( 
		filename=filename,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfset res = storage.deleteFileById( result.name )>

	<cfdump var="#res#">

</cfif>

<cfif action IS "insertFile">

	<cfset storage = loadStorage()>

	<cfset fileName = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(fileName, '\')#">
	
	<cfset result = storage.insertFile( 
		filename=filename,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfdump var="#result#">

</cfif>

<cfif action IS "getFile">

	<cfset storage = loadStorage()>
	
	<cfset fileName = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(fileName, '\')#">
	
	<cfset result = storage.insertFile( 
		filename=filename,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfdump var="#result#">

</cfif>

<cfif action IS "listFiles">
	
	<cfset storage = loadStorage()>

	<cfset files = storage.listFiles()>

	<cfdump var="#files#">

</cfif>


<cffunction name="loadStorage">

	<cfset var storage = new GoogleStorage(
		bucket         = 'opus-dev-bucket',
		pathToJsonFile = ExpandPath("/tests/config/key-b98b738d31f2.json")
	)>

	<cfreturn storage>

</cffunction>