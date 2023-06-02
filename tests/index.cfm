<h2>Simple tests</h2>
<cfparam name="action" default="">

<cfset menuItems = QueryNew("item", "varchar", [
	["insertFile"],	["listFiles" ], ["deleteFileById"], ["getSignedUrl"], ["getFile"], ["downloadFile"], ["downloadFromUrl"] 
])>

<p>
	<a href="?">Start</a> |
	Methods:
	<cfoutput query="#menuItems#">
		<a href="?action=#item#">#item#</a> |
	</cfoutput>
</p>

<cfif action is "downloadFile">

	<cfset storage = loadStorage()>

	<cfset filePath = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(filePath, '\')#">
	
	<cfset result = storage.insertFile( 
		filePath=filePath,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfset result = storage.downloadFile( 
		fileId=result.fileId,
		mimeType="image/png"
	)>
	
	<cfdump var="#result#">

</cfif>


<cfif action is "downloadFromUrl">

	<cfset storage = loadStorage()>

	<cfset filePath = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(filePath, '\')#">
	
	<cfset result = storage.insertFile( 
		filePath=filePath,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfset result = storage.downloadFromUrl( fileId=result.fileId, fileName=CreateUUID() & ".png" )>
	
	<cfdump var="#result#">

</cfif>

<cfif action is "getSignedUrl">

	<cfset storage = loadStorage()>

	<cfset filePath = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(filePath, '\')#">
	
	<cfset result = storage.insertFile( 
		filePath=filePath,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfset uri = storage.getSignedUrl( result.fileId, 10 )>

	<cfdump var="#uri#">

</cfif>

<cfif action IS "deleteFileById">

	<cfset storage = loadStorage()>

	<cfset filePath = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(filePath, '\')#">
	
	<cfset result = storage.insertFile( 
		filePath=filePath,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfset res = storage.deleteFileById( result.fileId )>

	<cfdump var="#res#">

</cfif>

<cfif action IS "insertFile">

	<cfset storage = loadStorage()>

	<cfset filePath = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(filePath, '\')#">
	
	<cfset result = storage.insertFile( 
		filePath=filePath,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfdump var="#result#">

</cfif>


<cfif action IS "getFile">

	<cfset storage = loadStorage()>
	
	<cfset filePath = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

	<cfset fileId = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(filePath, '\')#">
	
	<cfset result = storage.insertFile( 
		filePath=filePath,
		fileId=fileId,
		mimeType="image/png"
	)>

	<cfset obj = storage.getFile( fileId )>

	<cfdump var="#obj#">

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