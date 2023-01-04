//
//  CacheManager.swift
//  DownloadKit
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import UIKit
// for resume
//"DownloadsCaches";
public class CacheManager: NSObject {
    var featureName:String
    
    public init(_ featureName:String) {
        self.featureName=featureName;
   }
    
    public func catchUrl(remoteUrl:URL?,locale:FileDownloadService.LocalFile?)->URL?{
        var localUrl:URL?
        if let locale:FileDownloadService.LocalFile = locale {
            switch locale{
            case .url(let url):
                localUrl = url
                break;
            case .downloads(folderName: let folderName, localefileName: let localefileName, fileType: let fileType):
                if let remoteUrl:URL = remoteUrl{
                    localUrl = URL.genrateLocalFile(remoteFile:remoteUrl,featureName,fileType, localefileName)
                }
                break;
            }
        }else{
        }
        if var localUrl:URL = localUrl{
            localUrl=localUrl.appendingPathExtension("txt")
            return localUrl
        }
        return nil
    }
    func write(data:Data,remoteUrl:URL?,locale:FileDownloadService.LocalFile?)->URL?{
        let catchUrl = self.catchUrl(remoteUrl: remoteUrl, locale: locale)
        self.writeFile(data: data, cacheUrl: catchUrl)
        return catchUrl;
    }
    private  func writeFile(data:Data,cacheUrl:URL?){
        if let fileURL:URL = cacheUrl{
            do {
//                try data.write(to: cacheUrl!,options: .atomic)
                try data.bs_64String.write(to: cacheUrl!, atomically: true, encoding:.utf8);
            }catch{
                var a = error;
                print(a);
            }
        }else{
        }
    }
}
