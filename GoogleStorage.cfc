component displayname="GoogleStorage" output="false" accessors="true" {

	property name="bucket" type="String";
	property name="pathToKeyFile" type="String";
	property name="storeService" type="Object";
	property name="credentials" type="Object";

	public GoogleStorage function init(
		required string serviceAccountId, 
		required string bucket, 
		required string serviceAccountEmail, 
		required string pathToKeyFile, 
		required string pathToJsonFile, 
		required string applicationName
	) {

		variables.serviceAccountId    = arguments.serviceAccountId;
		variables.serviceAccountEmail = arguments.serviceAccountEmail;
		variables.pathToKeyFile       = arguments.pathToKeyFile;
		variables.applicationName     = arguments.applicationName;
		variables.bucket              = arguments.bucket;   

		variables.HTTPTransport     = CreateObject("java", "com.google.api.client.http.javanet.NetHttpTransport").init();
		variables.JSONFactory       = CreateObject("java", "com.google.api.client.json.jackson2.JacksonFactory").init();
		variables.credentialBuilder = CreateObject("java", "com.google.api.client.googleapis.auth.oauth2.GoogleCredential$Builder");
		variables.storageScopes     = CreateObject("java", "com.google.api.services.storage.StorageScopes");
		variables.Collections       = CreateObject("java", "java.util.Collections");
		variables.Arrays            = CreateObject("java", "java.util.Arrays");
		variables.credential        = "";
		variables.service           = "";

		variables.storageBuilder = CreateObject("java", "com.google.api.services.storage.Storage$Builder")
										.init(
											variables.HTTPTransport,
											variables.JSONFactory, 
											NullValue()
										);

		/**********************************/
		setPathToKeyFile( arguments.pathToKeyFile );
		setBucket( arguments.bucket );

		var configFile = CreateObject("java", "java.io.FileInputStream").init( arguments.pathToJsonFile );

		var credentials = CreateObject("java", "com.google.auth.oauth2.ServiceAccountCredentials")
							.fromStream( configFile );

		var storage = CreateObject("java", "com.google.cloud.storage.StorageOptions")
						.newBuilder()
						.setCredentials( credentials )
						.setProjectId("opus-plus-dev")
						.build()
						.getService();

		setStoreService( storage );

		setCredentials( credentials );


		/**********************************/										

		return this;
	}

	/**
	 * creates storage object
	 */
	public struct function build() {

		var result = {};
		
		result.credential = "";
		result.result = {};
		result.result.success = true;
		result.result.error = "";
		
		/*  
			Access tokens issued by the Google OAuth 2.0 Authorization Server expire in one hour. 
        	When an access token obtained using the assertion flow expires, then the application should 
         	generate another JWT, sign it, and request another access token. 
         	"https://www.googleapis.com/auth/drive","https://www.googleapis.com/auth/analytics"
         	https://developers.google.com/accounts/docs/OAuth2ServiceAccount 
		*/
		try {

			var keyFile = CreateObject("java", "java.io.File").init( variables.pathToKeyFile );

			result.credential = credentialBuilder
                                    .setTransport( variables.HTTPTransport )
                                    .setJsonFactory( variables.JSONFactory )
                                    .setServiceAccountId( variables.serviceAccountId )
                                    .setServiceAccountScopes( variables.Collections.singleton( variables.storageScopes.DEVSTORAGE_READ_WRITE ) )
                                    .setServiceAccountPrivateKeyFromP12File( keyFile )
                                    .build();

			variables.credentials = result.credential;

		} catch (any cfcatch) {
			result.result.error = "Credential Object Error: " & cfcatch.message & " - " & cfcatch.detail;
			result.result.success = false;
		}
		if ( result.result.success ) {
			
			try {

				variables.service = variables.storageBuilder
            		.setApplicationName( variables.applicationName )
            		.setHttpRequestInitializer( result.credential )
            		.build();
			
			} catch (any cfcatch) {
				
				result.result.error = "Storage Object Error: " & cfcatch.message & " - " & cfcatch.detail;
				result.result.success = false;
			
			}
		}


		//dump( variables.service );
		//abort;

		return result;
	}	

	/*
	public GoogleStorage function init(
		required string bucket, 
		required string pathToKeyFile, 
	) {

		setPathToKeyFile( arguments.pathToKeyFile );
		setBucket( arguments.bucket );

		var configFile = CreateObject("java", "java.io.FileInputStream").init( arguments.pathToKeyFile );

		var credentials = CreateObject("java", "com.google.auth.oauth2.ServiceAccountCredentials")
							.fromStream( configFile );

		var storage = CreateObject("java", "com.google.cloud.storage.StorageOptions")
						.newBuilder()
						.setProjectId(projectId)
						.build()
						.getService();

		setService( storage );


		setCredentials( credentials );

		return this;
	}
	*/

	/**
	 * creates storage object
	 */
	public struct function build() {

		var result = {};
		
		result.credential = "";
		result.result = {};
		result.result.success = true;
		result.result.error = "";
		
		/*  
			Access tokens issued by the Google OAuth 2.0 Authorization Server expire in one hour. 
        	When an access token obtained using the assertion flow expires, then the application should 
         	generate another JWT, sign it, and request another access token. 
         	"https://www.googleapis.com/auth/drive","https://www.googleapis.com/auth/analytics"
         	https://developers.google.com/accounts/docs/OAuth2ServiceAccount 
		*/
		try {

			var keyFile = CreateObject("java", "java.io.File").init( variables.pathToKeyFile );

			result.credential = credentialBuilder
                                    .setTransport( variables.HTTPTransport )
                                    .setJsonFactory( variables.JSONFactory )
                                    .setServiceAccountId( variables.serviceAccountId )
                                    .setServiceAccountScopes( variables.Collections.singleton( variables.storageScopes.DEVSTORAGE_READ_WRITE ) )
                                    .setServiceAccountPrivateKeyFromP12File( keyFile )
                                    .build();

		} catch (any cfcatch) {
			result.result.error = "Credential Object Error: " & cfcatch.message & " - " & cfcatch.detail;
			result.result.success = false;
		}
		if ( result.result.success ) {
			
			try {

				variables.service = variables.storageBuilder
            		.setApplicationName( variables.applicationName )
            		.setHttpRequestInitializer( result.credential )
            		.build();
			
			} catch (any cfcatch) {
				
				result.result.error = "Storage Object Error: " & cfcatch.message & " - " & cfcatch.detail;
				result.result.success = false;
			
			}
		}


		//dump( variables.service );
		//abort;

		return result;
	}

	public any function getSignedUrl(
		required Date expirationDate,
		required String GCPFile
	) {

		var bucketName = getBucket();
		var blobName = arguments.GCPFile;
		var projectId = "opus-plus-dev";

		var blobInfo = CreateObject("java", "com.google.cloud.storage.BlobInfo");
		var BlobId = CreateObject("java", "com.google.cloud.storage.BlobId");

		/*
		var configFile = CreateObject("java", "java.io.FileInputStream").init( ExpandPath('/opus-plus-dev-b98b738d31f2.json') );

		var storage = CreateObject("java", "com.google.cloud.storage.StorageOptions")
						.newBuilder()
						.setProjectId(projectId)
						.build()
						.getService();

		var credentials = CreateObject("java", "com.google.auth.oauth2.ServiceAccountCredentials")
							.fromStream( configFile );
		*/


		var uri = getStoreService().signUrl(
					blobInfo.newBuilder(BlobId.of(bucketName, blobName)).build(), 
					10,
					CreateObject("java", "java.util.concurrent.TimeUnit").MINUTES,
					[
						CreateObject("java", "com.google.cloud.storage.Storage$SignUrlOption").signWith(
							getCredentials()
						)
					]
				);

		return uri.toString();

	}

	/**
	 * 
	 */
	/*
	public any function getAccessToken(required struct build) {
		
		var result = {};
		result.results = {};
		result.results.error = "";
		
		try {
			
			result.results = build.credential.getAccessToken();
		
		} catch (any cfcatch) {
			
			result.results.error = cfcatch.message & " " & cfcatch.detail;
		
		}
		return result.results;
	}
	*/

	/**
	 * 
	 */
	public struct function getFile(
         required String title,
         String path
      ) {
		var result = {};
		result.results = {};
		result.results.error = "";
		
		try {
         
			if ( !isNull( path ) ) {
				title = "#path#/#title#";
			}

			result.results = variables.service.objects().get(variables.bucket, title).execute();
		
		} catch (any cfcatch) {
			
			result.results.error = cfcatch.message & " " & cfcatch.detail;
		
		}
		
		return result.results;
	}

	public any function deleteFileById(required string fileId) {

		var result = {};
		result.results = {};
		result.results.error = "";
		
		try {
			result.results = variables.service.objects().delete(variables.bucket, fileId).execute();
			result.results = {removed: true};
		
		} catch (any cfcatch) {
		
			result.results.error = cfcatch.message & " " & cfcatch.detail;
		
		}
		
		return result.results;
	}


	/**
	 * 
	 */
	public struct function listFiles() {


		var outcome = getStoreService().list( getBucket() )

		dump( outcome );
		abort;




		/*
		var result = {};
		result.results = {};
		result.results.error = "";
		try {
			//dump(variables.service.objects());
			result.results.items = variables.service.objects().list(variables.bucket).execute().getItems();
		} catch (any cfcatch) {
			result.results.error = cfcatch.message & " " & cfcatch.detail;
		}
		return result.results;
		*/
	}

	public function downloadToBrowser(required string downloadUrl, required string mimeType, required string fileName) {
		fname    = ReReplace(fileName,"[[:space:]]","_","ALL");
		tempDir  = getTempDirectory();
		tempFile = getFileFromPath(getTempFile(tempDir, fname));
		cfhttp( getAsBinary=true, url=downloadUrl, result="get", method="get" );
		cfheader( name="Content-Disposition", value="attachment; filename=#fname#" );
		cfcontent( reset=true, variable=ToBinary(ToBase64(get.fileContent)), type="text/plain" );
	}

	/**
	 * 
	 */
	public function downloadFile(required string title, required string type) {
       
      if ( !isNull( path ) ) {
         title = "#path#/#title#";
      }
		
		//var download = variables.service.objects().get(variables.bucket, title).executeMediaAsInputStream();
		var download = variables.service.objects().get(variables.bucket, title);

		cfheader( name="Content-Disposition", value="attachment; filename=#title#.#type#" );
		cfcontent( reset=true, variable=ToBinary(ToBase64(download.readAllBytes())) );
	}

	/**
	 * 
	 */
	public Struct function insertFile(
         required string filename, //filePath
         required String title, 
         required string mimeType,
         String path
      ) {

		var blobInfo = CreateObject("java", "com.google.cloud.storage.BlobInfo");
		var BlobId = CreateObject("java", "com.google.cloud.storage.BlobId");

		if (!FileExists( arguments.fileName )) {

			raiseError( 
				type="FileToUploadNotExists", 
				message="File [#arguments.fileName#] not exists"
			)

		}

		try{

			var outcome = getStoreService().create(
					blobInfo
						.newBuilder( BlobId.of( getBucket(), arguments.title ))
						.setContentType( arguments.mimeType )
						.build(),
					CreateObject("java", "java.io.FileInputStream")
						.init( arguments.filename ),
					[]
				)

		} catch( any error ) {

			raiseError(type="NotCreateFileInStore", message="#error.message#", error=error)

		}


		var result = {
			size = outcome.getSize(),
			name = outcome.getName()
		}

		return result;
	}


	/*
		Private methods
	*/

	private Void function raiseError( required String type, required String message="",  Struct error={} ){

		throw(
			type    = "GoogleStorageCfml.errors.#arguments.type#",
			message = arguments.message,
			object  = arguments.error
		)

	}

}
