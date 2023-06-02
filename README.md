# Google Storage for CFML
Google Cloud Storage [(com.google.cloud.storage)](https://cloud.google.com/java/docs/reference/google-cloud-storage/latest/com.google.cloud.storage.Storage) wrapper for CFML, tested on Lucee 5.4.

## Install
1. Download all required jars from [jar-download.com](
https://jar-download.com/artifacts/com.google.cloud/google-cloud-storage)

2. Copy them in "/libs" (or whatever you want) directory, and than set consequently javaSettings var in you Application.cfc:
    
    ```
	this.javaSettings = {
		LoadPaths = ["/libs" ]
    }
    ```

## Usage

Load class:

```
var storage = mew GoogleStorage( 
        bucket="YOUR_BUCKET_NAME", 
        pathToJsonFile=ExpandPath("/path/keys.json") 
    )

dump( storage ) //show all methods
```

Download the Json key file from your GCP console, copy it into your project directory. 

The followings are the public methods you can use:

* getFile

 Get details of file. Return struct;

  ```sh
  getFile( rrequired String fileId ) 
  ```


* getSignedUrl
  
 Get signed url, valid until now() + minutes passed in arguments. Return url as string;

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

 You can search for files (including path) starting with **prefix** argument

  ```sh
  listFiles( String prefix ) 
  ```

* insertFile

Put file in bucket. Return struct of detail of file.
Arguments:

  ```sh
  insertFile( required String fileName, required String fileId, required String mimeType ) 
  ```

> :warning: The **fileId** is the full path file, without bucket;


## For testing

1. Download the keys json file from your GCP console, copy them into the test folder.

2. Fit the values in the "loadStorage()" function in /tests/index.cfm
