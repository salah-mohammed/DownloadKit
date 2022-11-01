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
    open func addfileService(_ url:URL?,localFile:FileDownloadService.LocalFile)->FileDownloadService?{
        if let url :URL = url{
            var fileDownloadService:FileDownloadService? = self.items.first(where: { (item) -> Bool in
                return item.url==url
            })
            if fileDownloadService == nil {
            fileDownloadService = FileDownloadService.init(url: url,.background);
                self.items.append(fileDownloadService!);
            }
            fileDownloadService?.localFile = localFile
            return fileDownloadService;
        }
        return nil;
    }
    open func fileService(_ remoteUrl:URL?)->FileDownloadService?{
        if let remoteUrl :URL = remoteUrl{
            let fileDownloadService:FileDownloadService? = self.items.first(where: { (item) -> Bool in
                return item.url==remoteUrl
            })
            return fileDownloadService;
        }
        return nil
    }
}
