//
//  ViewController.swift
//  AssetManagerExample
//
//  Created by Salah on 3/15/19.
//  Copyright © 2019 Salah. All rights reserved.
//

import UIKit
import DownloadKit
class ViewController: UIViewController {
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnResume: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var sliderView: UISlider!
    @IBOutlet weak var lblContentLength: UILabel!
    @IBOutlet weak var lblBufferLength: UILabel!
    
    var downloadService:DownloadService?
    override func viewDidLoad() {
        super.viewDidLoad()
       downloadService =  DownloadService.init(url: URL.init(string:"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!)
        downloadService?.didReceive(didReceive: {
            self.sliderView.value  = self.downloadService?.percentageDownloaded ?? 0;
            self.lblBufferLength.text = "\(self.downloadService?.bufferLength ?? 0)";
            self.lblContentLength.text = "\(self.downloadService?.contentLength ?? 0)";

        })
        downloadService?.completeWithError(completeWithError: {
            print("error to download");
        })
        downloadService?.completeReceive(completeReceive: {
            print("completeReceive");
        })

    }

    @IBAction func btnStart(_ sender: Any) {
        downloadService?.resume();
    }
    
    @IBAction func btnResume(_ sender: Any) {
        downloadService?.resume();
    }
    @IBAction func btnStop(_ sender: Any) {
        downloadService?.cancel(handler: { (data) in
            
        })
        
    }
    @IBAction func btnPause(_ sender: Any) {
        downloadService?.suspend();
    }
}


