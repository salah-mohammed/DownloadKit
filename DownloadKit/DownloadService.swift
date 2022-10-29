//
//  DownloadService.swift
//  AssetManager
//
//  Created by Salah on 3/15/19.
//  Copyright © 2019 Salah. All rights reserved.
//

import UIKit

open class DownloadService: NSObject,URLSessionDelegate,URLSessionDataDelegate {
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
    open var dataTask:URLSessionDataTask?
    open var url:URL?
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
    public func build(url:URL){
        session = URLSession(configuration:  URLSessionConfiguration.default, delegate:self, delegateQueue: OperationQueue.main)
        dataTask = session?.dataTask(with: NSURLRequest(url: url) as URLRequest);
        self.buffer = NSMutableData();
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
        self.dataTask?.resume();
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
extension DownloadService {
    func reStart(){
        self.build(url: self.url!)
        self.resume();
    }
}

