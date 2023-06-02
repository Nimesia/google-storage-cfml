# Google Store for CFML
Google Storage (com.google.cloud.storage) wrapper for CFML, tested on Lucee 5.4.

## Install
1. Download all required jars from [jar-download.com](
https://jar-download.com/artifacts/com.google.cloud/google-cloud-storage)

2. Copy them in "/libs" (or whatever you want) directory, and than set consequently javaSettings var in you Application.cfc:
    
    ```
	this.javaSettings = {
		LoadPaths = ["/libs" ]
    }
    ```

## Start

Load class:

```
var storage = GoogleStorage( 
        bucket="YOUR_BUCKET_NAME", 
        pathToJsonFile=ExpandPath("/path/keys.json") 
    )

dump( storage ) //show all methods
```


Download the Json key file from your GCP console, copy them into your project directory. 


## For testing

1. Download the keys json file from your GCP console, copy them into the test folder.

2. Fit the values in the "loadStorage()" function in /tests/index.cfm
