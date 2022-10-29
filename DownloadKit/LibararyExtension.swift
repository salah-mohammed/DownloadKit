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
