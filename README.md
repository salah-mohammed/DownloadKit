# DownloadKit

DownloadKit operates as a multi-layered system of services like a file processing system, an individual download service, and a queue for group download services.


# Requirements
* IOS 13+ 
* Swift 5+



# Pod install
```ruby
pod 'DownloadKit',:git => "https://github.com/salah-mohammed/DownloadKit.git"
 
```
# How used

- FileDownloadService, used to download data and save it in your path.
```swift
var downloadService:FileDownloadService?
downloadService = FileDownloadService.init(url:URL.init(string:"https://ia802302.us.archive.org/27/items/Pbtestfilemp4videotestmp4/video_test.mp4")!);
        downloadService?.autoSave=true;
        downloadService?.localFile = .downloads(folderName:"Videos/mp4Folder",localefileName:"video_test", fileType:"mp4")

        downloadService?.didReceive(didReceive: {
            self.sliderView.value  = self.downloadService?.percentageDownloaded ?? 0;
            self.lblBufferLength.text = "\(self.downloadService?.totalBytesWritten ?? 0)";
            self.lblContentLength.text = "\(self.downloadService?.totalBytesExpectedToWrite ?? 0)";
            
        })
        downloadService?.didFinishDownloadingWithError({ (error) in
            print(error);
        })
        downloadService?.didFinishDownloadingTo({ (url) in
            print("completeReceive");

        })
        downloadService?.resume();
```
- For Canceling the FileDownloadService.

```swift
        downloadService?.cancel(byProducingResumeData:nil);
```
- For resumeing FileDownloadService even if your turn off the app, file link required only and do this.

```swift
        if let  url:URL = self.downloadService?.localFileUrl {
            if var data:Data = try? Data.init(contentsOf:url){
                downloadService?.build(data: data);
                downloadService?.resume();
            }
        }
```

- DownloadManager 
```swift
var appDownloadManager = defaultAppDownloadManager
```
or 
```swift
public var defaultAppDownloadManager = AppDownloadManager.init(featureName:"DownloadList")
```
- DownloadService, used to download data only, without saving in files.

```swift
    var downloadService:DownloadService?

       downloadService =  DownloadService.init(url: URL.init(string:"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!)
        downloadService?.didReceive(didReceive: {
            self.sliderView.value  = self.downloadService?.percentageDownloaded ?? 0;
            self.lblBufferLength.text = "\(self.downloadService?.bufferLength ?? 0)";
            self.lblContentLength.text = "\(self.downloadService?.contentLength ?? 0)";

        })
        downloadService?.completeWithError(completeWithError: {
            print("error to download");
        })
        downloadService?.completeReceive(completeReceive: {
            print("completeReceive");
        })
```
