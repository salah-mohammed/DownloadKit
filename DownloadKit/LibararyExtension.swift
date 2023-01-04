import Photos
import AVKit
#if canImport(Realm)
#if canImport(RealmSwift)
import Realm
import RealmSwift
#endif
#endif

extension FileManager {
   internal class func le_writeToFile(fileName:String,fileData:Data,completionHandler:(URL?)->Void){
        do {
            let fm = FileManager.default
            guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Unable to reach the documents folder")
                return
            }
            //fileName=test.mp4
            let localUrl = docUrl.appendingPathComponent(fileName);
            try fileData.write(to: localUrl)
            completionHandler(localUrl)
        } catch  {
            completionHandler(nil)
            print("could not save data")
        }
    }
}
extension PHPhotoLibrary {
    open class func le_creationRequestForAssetFromVideo(atFileURL:URL,completionHandler:@escaping (Bool,AVURLAsset?,Error?)->Void){
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:atFileURL);
        }) { saved, error in
            if saved {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                // After uploading we fetch the PHAsset for most recent video and then get its current location url
                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                    completionHandler(saved,avurlAsset as? AVURLAsset,nil)
                    // This is the URL we need now to access the video from gallery directly.
                })
            }else{
                completionHandler(false,nil,nil)
            }
        }
    }
    
    open class func le_creationRequestForAssetFromVideo(data:Data,completionHandler:@escaping (Bool,AVURLAsset?,Error?)->Void){
        FileManager.le_writeToFile(fileName:"test.mp4", fileData: data) { (atFileURL:URL?) in
            if atFileURL != nil {
                PHPhotoLibrary.le_creationRequestForAssetFromVideo(atFileURL: atFileURL!, completionHandler: { (saved:Bool,avurlasset:AVURLAsset?, error:Error?) in
                    completionHandler(saved,avurlasset,error);
                })
            }else{
                completionHandler(false,nil,nil);
            }
        }
    }
    
    class func le_creationRequestForAssetFromVideo(atRemoteUrl:URL,completionHandler:@escaping (Bool,AVURLAsset?,Error?)->Void)->FileDownloadService?{
        let download = FileDownloadService.init(url: atRemoteUrl);
        PHPhotoLibrary.le_checkPhotoLibraryAuthorization(authorized: {
            download.didFinishDownloadingTo({ (url:URL) in
                PHPhotoLibrary.le_creationRequestForAssetFromVideo(atFileURL:url, completionHandler: { (saved:Bool, avurlasset:AVURLAsset?, error:Error?) in
                    completionHandler(saved,avurlasset,error)
                })
            })
            download.didFinishDownloadingWithError({ (error) in
                completionHandler(false,nil,NSError.init(domain:"failed to get from newtowrk message by salah", code: 0, userInfo: nil));
            })
        }) {
            completionHandler(false,nil,NSError.init(domain:"Photos not allowed to Save In", code: 0, userInfo: nil));
        }
        return download
    }
    
    class func le_checkPhotoLibraryAuthorization(authorized:(()->Void)?,unAuthorized:(()->Void)?){
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            //      getPhotosAndVideos()
            authorized?();
        }else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    //   self.getPhotosAndVideos()
                    authorized?();
                }else {
                    unAuthorized?();
                }
            })
        }
    }
    
}
extension String{
    public func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with:withString, options: .literal, range: nil)
    }
}
extension URL {
    func bs_fileName() -> String {
        return self.deletingPathExtension().lastPathComponent
    }

    func bs_fileExtension() -> String {
        return self.pathExtension
    }
    func equalRemoteUrl(_ url:URL?)->Bool{
            var firstStringUrl = self.absoluteString
            if var secondStringUrl:String = url?.absoluteString{
                let firstUrlPrefix = String(firstStringUrl.prefix(5))
                let secondUrlPrefix = String(secondStringUrl.prefix(5))
                if firstUrlPrefix.lowercased() == "https"{
                }else{
                    firstStringUrl=firstStringUrl.replace(target: String(firstStringUrl.prefix(4)), withString:"https")
                }
                if secondUrlPrefix.lowercased() == "https"{
                }else{
                    secondStringUrl=secondStringUrl.replace(target: String(secondStringUrl.prefix(4)), withString:"https")
                }
               return firstStringUrl == secondStringUrl
            }
            return false;
    }
    // internal Used
    // folder/subfolder/subfolder
     static func createFolder(folderName: String) -> URL? {
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
    // internal Used
    static func genrateLocalFile(remoteFile:URL,_ folderName:String,_ fileType:String?,_ localefileName:String?)->URL?{
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
}
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

public extension Substring{
    var bs_string:String?{
        return String(self);
    }
}

#if canImport(Realm)
#if canImport(RealmSwift)
extension Realm {
    func bs_write(_ handler:@escaping (Realm) -> Void,errorHandler:((NSError) -> Void)?){
        DispatchQueue.main.async {
        autoreleasepool {
        do {
        let realm = self
        if realm.isInWriteTransaction{
            handler(realm);
        }else{
            try realm.write {
                 handler(realm);
             }
        }
        }
        catch let error as NSError {
            errorHandler?(error);
        }
    }
        }
    }
    func bs_write(_ handler:@escaping (Realm) -> Void){
        self.bs_write({ (realm) in
            handler(realm)
        }, errorHandler: { (error) in
        })
      }
}
#endif
#endif
extension Data{
    public var bs_64String:String{
        var token:String = "";
        for i in 0..<self.count {
            token = token + String(format: "%02.2hhx", arguments: [self[i]])
        }
        return token;
    }
}
