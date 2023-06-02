component displayname="GoogleStorage" output="false" accessors="true" {

	property name="bucket" type="String";
	property name="storeService" type="Object";
	property name="credentials" type="Object";

	public GoogleStorage function init(
		required string bucket, 
		required string pathToJsonFile
	) {

		//setPathToKeyFile( arguments.pathToKeyFile );
		setBucket( arguments.bucket );

		var configFile = CreateObject("java", "java.io.FileInputStream").init( arguments.pathToJsonFile );

		var credentials = CreateObject("java", "com.google.auth.oauth2.ServiceAccountCredentials")
							.fromStream( configFile );

		var storage = CreateObject("java", "com.google.cloud.storage.StorageOptions")
						.newBuilder()
						.setCredentials( credentials )
						.build()
						.getService();

		setStoreService( storage );

		setCredentials( credentials );

		return this;
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
	public Array function listFiles(
		required String prefix="",
		required String pageSize=100,
	) {

		var results = [];

		var options = CreateObject("java", "com.google.cloud.storage.Storage$BlobListOption")
						//.prefix( 'opus-dev-bucket' );
		
		var record = getStoreService().list( 
				getBucket(), 
				[ 
					options
						.prefix( arguments.prefix ),
					options
						.pageSize( arguments.pageSize )//not works
				]
			) 
			.iterateAll()
			.iterator();
  
		while ( record.hasNext()) {

			var obj = record.next();

			results.add( {
				"name" = obj.getName(),
				"sisze" = obj.getSize()
			})

		}

		return results;

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
