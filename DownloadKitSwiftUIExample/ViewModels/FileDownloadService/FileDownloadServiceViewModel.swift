//
//  FileDownloadServiceViewModel.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//
import Foundation
import DownloadKit
class FileDownloadServiceViewModel:NSObject,ObservableObject{
    var downloadService:FileDownloadService?
    @Published  var progress:Float=0
    @Published  var bufferLength:String?
    @Published  var contentLength:String?

    override init() {
        super.init();
//"https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_30MB.mp4"
        downloadService =  FileDownloadService.init(url:URL.init(string:"https://ia802302.us.archive.org/27/items/Pbtestfilemp4videotestmp4/video_test.mp4")!);
        // MARK: localFile to set the final destination of downloaded file.
        downloadService?.localFile = .downloads(folderName:"Videos/mp4Folder",localefileName:"video_test", fileType:"mp4")
        downloadService?.didReceive(didReceive: {
            self.progress = self.downloadService?.percentageDownloaded ?? 0;
            self.bufferLength = "\(self.downloadService?.totalBytesWritten ?? 0)";
            self.contentLength = "\(self.downloadService?.totalBytesExpectedToWrite ?? 0)";
            
        })
        downloadService?.didFinishDownloadingWithError({ (error) in
            print(error);
        })
        downloadService?.didFinishDownloadingTo({ (url) in
            print("completeReceive");
            
        })
        print(downloadService?.state?.rawValue)
    }
    
    func startAction() {
        downloadService?.resume();
        print(downloadService?.state?.rawValue)
    }
    
    func resumeAction(){
        downloadService?.resume();
        print(downloadService?.state?.rawValue)
    }
    func stopAction() {
        downloadService?.cancel(byProducingResumeData:nil);
        print(self.downloadService?.state?.rawValue)
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            print(self.downloadService?.state?.rawValue)
            print("a a");
        }
        
    }
    func restartAction() {
        self.downloadService?.cancel(byProducingResumeData: nil);
        downloadService?.reStart();
    }
    func pauseAction() {
        downloadService?.suspend();
        print(downloadService?.state?.rawValue)
    }
    func getDownloadStatusAction() {
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
    func resumDownloadFromLocalFileAction() {
        if let  url:URL = self.downloadService?.localFileUrl {
            if var data:Data = try? Data.init(contentsOf:url){
                downloadService?.build(data: data);
                downloadService?.resume();
            }
        }
        print(downloadService?.state?.rawValue)
    }
}
