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
    open func downloadConfig(_ featureName:String?=Download.defaultFeatureName,
                         remoteUrl:URL,
                         status:@escaping DownloadDataConfig){
        if let download:Download = Download.download(featureName,remoteUrl:remoteUrl.absoluteString){
            if let downloadService = DownloadManager.shared.fileService(remoteUrl){
                let value = downloadService.percentageDownloaded.bs_cgFloat
                downloadService.didReceive(didReceive: {
                    download.update(totalBytesCount:downloadService.totalBytesExpectedToWrite.bs_int,downloadService.totalBytesWritten.bs_int, handler: nil);
                    let value = downloadService.percentageDownloaded.bs_cgFloat
                    status(download.status,value,downloadService.state)
                })
                downloadService.didFinishDownloadingTo({ (url) in
                    download.update(url, handler: nil);
                    status(.downloaded,1.0,downloadService.state)
                })
                downloadService.didFinishDownloadingWithError { (error) in
                    let value = downloadService.percentageDownloaded.bs_cgFloat
                    status(download.status,value,downloadService.state)
                }
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
        if let download = Download.download(featureName,remoteUrl:remoteUrl.absoluteString){
            let downloadService = DownloadManager.shared.addfileService(remoteUrl, localFile:localFile)
            downloadService?.didReceive(didReceive: {
                download.update(totalBytesCount:(downloadService?.totalBytesExpectedToWrite ?? 0).bs_int, (downloadService?.totalBytesWritten ?? 0).bs_int, handler: nil);
                let value = downloadService?.percentageDownloaded.bs_cgFloat
                status(download.status,value,downloadService?.state)
            })
            downloadService?.didFinishDownloadingTo({ (url) in
                download.update(url, handler: nil);
                status(.downloaded,1.0,downloadService?.state)
            })
            downloadService?.didFinishDownloadingWithError { (error) in
                let value = downloadService?.percentageDownloaded.bs_cgFloat
                status(download.status,value,downloadService?.state)
            }
            switch download.status ?? .notDownloaded{
            case .notDownloaded:
                downloadService?.resume();
                break;
            case .downloaded:
                break;
            case .downloading:
                let status = downloadService?.state ?? .suspended
                    switch status {
                    case .running:
                        downloadService?.cancel(byProducingResumeData: { (data) in
                            if let data:Data = data{
                                downloadService?.build(data: data);
                            }
                            })
                        break;
                    case .suspended:
                        if let  url = downloadService?.localFileUrl {
                            if var data = try? Data.init(contentsOf:url) {
                                downloadService?.build(data: data);
                            }
                            downloadService?.resume();
                            }
                        break;
                    case .canceling:
//                        if let  url = downloadService?.localFileUrl {
//                            if var data = try? Data.init(contentsOf:url) {
//                                downloadService?.build(data: data);
//                            }
                            downloadService?.resume();
//                            }
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
