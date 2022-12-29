//
//  ParentFileDownloadService.swift
//  DownloadKit
//
//  Created by SalahMohamed on 03/11/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import UIKit

open class ParentFileDownloadService: NSObject,URLSessionDelegate,URLSessionDownloadDelegate {
   public enum ThreadType{
      case background
      case main
   }
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
   open var totalBytesWritten:Int64=0;
   open var totalBytesExpectedToWrite:Int64=0;
   open var percentageDownloaded:Float{
       return  Float(totalBytesWritten) / Float(totalBytesExpectedToWrite);
   }
   func internalLocalFileUrl()->URL?{
       return nil
   }
   open var didReceive:DidReceive?
   open var didFinishDownloadingTo:DidFinishDownloadingTo?
   open var didFinishDownloadingWithError:DidFinishDownloadingWithError?
   public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
       if self.autoSave {
       do {
           let manager = FileManager.default
           if let localFile:URL = self.internalLocalFileUrl(){
               _ = try? manager.removeItem(at: localFile)
                try manager.moveItem(at: location, to: localFile)    // move new one there
               self.finishSucess(localFile);
           }else{
               self.finishWithError(error: FileDownloadServiceError.localFileUrlNil);
           }
       } catch let moveError {
           self.finishWithError(error: FileDownloadServiceError.writeFileError);
           print("\(moveError)")
       }
       }
   }
    func finishSucess(_ localFile:URL){
        NotificationCenter.default.post(name: .DidFinishDownloadingTo, object: self)
        didFinishDownloadingTo?(localFile);
    }
    func finishWithError(error:Error?){
        NotificationCenter.default.post(name: .DidFinishDownloadingWithError, object: nil)
        self.didFinishDownloadingWithError?(error);
    }
   public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
       if totalBytesWritten == bytesWritten , totalBytesExpectedToWrite == -1{
           self.finishWithError(error: FileDownloadServiceError.serverUnavailable)
       }else{
           self.totalBytesWritten=totalBytesWritten;
           self.totalBytesExpectedToWrite=totalBytesExpectedToWrite;
           didReceive?();
           NotificationCenter.default.post(name: .DidReceive, object: nil)
       }
   }
   public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
       self.finishWithError(error: error ?? nil)
   }
   open var url:URL?
   private var session:URLSession?
   private var dataTask:URLSessionDownloadTask?
   open var threadType:ThreadType = .main{
       didSet{
           if threadType == .background{
               self.backgroundConfig = URLSessionConfiguration.background(withIdentifier: "com.salahmohamed.AssetManager")
               self.backgroundConfig?.isDiscretionary = true
               self.backgroundConfig?.sessionSendsLaunchEvents = true
           }
       }
   }
   private var backgroundConfig:URLSessionConfiguration?
   open var currentConfiguration:URLSessionConfiguration{
       get{
       switch self.threadType{
       case .background:
           return backgroundConfig ?? URLSessionConfiguration.default
       case .main:
       return URLSessionConfiguration.default
       }
       }
   }
   open var state: URLSessionTask.State?{
       return self.dataTask?.state ?? nil;
   }


   public  init(url: URL,_ threadType:ThreadType = .main) {
   super.init()
   self.threadType=threadType;
   session = URLSession(configuration:currentConfiguration, delegate:self, delegateQueue: OperationQueue.main)
   self.url = url;
   self.build(url: self.url!);
   
   }
   public init(data: Data) {
       super.init();
       self.build(data: data);
   }
    open func resume() {
   self.dataTask?.resume();
   }
   open func cancel(byProducingResumeData:((Data?)->Void)?) {
       self.dataTask?.cancel(byProducingResumeData: { (data:Data?) in
//            if data != nil && self.autoSave == true {
//            self.writeFile(data: data!, url: self.url!);
//            }
           byProducingResumeData?(data);
       })
   }
    open func suspend() {
       self.dataTask?.suspend();
   }
   open func writeFile(data:Data,url:URL){
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
   public func build(data:Data){
       dataTask = session?.downloadTask(withResumeData: data);
       self.url = dataTask?.currentRequest?.url;
   }
   public func build(url:URL){
       dataTask = session?.downloadTask(with: NSURLRequest(url: url) as URLRequest);
   }

   @discardableResult open func didReceive(didReceive:DidReceive?) -> Self {
       self.didReceive=didReceive;
       return self;
   }
   @discardableResult open func didFinishDownloadingWithError(_ didFinishDownloadingWithError:DidFinishDownloadingWithError?) -> Self {
       self.didFinishDownloadingWithError=didFinishDownloadingWithError;
       return self;
   }
   @discardableResult open func didFinishDownloadingTo(_ didFinishDownloadingTo:DidFinishDownloadingTo?) -> Self {
       self.didFinishDownloadingTo=didFinishDownloadingTo;
       return self;
   }
   
   open func subscrip(_ event:Notification.Name){
       NotificationCenter.default.addObserver(forName: event, object: self, queue: nil) { (notif:Notification) in
           
       }
   }
   deinit {
       self.removeObservers();
   }
   open func removeObservers(){
       NotificationCenter.default.removeObserver(self, name: .DidFinishDownloadingTo, object: nil);
       NotificationCenter.default.removeObserver(self, name: .DidReceive, object: nil);
       NotificationCenter.default.removeObserver(self, name: .DidFinishDownloadingWithError, object: nil);
   }
}
