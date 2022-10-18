//  BasicDownloadManager.swift
//  DownloadKit
//
//  Created by SalahMohamed on 18/10/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

open class BasicDownloadManager: NSObject {
    open var items:[BasicFileDownloadService]=[BasicFileDownloadService]();
    public static let shared: BasicDownloadManager = { BasicDownloadManager()} ()

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
    open func addfileService(_ url:URL?,localIUrl:URL)->BasicFileDownloadService?{
        if let url :URL = url{
            var fileDownloadService:BasicFileDownloadService? = self.items.first(where: { (item) -> Bool in
                return item.url==url
            })
            if fileDownloadService == nil {
            fileDownloadService = BasicFileDownloadService.init(url: url,.background);
            self.items.append(fileDownloadService!);
            }
            fileDownloadService?.localFileUrl = localIUrl
            return fileDownloadService;
        }
        return nil;
    }
    open func fileService(_ url:URL?)->BasicFileDownloadService?{
        if let url :URL = url{
            let fileDownloadService:BasicFileDownloadService? = self.items.first(where: { (item) -> Bool in
                return item.url==url
            })
            return fileDownloadService;
        }
        return nil
    }
}
