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
    var featureName:String?
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
                return self.genrateLocalFile(remoteFile:url,self.folderName(folderName),fileType,localefileName);
            default:
                self.finishWithError(error: FileDownloadServiceError.localFileUrlNil)
            }
            
        }
       self.finishWithError(error: FileDownloadServiceError.remoteFileUrlNil)
       return nil;
    }

    
    open func genrateLocalFile(remoteFile:URL,_ folderName:String,_ fileType:String?,_ localefileName:String?)->URL?{
         let tempLocalFolderUrl:URL? = URL.createFolder(folderName:"\(folderName)")
        //  for get file name from self.localefileName or get file name from remote url
        //https://ia802302.us.archive.org/27/items/Pbtestfilemp4videotestmp4/video_test.mp4 -> video_test
        var tempLocalFilename = localefileName == nil ? (((remoteFile.lastPathComponent) as NSString).deletingPathExtension as String) : localefileName
        if let tempLocalFolderUrl:URL=tempLocalFolderUrl,
            let tempLocalFilename:String=tempLocalFilename,
            let fileType:String=fileType{
             let fileURL:URL = tempLocalFolderUrl.appendingPathComponent(tempLocalFilename).appendingPathExtension("\(fileType)")
             return fileURL;
        }else{
            return nil;
        }
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

extension URL {
    // folder/subfolder/subfolder
    internal static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            var folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
}
