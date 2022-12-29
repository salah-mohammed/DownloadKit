//
//  DownloadManager.swift
//  SalatySalahy
//
//  Created by Salah on 1/25/20.
//  Copyright © 2020 Salah. All rights reserved.
//

import UIKit

open class DownloadManager: NSObject {
    open var items:[FileDownloadService]=[FileDownloadService]();
    public static let shared: DownloadManager = { DownloadManager()} ()
    var downloadIndex:Int?;
    public override init() {
        super.init()
       
    }
    open func terminate(){
        for downloadService in items{
            if downloadService.state == .running{
                downloadService.cancel(byProducingResumeData:nil);
            }
        }
    }
    open func addfileService(featureName:String?=Download.defaultFeatureName,_ url:URL?,localFile:FileDownloadService.LocalFile)->FileDownloadService?{
        if let url :URL = url{
            var fileDownloadService:FileDownloadService? = self.items.first(where: { (item) -> Bool in
                return item.url==url
            })
            if fileDownloadService == nil {
            fileDownloadService = FileDownloadService.init(url: url,.background);
            fileDownloadService?.featureName=featureName
            self.items.append(fileDownloadService!);
            }
            fileDownloadService?.localFile = localFile
            return fileDownloadService;
        }
        return nil;
    }
    open func fileService(featureName:String?=Download.defaultFeatureName,_ remoteUrl:URL?)->FileDownloadService?{
        if let remoteUrl :URL = remoteUrl{
            let fileDownloadService:FileDownloadService? = self.items.first(where: { (item) -> Bool in
                return item.url==remoteUrl && item.featureName==featureName
            })
            return fileDownloadService;
        }
        return nil
    }
    func downloadAll(){
        self.items.first?.resume();
        downloadIndex = 0
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadManager.finish(_:)), name:Notification.Name.DidFinishDownloadingTo, object: nil)

    }
    @objc func finish(_ notification:NSNotification){
        if let notification:FileDownloadService=notification.object as? FileDownloadService{
            if let downloadIndex:Int = self.downloadIndex{
                if  (downloadIndex+1) < self.items.count{
                    self.downloadIndex = downloadIndex+1
                    self.items[downloadIndex].resume();
                }
            }
        }
    }
}
