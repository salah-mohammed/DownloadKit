//
//  DownloadServiceViewModel.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//
import Foundation
import DownloadKit
class DownloadServiceViewModel:NSObject,ObservableObject{
    @Published  var progress:Float=0
    @Published  var bufferLength:String?
    @Published  var contentLength:String?
    var downloadService:DownloadService?
    override init() {
        super.init();
        downloadService =  DownloadService.init(url: URL.init(string:"https://ia802302.us.archive.org/27/items/Pbtestfilemp4videotestmp4/video_test.mp4")!)
         downloadService?.didReceive(didReceive: {
             self.progress  = self.downloadService?.percentageDownloaded ?? 0;
             self.bufferLength = "\(self.downloadService?.bufferLength ?? 0)";
             self.contentLength = "\(self.downloadService?.contentLength ?? 0)";

         })
         downloadService?.completeWithError(completeWithError: {
             print("error to download");
         })
         downloadService?.completeReceive(completeReceive: {
             print("completeReceive");
         })
    }
    func startAction() {
        downloadService?.resume();
    }
    
    func resumeAction() {
        downloadService?.resume();
    }
    func stopAction() {
        downloadService?.cancel(handler: { (data) in
            
        })
    }
    func pauseAction() {
        downloadService?.suspend();
    }
}
