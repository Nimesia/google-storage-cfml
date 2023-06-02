<h2>Simple tests</h2>
<cfparam name="action" default="">

<cfset menuItems = QueryNew("item", "varchar", [
	["insertFile"],	["listFiles" ], ["deleteFileById"], ["getSignedUrl"], ["getFile"] 
])>

<p>
	Methods:
	<cfoutput query="#menuItems#">
		<a href="?action=#item#">#item#</a> |
	</cfoutput>
</p>

<cfif action is "getSignedUrl">

	<cfset storage = loadStorage()>

	<cfabort>
	
	<cfset result = storage.downloadFile( 
		title=title,
		type="image/png"
	)>
	
	<cfdump var="#result#">
	<cfabort>
	
	<cfset title = "test#randRange(1,199)#">
	<cfset path = "folder/folder2">
	
	<cfdump var="#storage.listFiles(title=title, path=path)#">

</cfif>

<cfif action IS "deleteFileById">

	<cfset storage = loadStorage()>

	<cfset fileName = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset title = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(fileName, '\')#">
	
	<cfset result = storage.insertFile( 
		filename=filename,
		title=title,
		mimeType="image/png"
	)>

	<cfset res = storage.deleteFileById( result.name )>

	<cfdump var="#res#">

</cfif>

<cfif action IS "insertFile">

	<cfset storage = loadStorage()>

	<cfset fileName = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset title = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(fileName, '\')#">
	
	<cfset result = storage.insertFile( 
		filename=filename,
		title=title,
		mimeType="image/png"
	)>

	<cfdump var="#result#">

</cfif>

<cfif action IS "getFile">

	<cfset storage = loadStorage()>
	
	<cfset fileName = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset title = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(fileName, '\')#">
	
	<cfset result = storage.insertFile( 
		filename=filename,
		title=title,
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