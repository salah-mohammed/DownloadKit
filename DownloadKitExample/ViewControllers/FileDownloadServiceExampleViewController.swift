//
//  FileDownloadServiceExampleViewController.swift
//  AssetManagerExample
//
//  Created by Salah on 3/16/19.
//  Copyright © 2019 Salah. All rights reserved.
//

import UIKit
import DownloadKit
class FileDownloadServiceExampleViewController: UIViewController {
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnResume: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var lblContentLength: UILabel!
    @IBOutlet weak var lblBufferLength: UILabel!
    @IBOutlet weak var btnResumDownloadFromLocalFile: UIButton!
    @IBOutlet weak var btnGetDownloadStatus: UIButton!
    
    
    var downloadService:FileDownloadService?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadService =  FileDownloadService.init(url:URL.init(string:"https://ia802302.us.archive.org/27/items/Pbtestfilemp4videotestmp4/video_test.mp4")!);
        downloadService?.autoSave=true;
        // MARK: localFile to set the final destination of downloaded file.
        downloadService?.localFile = .downloads(folderName:"Videos/mp4Folder",localefileName:"video_test", fileType:"mp4")
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
        downloadService?.cancel(byProducingResumeData:nil);
        print(self.downloadService?.state?.rawValue)
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            print(self.downloadService?.state?.rawValue)
            print("a a");
        }
        
    }
    @IBAction func btnRestart(_ sender: Any) {
        self.downloadService?.cancel(byProducingResumeData: nil);
        downloadService?.reStart();
    }
    @IBAction func btnPause(_ sender: Any) {
        downloadService?.suspend();
        print(downloadService?.state?.rawValue)
    }
    @IBAction func btnGetDownloadStatus(_ sender: Any) {
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
        if let  url:URL = self.downloadService?.localFileUrl {
            if var data:Data = try? Data.init(contentsOf:url){
                downloadService?.build(data: data);
                downloadService?.resume();
            }
        }
        print(downloadService?.state?.rawValue)
    }
}
