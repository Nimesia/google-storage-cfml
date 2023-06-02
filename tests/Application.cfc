component {

	this.name = "google-storage-cfml"
	
	this.javaSettings = {
		LoadPaths = ["/libs" ], 
		loadCFMLClassPath = true, 
		reloadOnChange= true, 
		watchInterval = 100, 
		watchExtensions = "jar,class,xml"
	}

}

<!----
https://jar-download.com/artifacts/com.google.cloud/google-cloud-storage
https://github.com/PCommons/cf-google-drive
----->