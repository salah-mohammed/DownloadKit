//
//  FileDonwloadService.swift
//  AssetManager
//
//  Created by Salah on 3/16/19.
//  Copyright © 2019 Salah. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let DidFinishDownloadingTo = Notification.Name("DidFinishDownloadingTo")
    static let DidReceive = Notification.Name("DidReceive")
    static let DidFinishDownloadingWithError = Notification.Name("DidFinishDownloadingWithError")

}
public let DownloadKitDefaultFolderName = "Downloads"

open class FileDownloadService:ParentFileDownloadService{
//    var featureName:String?
    open var localFileUrl:URL?{
     return internalLocalFileUrl()
    }
    public enum LocalFile{
     case url(URL)
     case downloads(folderName:String?=DownloadKitDefaultFolderName,localefileName:String,fileType:String)
    }
    public var localFile:LocalFile?
    private func folderName(_ folderName:String?)->String{
     return folderName ?? DownloadKitDefaultFolderName
    }
   override func internalLocalFileUrl()->URL?{
        if let url:URL = self.url{
            switch self.localFile{
            case .url(let url):
                return url
            case .downloads(folderName:let folderName,localefileName: let localefileName, fileType: let fileType):
                return URL.genrateLocalFile(remoteFile:url,self.folderName(folderName),fileType,localefileName);
            default:
                self.finishWithError(error: FileDownloadServiceError.localFileUrlNil)
            }
            
        }
       self.finishWithError(error: FileDownloadServiceError.remoteFileUrlNil)
       return nil;
    }

    open override func writeFile(data:Data,url:URL){
        if let fileURL:URL = self.internalLocalFileUrl(){
            do {
             try data.write(to: fileURL)
            }catch(_){
                self.finishWithError(error: FileDownloadServiceError.writeFileError)
            }
        }else{
            self.finishWithError(error: FileDownloadServiceError.localFileUrlNil)
        }
    }
}
 extension ParentFileDownloadService {
     public func reStart(){
        self.build(url: self.url!)
        self.resume();
    }
}

