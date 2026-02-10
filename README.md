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

- FileDownloadService
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
- For Canceling the download service.

```swift
        downloadService?.cancel(byProducingResumeData:nil);
```
