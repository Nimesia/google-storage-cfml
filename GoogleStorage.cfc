component displayname="GoogleStorage" output="false" accessors="true" {

	property name="bucket" type="String";
	property name="service" type="Object";

	public GoogleStorage function init(
		required string bucket, 
		required string pathToJsonFile
	) {

		setBucket( arguments.bucket );

		var configFile = CreateObject("java", "java.io.FileInputStream").init( arguments.pathToJsonFile );

		var credentials = CreateObject("java", "com.google.auth.oauth2.ServiceAccountCredentials")
							.fromStream( configFile );

		var storage = CreateObject("java", "com.google.cloud.storage.StorageOptions")
						.newBuilder()
						.setCredentials( credentials )
						.build()
						.getService();

		setService( storage );

		return this;
	}

	/**
	 * 
	 */
	public any function getSignedUrl(
		required String fileId,
		required Numeric minutes
	) {

		var blobInfo = CreateObject("java", "com.google.cloud.storage.BlobInfo");
		var BlobId = CreateObject("java", "com.google.cloud.storage.BlobId");

		var uri = getService().signUrl(
					blobInfo.newBuilder(BlobId.of( getBucket(), arguments.fileId ) ).build(), 
					arguments.minutes,
					CreateObject("java", "java.util.concurrent.TimeUnit").MINUTES,
					[]
				);

		return uri.toString();

	}

	/**
	 * 
	 */
	public Struct function getFile(
         required String fileId
      ) {

		var blobId = CreateObject("java", "com.google.cloud.storage.BlobId");

		var obj = getService().get( blobId.of( getBucket(), arguments.fileId ) );

		return createFile( obj );;

	}

	/**
	 * 
	 */
	public Boolean function deleteFileById(required string fileId) {

		var result = getService().delete( getBucket(), arguments.fileId, [] );

		return result;

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
		
		var record = getService().list( 
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
  
		while ( record.hasNext() ) {

			var obj = record.next();

			results.add(
				createFile( obj )
			);

		}

		return results;

	}

	/**
	 * 
	 */
	public Void function downloadFromUrl(required String fileId, String fileName="" ) {

		var uri = getSignedUrl( fileId, 3 )

		var fname = Len( arguments.fileName ) ? arguments.fileName : arguments.fileId;

		cfhttp( getAsBinary=true, url=uri, result="result", method="get" );

		cfheader( name="Content-Disposition", value="attachment; filename=#fname#" );
		
		cfcontent( reset=true, variable=ToBinary(ToBase64(result.fileContent)), type="text/plain" );

	}


	/**
	 * 
	 */
	public Void function downloadFile(required String fileId, required string mimeType) {
	   
		var paths  = CreateObject("java", "java.nio.file.Paths");
		var files  = CreateObject("java", "java.nio.file.Files");
		
		// returns sun.nio.fs.WindowsPath instead of java.nio.file.Paths
		var destination  = CreateObject("java", "java.io.File").init( CreateUUID() ).toPath();
		
		var blobId = CreateObject("java", "com.google.cloud.storage.BlobId");

		getService().downloadTo( 
			blobId.of( getBucket(), arguments.fileId ), 
			// Raise error
			// Method downloadTo(com.google.cloud.storage.BlobId, sun.nio.fs.WindowsPath) not found
			destination 
		);

	}

	/**
	 * 
	 */
	public Struct function insertFile(
         required string filename, //filePath
         required String fileId, 
         required string mimeType
      ) {

		var blobInfo = CreateObject("java", "com.google.cloud.storage.BlobInfo");
		var BlobId = CreateObject("java", "com.google.cloud.storage.BlobId");

		if ( !FileExists( arguments.fileName ) ) {

			raiseError( 
				type="FileToUploadNotExists", 
				message="File [#arguments.fileName#] not exists"
			)

		}

		try{

			var obj = getService().create(
					blobInfo
						.newBuilder( BlobId.of( getBucket(), arguments.fileId ))
						.setContentType( arguments.mimeType )
						.build(),
					CreateObject("java", "java.io.FileInputStream")
						.init( arguments.filename ),
					[]
				)

		} catch( any error ) {

			raiseError(type="NotCreateFileInStore", message="#error.message#", error=error)

		}

		return createFile( obj );
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

	private Struct function createFile( required Object obj ){

		var result = {
			"size" = obj.getSize(),
			"fileId" = obj.getName(),
			"bucket" = obj.getBlobId().getBucket(),
			"createdAd" = epochToDate( obj.getCreateTime() )
		}

		return result;

	}

	private Date function epochToDate( required Number milliseconds ){
		return DateAdd("s", arguments.milliseconds/1000, "January 1 1970 00:00:00");
	}

}
