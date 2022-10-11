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
    public static let sharedInstance: DownloadManager = { DownloadManager()} ()

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
    open func addfileService(_ url:URL?,folderName:String,fileType:String,localefileName:String)->FileDownloadService?{
        if let url :URL = url{
            var fileDownloadService:FileDownloadService? = DownloadManager.sharedInstance.items.first(where: { (item) -> Bool in
                return item.url==url
            })
            if fileDownloadService == nil {
                fileDownloadService = FileDownloadService.init(url: url,.background);
            DownloadManager.sharedInstance.items.append(fileDownloadService!);
            }
            fileDownloadService?.localFile = .downloads(folderName:folderName,localefileName: localefileName, fileType: fileType)
            return fileDownloadService;
        }
        return nil;
    }
    open func fileService(_ url:URL?)->FileDownloadService?{
        if let url :URL = url{
            var fileDownloadService:FileDownloadService? = DownloadManager.sharedInstance.items.first(where: { (item) -> Bool in
                return item.url==url
            })
            return fileDownloadService;
        }
        return nil
    }
}
