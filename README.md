ge# DownloadKit

DownloadKit operates as a multi-layered system of services like a file processing system, an individual download service, and a queue for group download services.

[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](#)
[![iOS](https://img.shields.io/badge/iOS-13+-blue.svg)](#)
[![GitHub stars](https://img.shields.io/github/stars/salah-mohammed/GeneralKit?style=social)](#)
[![Sponsor](https://img.shields.io/badge/Sponsor-💖-ff69b4)](https://github.com/sponsors/salah-mohammed)
[![Buy Me A Coffee](https://img.shields.io/badge/☕️-Buy%20Me%20a%20Coffee-yellow)](https://buymeacoffee.com/salahalimou)

# Why Use This?

> Write less code, get more done, and keep your Swift projects elegant.
> Stop writing the same boilerplate downloading for download files again and again.  
> **DownloadKit** gives you a clean, reusable, and lightning-fast way to singlular download and Mass download  — so you can focus on building features that matter.

# Features

* It is a Data management Library  support HTTP networking.
* Data display management in UITableView and UICollectionView,In an easy and simple way and with the least possible code by GeneralKit tools.
* Pagination by page number and offset.
* Support UIKit and SwiftUI(WithExample).
* Very clean code.
* Tools to present data in UITableView and UICollectionView.
* Placeholder for UITableView  and UICollectionView.
* Single,Multi and Single Section selection  for UITableView  and UICollectionView.
* Upload File / Data / Stream / MultipartFormData.
* URL / JSON Parameter Encoding.
* You can develop a project with very clear code
* Swift Concurrency Support Back to iOS 13.
* Simulate Remote Response by local file.


# Requirements
* IOS 13+ 
* Swift 5+



# Pod install
```ruby
pod 'DownloadKit',:git => "https://github.com/salah-mohammed/DownloadKit.git"
```

# How use FileDownloadService

* FileDownloadService, Downloads singular file and saves it to your path.
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
- For Cancelling the FileDownloadService, Permanent suspension.

```swift
downloadService?.cancel(byProducingResumeData:nil);
```
- Even if your turn off the app or do Permanent suspension, resuming enable by FileDownloadService, file link required only and do this.

```swift
if let  url:URL = self.downloadService?.localFileUrl {
  if var data:Data = try? Data.init(contentsOf:url){
     downloadService?.build(data: data);
     downloadService?.resume();
      }
}
```
# How use DownloadManager
* DownloadManager, Downloads multiple files and saves them to your paths.
  
1. Define your manager.
```swift
var appDownloadManager = defaultAppDownloadManager
//or
var appDownloadManager = AppDownloadManager.init(featureName:"DownloadList")
```

2. Add your remote file and local file destination to manager.
```swift
let localefile = FileDownloadService.LocalFile.downloads(folderName:"Downloads/Audio/Mp3Folder",localefileName:"file_1",fileType:"mp3")  
defaultAppDownloadManager.addfileService(url, localFile:localefile)
```
3. Get download info, for your download file.
```swift  
var downloadConfig = defaultAppDownloadManager.downloadConfig(remoteUrl:url)
```
4. Track the progress and file status by this handler.
```swift     
defaultAppDownloadManager.downloadConfig(remoteUrl: url) { status, progress, fileState in
}
```
5. Set this in download button or action, all logic code inside libaray
```swift     
defaultAppDownloadManager.downloadAction(remoteUrl: remoteUrl, localFile: object.localFile()) { status, progressValue, sessionTaskStatus in
}
```
6. Download all: Controlling hidden of the button, depend if all downloaded or not. 
```swift     
self.showDownload = !defaultAppDownloadManager.donwloadAllIsActive
defaultAppDownloadManager.downloadAllIsActiveHandler = { value in
self.showDownload = !value
}
```
# How use DownloadService
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
