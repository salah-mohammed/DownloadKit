/*
 //
 //  DownloadService.swift
 //  AssetManager
 //
 //  Created by Salah on 3/15/19.
 //  Copyright © 2019 Salah. All rights reserved.
 //
 
 import UIKit
 
 open class DownloadService: NSObject,URLSessionDelegate,URLSessionDownloadDelegate {
 public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
 print("URLSessionDownloadDelegate")
 }
 public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
 print("didWriteData");
 }
 open var didReceive:(()->Void)?
 open var completeReceive:(()->Void)?
 open var completeWithError:(()->Void)?
 open var stateHandler:StateHandler?
 
 public typealias StateHandler = (URLSessionDataTask.State?)->Void
 
 open var buffer:NSMutableData = NSMutableData()
 open var percentageDownloaded:Float{
 return  Float(bufferLength) / Float(contentLength);
 }
 open var contentLength = 0
 open var bufferLength:Int{
 return buffer.length
 }
 open var session:URLSession?
 open var dataTask:URLSessionDownloadTask?
 var url:URL?
 fileprivate func setAllObserver (){
 self.addObserver(self, forKeyPath:"status", options:[], context: nil);
 }
 open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
 contentLength = Int(response.expectedContentLength)
 completionHandler(URLSession.ResponseDisposition.allow)
 }
 open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
 buffer.append(data)
 didReceive?();
 }
 open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
 if error == nil {
 completeReceive?();
 }else{
 self.completeWithError?();
 }
 }
 public init(url:URL) {
 super.init()
 self.url = url;
 self.build(url: self.url!);
 }
 public init(data:Data,url:URL) {
 super.init()
 self.build(data: data, url: url);
 }
 public func build(url:URL){
 session = URLSession(configuration:  URLSessionConfiguration.default, delegate:self, delegateQueue: OperationQueue.main)
 dataTask = session?.downloadTask(with:NSURLRequest(url: url) as URLRequest);
 //session?.dataTask(with: NSURLRequest(url: url) as URLRequest)
 self.buffer = NSMutableData();
 self.setAllObserver()
 
 }
 public func build(data:Data,url:URL){
 session = URLSession(configuration:  URLSessionConfiguration.default, delegate:self, delegateQueue: OperationQueue.main)
 dataTask = session?.downloadTask(withResumeData: data);
 self.buffer = NSMutableData();
 self.buffer.append(data);
 self.setAllObserver()
 
 }
 
 override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
 if keyPath == "status"{
 self.stateHandler?(self.dataTask?.state);
 }
 }
 @discardableResult open func didReceive(didReceive:(()->Void)?) -> Self {
 self.didReceive=didReceive;
 return self;
 }
 @discardableResult open func completeWithError(completeWithError:(()->Void)?) -> Self {
 self.completeWithError=completeWithError;
 return self;
 }
 @discardableResult open func completeReceive(completeReceive:(()->Void)?) -> Self {
 self.completeReceive=completeReceive;
 return self;
 }
 @discardableResult open func stateHandler(stateHandler:@escaping StateHandler) -> Self {
 self.stateHandler = stateHandler;
 return self;
 }
 open func resume(){
 if self.dataTask?.state == .completed{
 self.build(url: self.url!)
 self.dataTask?.resume();
 }else{
 self.dataTask?.resume();
 }
 }
 open func suspend(){
 self.dataTask?.suspend();
 }
 // return bufferData
 open func cancel(handler:((Data)->Void)?){
 self.dataTask?.cancel();
 handler?(self.buffer as Data);
 self.build(url: self.url!)
 didReceive?();
 }
 }
 

 */
