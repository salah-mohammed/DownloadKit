//
//  DownloadKitManager.swift
//  DownloadKit
//
//  Created by SalahMohamed on 24/10/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import UIKit
#if canImport(Realm)
#if canImport(RealmSwift)
import Realm
import RealmSwift
open class DownloadKitManager: NSObject {
    public typealias DownloadData = (Download.Status?,CGFloat?,URLSessionTask.State?)
    public typealias DownloadDataConfig = (Download.Status?,CGFloat?,URLSessionTask.State?) -> Void
    var realm:Realm?
    public static let shared: DownloadKitManager = { DownloadKitManager()} ()
    var downloadIndex:Int?;
    var donwloadAllIsActive:Bool=false{
        didSet{
            if donwloadAllIsActive{
                NotificationCenter.default.addObserver(self, selector: #selector(DownloadKitManager.finish(_:)), name:Notification.Name.DidFinishDownloadingTo, object: nil)
            }else{
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    override init() {
        super.init()
        var config = Realm.Configuration()
        config.fileURL = config.fileURL?.deletingLastPathComponent().appendingPathComponent("DownloadKit.realm")
        autoreleasepool {
            do {
                self.realm = try? Realm(configuration: config)
            }catch let error as NSError {
                
            }
        }
    }
    // use for actions only don't use handlers
    open func downloadData(_ featureName:String?=Download.defaultFeatureName,
remoteUrl:URL)->(Download?,FileDownloadService?){
    let download:Download? = Download.download(featureName,remoteUrl:remoteUrl.absoluteString)
    let fileDownloadService:FileDownloadService? = DownloadManager.shared.fileService(remoteUrl)
    return (download,fileDownloadService)
}
    
    open func downloadConfig(_ featureName:String?=Download.defaultFeatureName,
                         remoteUrl:URL)->DownloadData{
        if let download:Download = Download.download(featureName,remoteUrl:remoteUrl.absoluteString){
            if let downloadService = DownloadManager.shared.fileService(remoteUrl){
                let value = downloadService.percentageDownloaded.bs_cgFloat
                return (download.status,value,downloadService.state)
            }else{
                return (download.status,download.percentageDownloaded.bs_cgFloat,nil)
            }
        }else{
            return (.notDownloaded,nil,nil)
        }
    }
    func download(_ old:Download?,_ featureName:String?=Download.defaultFeatureName,
                     remoteUrl:URL)->Download?{
        if let value:Download = old{
          return value
        }else{
        return Download.download(featureName,remoteUrl:remoteUrl.absoluteString)
        }
    }
    open func downloadConfig(_ featureName:String?=Download.defaultFeatureName,
                         remoteUrl:URL,
                         status:@escaping DownloadDataConfig){
        var download:Download? = Download.download(featureName,remoteUrl:remoteUrl.absoluteString)
        let downloadService:FileDownloadService? = DownloadManager.shared.fileService(remoteUrl)
        if let downloadService:FileDownloadService = downloadService{
            downloadService.didReceive(didReceive: {
                download = self.download(download,featureName,remoteUrl:remoteUrl)
                download?.update(totalBytesCount:downloadService.totalBytesExpectedToWrite.bs_int,downloadService.totalBytesWritten.bs_int, handler: nil);
                let value = downloadService.percentageDownloaded.bs_cgFloat
                status(download?.status,value,downloadService.state)
            })
            downloadService.didFinishDownloadingTo({ (url) in
                download = self.download(download,featureName,remoteUrl:remoteUrl)
                download?.update(url, handler: nil);
                status(.downloaded,1.0,downloadService.state)
            })
            downloadService.didFinishDownloadingWithError { (error) in
                download = self.download(download,featureName,remoteUrl:remoteUrl)
                let value = downloadService.percentageDownloaded.bs_cgFloat
                status(download?.status,value,downloadService.state)
            }
        }
        if let download:Download = download{
            if let downloadService:FileDownloadService = downloadService{
                let value = downloadService.percentageDownloaded.bs_cgFloat
                status(download.status,value,downloadService.state)
            }else{
                status(download.status,download.percentageDownloaded.bs_cgFloat,nil)
            }
        }else{
            status(.notDownloaded,nil,nil)
        }
    }
    //_ a:FileDownloadService.DidReceive
    open func downloadAction(_ featureName:String?=Download.defaultFeatureName,
                remoteUrl:URL,
                localFile:FileDownloadService.LocalFile,
                status:@escaping DownloadDataConfig){
        var download = Download.download(featureName,remoteUrl:remoteUrl.absoluteString)
        var downloadService = DownloadManager.shared.addfileService(remoteUrl, localFile:localFile)

        downloadService?.didReceive(didReceive: {
            download = self.download(download,featureName,remoteUrl:remoteUrl)
            download?.update(totalBytesCount:(downloadService?.totalBytesExpectedToWrite ?? 0).bs_int, (downloadService?.totalBytesWritten ?? 0).bs_int, handler: nil);
            let value = downloadService?.percentageDownloaded.bs_cgFloat
            status(download?.status,value,downloadService?.state)
        })
        downloadService?.didFinishDownloadingTo({ (url) in
            download = self.download(download,featureName,remoteUrl:remoteUrl)
            download?.update(url, handler: nil);
            status(.downloaded,1.0,downloadService?.state)
        })
        downloadService?.didFinishDownloadingWithError { (error) in
            download = self.download(download,featureName,remoteUrl:remoteUrl)
            let value = downloadService?.percentageDownloaded.bs_cgFloat
            status(download?.status,value,downloadService?.state)
        }
        if let download = download{
            switch download.status ?? .notDownloaded{
            case .notDownloaded:
                downloadService?.resume();
                break;
            case .downloaded:
                break;
            case .downloading:
                let downloadServiceStatus = downloadService?.state ?? .suspended
                    switch downloadServiceStatus {
                    case .running:
                        self.donwloadAllIsActive=false;
                        downloadService?.cancel(byProducingResumeData: { (data) in
                            if let data:Data = data{
                                downloadService?.build(data: data);
                            }
                            })
                        break;
                    case .suspended:
//                        if let  url = downloadService?.localFileUrl {
//                            if var data = try? Data.init(contentsOf:url) {
//                                downloadService?.build(data: data);
//                            }else{
//                                downloadService?.build(url: remoteUrl);
//                            }
//                            downloadService?.resume();
//                            }
                        if downloadService?.dataTask?.error != nil {
                            downloadService?.build(url: remoteUrl);
                        }
                        downloadService?.resume();

                        break;
                    case .canceling:
                            downloadService?.resume();
                        break;
                    case .completed:
                        break;
                    @unknown default:
                        break;
                    }
                break;
            }
        }
    }
    open func downloadAll(){
        if donwloadAllIsActive==false{
            donwloadAllIsActive=true;
        }
        self.downloadFirstNotDownloaded();
    }
    func downloadFirstNotDownloaded(){
        let items = DownloadManager.shared.items
        var notDownlaodedService = items.first { service in
            let download = Download.download(service.featureName,remoteUrl:service.url!.absoluteString)
            return download?.status != .downloaded
        }
        downloadIndex = items.firstIndex(where: {notDownlaodedService == $0});
        notDownlaodedService?.resume();
    }
    @objc func finish(_ notification:NSNotification){
        
        let  items = DownloadManager.shared.items;
//        if let notification:FileDownloadService=notification.object as? FileDownloadService{
            if let oldIndex:Int = self.downloadIndex{
                if  (oldIndex+1) < items.count{
                    self.downloadIndex = (oldIndex+1)
                    var newFileService =  items[self.downloadIndex ?? 0];
                    let download = Download.download(newFileService.featureName,remoteUrl:newFileService.url!.absoluteString)
                        if download?.status == .downloaded{
                            self.finish(_:notification)
                        }else{
                            newFileService.resume();
                        }
                }
            }
//        }
    }
}

#endif
#endif

extension Int64 {
    public var bs_int:Int
    {
        return Int.init(self);
    }
    public var bs_cgFloat:CGFloat{
        return  CGFloat.init(self)
    }
    
    
}
extension Float{
    public var bs_cgFloat:CGFloat?{
        return CGFloat(self);
    }
}
