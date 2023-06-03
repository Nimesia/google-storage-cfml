# Google Storage for CFML
Google Cloud Storage [(com.google.cloud.storage)](https://cloud.google.com/java/docs/reference/google-cloud-storage/latest/com.google.cloud.storage.Storage) wrapper in CFML, tested on Lucee 5.4.

## Install
1. Download all required jars from [jar-download.com](
https://jar-download.com/artifacts/com.google.cloud/google-cloud-storage)

2. Copy them in "/libs" (or whatever you want) directory, and than set consequently javaSettings var in you Application.cfc:
    
    ```sh
	this.javaSettings = {
		LoadPaths = ["/libs" ]
    }
    ```

## Usage

### Load class

Download the Json key file from your GCP console, copy it into your project directory. 

```sh
var storage = mew GoogleStorage( 
        bucket="YOUR_BUCKET_NAME", 
        pathToJsonFile=ExpandPath("/path/keys.json") 
    )

dump( storage ) //show all methods
```

---

### Methods

The followings are the public **methods** you can use:

* getFile

 Get details of file. Return struct.

  ```sh
  getFile( required String fileId ) 
  ```


* getSignedUrl
  
 Get signed url, valid until now() + minutes passed in arguments. Return url as string.

  ```sh
  getSignedUrl( required String minutes, required String fileId ) 
  ```

* deleteFileById

 Remove file by name. Return boolean.

  ```sh
  deleteFileById( required String fileId ) 
  ```

* listFiles

 Get files in bucket. Return array of struct.

 You can search for files (including path) starting with **prefix** argument.

  ```sh
  listFiles( String prefix ) 
  ```

* insertFile

Put file in bucket. Return struct of detail of file.

  ```sh
  insertFile( required String filePath, required String fileId, required String mimeType, Struct metadata ) 
  ```

Arguments:

      - filePath: full path of file to upload. Required
      - fileId: full path of file on GPC, without bucket name. Required
      - mimeType: mime type of file. Required
      - metadata: optional data in a key/value struct to add to the object

* downloadFromUrl

Download file. It is possible to set the filename by passing the **fileName** argument to the method.

  ```sh
  downloadFromUrl( required String fileId, String fileName ) 
  ```

> :warning: The **fileId** is the full path offile on GPC, without bucket.


## For simple testing

1. Use CommandBox. Start server and point your brower to http://127.0.0.1:9011/tests/index.cfm

2. Download the keys json file from your GCP console, copy it into the tests folder.

3. Fit the value of _pathToJsonFile_ arg in the _loadStorage()_ function in /tests/index.cfm
