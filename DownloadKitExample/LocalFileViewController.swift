//
//  LocalFileViewController.swift
//  AssetManagerExample
//
//  Created by Salah on 3/16/19.
//  Copyright © 2019 Salah. All rights reserved.
//

import UIKit
//import DownloadKit
class LocalFileViewController: UIViewController {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnResume: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var lblContentLength: UILabel!
    @IBOutlet weak var lblBufferLength: UILabel!
    @IBOutlet weak var btnResumDownloadFromLocalFile: UIButton!
    @IBOutlet weak var btnTest: UIButton!
    
    
    var downloadService:FileDownloadService?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4
//        downloadService =  FileDownloadService.init(url: URL.init(string:"http://android.quran.com/data/zips/images_1024.zip")!,.background)
        downloadService =  FileDownloadService.init(url:URL.init(string:"http://android.quran.com/data/zips/images_1024.zip")!, isMainThread: false);

        downloadService?.autoSave=true;
        downloadService?.fileType = "zip";
        downloadService?.folderName = "Quran/Images";
        downloadService?.localefileName = "images_1024";

        downloadService?.didReceive(didReceive: {
            self.sliderView.value  = self.downloadService?.percentageDownloaded ?? 0;
            self.lblBufferLength.text = "\(self.downloadService?.totalBytesWritten ?? 0)";
            self.lblContentLength.text = "\(self.downloadService?.totalBytesExpectedToWrite ?? 0)";
            
        })
        downloadService?.didFinishDownloadingWithError({ (error) in
            print(error);
        })
        downloadService?.didFinishDownloadingTo({ (url) in
            print("completeReceive");

        })
        print(downloadService?.state?.rawValue)
    }
    
    @IBAction func btnStart(_ sender: Any) {
        downloadService?.resume();
        print(downloadService?.state?.rawValue)
    }
    
    @IBAction func btnResume(_ sender: Any) {
        downloadService?.resume();
        print(downloadService?.state?.rawValue)
    }
    @IBAction func btnStop(_ sender: Any) {
        downloadService?.cancel(byProducingResumeData: nil);
        print(self.downloadService?.state?.rawValue)
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            print(self.downloadService?.state?.rawValue)
            print("a a");
        }

    }
    @IBAction func btnPause(_ sender: Any) {
        downloadService?.suspend();
        print(downloadService?.state?.rawValue)
    }
    @IBAction func btnTest(_ sender: Any) {
        if let status:URLSessionTask.State = self.downloadService?.state{
        switch status {
        case .completed:
            print("completed")
            break;
        case .running:
            print("running")
            downloadService?.suspend();
            break;
        case .canceling:
            print("canceling")

            break;
        case .suspended:
            print("suspended")
            downloadService?.resume();

            break;
            
        }
        }
    }
    @IBAction func btnResumDownloadFromLocalFile(_ sender: Any) {
        var remoteUrl = URL.init(string:"https://ia802302.us.archive.org/27/items/Pbtestfilemp4videotestmp4/video_test.mp4")!;
        if let  url = self.downloadService!.localFileUrl {
        var data = try? Data.init(contentsOf:url)
        downloadService?.build(data: data!);
        downloadService?.resume();
        }
        print(downloadService?.state?.rawValue)
    }
}









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

@objcMembers
public class FileDownloadService: NSObject,URLSessionDelegate,URLSessionDownloadDelegate {

    enum FileDownloadServiceError: Error {
        case writeFileError
        case localFileUrlNil
        case remoteFileUrlNil
//       case unknownError
//       case connectionError
//       case invalidCredentials
//       case invalidRequest
//       case notFound
//       case invalidResponse
//       case serverError
       case serverUnavailable
//       case timeOut
//       case unsuppotedURL
    }
    public typealias DidFinishDownloadingTo = ((URL)->Void)
    public typealias DidReceive = (()->Void)
    public typealias DidFinishDownloadingWithError = ((Error?)->Void)

    var autoSave:Bool=true;
    public var totalBytesWritten:Int64=0;
    public var totalBytesExpectedToWrite:Int64=0;
    public var percentageDownloaded:Float{
        return  Float(totalBytesWritten) / Float(totalBytesExpectedToWrite);
    }
    public var didReceive:DidReceive?
    public var didFinishDownloadingTo:DidFinishDownloadingTo?
    public var didFinishDownloadingWithError:DidFinishDownloadingWithError?
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if self.autoSave {
        do {
            let manager = FileManager.default
            if let localFile:URL = self.localFileUrl{
                _ = try? manager.removeItem(at: localFile)
                 try manager.moveItem(at: location, to: localFile)    // move new one there

            }else{
                self.didFinishDownloadingWithError?(FileDownloadServiceError.localFileUrlNil);
            }
        } catch let moveError {
            self.didFinishDownloadingWithError?(FileDownloadServiceError.writeFileError);
            print("\(moveError)")
        }
        }
        NotificationCenter.default.post(name: .DidFinishDownloadingTo, object: nil)

        didFinishDownloadingTo?(location);
    }
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        print(session.allHTTPHeaderFields)
        print(downloadTask.currentRequest?.allHTTPHeaderFields);

        if totalBytesWritten == bytesWritten , totalBytesExpectedToWrite == -1{
            self.didFinishDownloadingWithError?(FileDownloadServiceError.serverUnavailable);
        }else{
            self.totalBytesWritten=totalBytesWritten;
            self.totalBytesExpectedToWrite=totalBytesExpectedToWrite;
            didReceive?();
            NotificationCenter.default.post(name: .DidReceive, object: nil)
        }
    }
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.didFinishDownloadingWithError?(error);
        NotificationCenter.default.post(name: .DidFinishDownloadingWithError, object: nil)

    }
    public var url:URL?
    private var session:URLSession?
    private var dataTask:URLSessionDownloadTask?
    public var isMainThread:Bool = true{
        didSet{
            if isMainThread == false{
                self.backgroundConfig = URLSessionConfiguration.background(withIdentifier: "com.salahmohamed.AssetManager")
                self.backgroundConfig?.isDiscretionary = true
                self.backgroundConfig?.sessionSendsLaunchEvents = true
            }
        }
    }
    private var backgroundConfig:URLSessionConfiguration?
    public var currentConfiguration:URLSessionConfiguration{
        get{
            if self.isMainThread{
                return URLSessionConfiguration.default
            }else{
                return backgroundConfig ?? URLSessionConfiguration.default
            }
        }
    }
    public var state: URLSessionTask.State?{
        return self.dataTask?.state ?? nil;
    }
   public var localFileUrl:URL?{
    if let url:URL = self.url{
        return self.genrateLocalFile(remoteFile:url);
    }else{
        self.didFinishDownloadingWithError?(FileDownloadServiceError.remoteFileUrlNil);
        return nil;
    }
    }
   public var folderName:String="Downloads"
   public var fileType:String?;
   public var localefileName:String?

    public  init(url: URL,isMainThread:Bool) {
    super.init()
    self.isMainThread=isMainThread;
    session = URLSession(configuration:currentConfiguration, delegate:self, delegateQueue: OperationQueue.main)
    self.url = url;
    self.build(url: self.url!);
    
    }
    public init(data: Data) {
        super.init();
        self.build(data: data);
    }
     public func resume() {
    self.dataTask?.resume();
    }
    public func cancel(byProducingResumeData:((Data?)->Void)?) {
        self.dataTask?.cancel(byProducingResumeData: { (data:Data?) in
            if data != nil && self.autoSave == true {
            self.writeFile(data: data!, url: self.url!);
            }
            byProducingResumeData?(data);
        })
    }
     public func suspend() {
        self.dataTask?.suspend();
    }
    public func writeFile(data:Data,url:URL){
        if let fileURL:URL = self.genrateLocalFile(remoteFile:url){
            do {
             try data.write(to: fileURL)
            }catch(_){
                didFinishDownloadingWithError?(FileDownloadServiceError.writeFileError)
            }
        }else{
            self.didFinishDownloadingWithError?(FileDownloadServiceError.localFileUrlNil);
        }
    }
    public func build(data:Data){
        dataTask = session?.downloadTask(withResumeData: data);
        self.url = dataTask?.currentRequest?.url;
    }
    public func build(url:URL){
        let aa = NSURLRequest(url: url) as URLRequest;
        dataTask = session?.downloadTask(with:aa);
        print(aa.allHTTPHeaderFields)
        print(aa.httpBodyStream);

    }
    public func genrateLocalFile(remoteFile:URL)->URL?{
         let tempLocalFolderUrl:URL? = URL.createFolder(folderName:"\(folderName)")
        //  for get file name from self.localefileName or get file name from remote url
        //https://ia802302.us.archive.org/27/items/Pbtestfilemp4videotestmp4/video_test.mp4 -> video_test
        var tempLocalFilename = self.localefileName == nil ? (((remoteFile.lastPathComponent) as NSString).deletingPathExtension as String) : self.localefileName
        if let tempLocalFolderUrl:URL=tempLocalFolderUrl,
            let tempLocalFilename:String=tempLocalFilename,
            let fileType:String=fileType{
             let fileURL:URL = tempLocalFolderUrl.appendingPathComponent(tempLocalFilename).appendingPathExtension("\(fileType)")
             return fileURL;
        }else{
            return nil;
        }
    }
    @discardableResult public func didReceive(didReceive:DidReceive?) -> Self {
        self.didReceive=didReceive;
        return self;
    }
    @discardableResult public func didFinishDownloadingWithError(_ didFinishDownloadingWithError:DidFinishDownloadingWithError?) -> Self {
        self.didFinishDownloadingWithError=didFinishDownloadingWithError;
        return self;
    }
    @discardableResult public func didFinishDownloadingTo(_ didFinishDownloadingTo:DidFinishDownloadingTo?) -> Self {
        self.didFinishDownloadingTo=didFinishDownloadingTo;
        return self;
    }
    
    public func subscrip(_ event:Notification.Name){
        NotificationCenter.default.addObserver(forName: event, object: self, queue: nil) { (notif:Notification) in
            
        }
    }
    deinit {
        self.removeObservers();
    }
    public func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: .DidFinishDownloadingTo, object: nil);
        NotificationCenter.default.removeObserver(self, name: .DidReceive, object: nil);
        NotificationCenter.default.removeObserver(self, name: .DidFinishDownloadingWithError, object: nil);
    }
}
extension FileDownloadService {
    func reStart(){
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
/*
 public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
     
     if totalBytesWritten == bytesWritten , totalBytesExpectedToWrite == -1{
         // server not found the server is expired
         //            self.didFinishDownloadingWithError?(Error.Protocol)
     }else{
         self.totalBytesWritten=totalBytesWritten;
         self.totalBytesExpectedToWrite=totalBytesExpectedToWrite;
         didReceive?();
         NotificationCenter.default.post(name: .DidReceive, object: nil)
     }


 }
 */
