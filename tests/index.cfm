<!----
<cfset storage = new GoogleStorage(
	serviceAccountID    = "117579987863854591514",
	serviceAccountEmail = "opus-zeus@opus-plus-dev.iam.gserviceaccount.com",
	pathToKeyFile       = ExpandPath("secretKey.p12"),
	applicationName     = "theGoogleStorage",
	bucket              = 'opus-dev-bucket'
)>
----->
<cfset storage = new GoogleStorage(
	serviceAccountID    = "117579987863854591514",
	serviceAccountEmail = "opus-zeus@opus-plus-dev.iam.gserviceaccount.com",
	pathToKeyFile       = ExpandPath("/tests/config/key-binary.p12"),
	pathToJsonFile      = ExpandPath("/tests/config/key-b98b738d31f2.json"),
	applicationName     = "theGoogleStorage",
	bucket              = 'opus-dev-bucket'
	/*
	pathToKeyFile = ExpandPath('/opus-plus-dev-b98b738d31f2.json'),
	bucket        = 'opus-dev-bucket'
	*/
)>

<!--- <cfdump  var = "#createObject("java","com.google.api.services.storage.Storage")#"> ---->
<cfset build ="#storage.build()#">


<!--- <cfdump var="#storage.insertFile(title = 'test#randRange(1,199)#', filename = ExpandPath('/tests/pdf/prova1.pdf'),  mimeType = 'application/pdf')#">
<cfdump var="#storage.downloadFile(fileId = 'test69', type="jpg")#"> --->
<cfset fileName = ExpandPath('/tests/assets/img/home-#RandRange(1,4)#.png')>

<cfset title = "tests/#TimeFormat(now(), 'HHmmss')#-#ListLast(fileName, '\')#">

<cfset result = storage.insertFile( 
	filename=filename,
	title=title,
	mimeType="image/png"
)>
<cfdump var="#result#" expand="true">

<cfdump var="#result#" expand="false">

<cfdump var="#storage.getSignedUrl(
	expirationDate=CreateDate( 2023, 6, 30 ),
	GCPFile = result.name
)#">

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
