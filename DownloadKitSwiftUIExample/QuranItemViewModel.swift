//
//  QuranItemViewModel.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//
import Foundation
import DownloadKit
import SwiftUI
import MediaPlayer

class QuranItemViewModel:NSObject,ObservableObject{
    

  
    func quranUrl()->URL?{
       if let url :URL = self.genrateQuranRemoteUrl(),
           let download = Download.download(remoteUrl:url.absoluteString){
           if download.status == .downloaded{
               // local url
//               return  DownloadManager.shared.fetch(quranItem: self);
               return download.localFileUrl
           }else{
               // remote url
               return url;
           }
       }
       return nil;
   }
    func localFile()->FileDownloadService.LocalFile{
        let localefile = FileDownloadService.LocalFile.downloads(folderName:nil,
                                                                 localefileName:String(self.url?.lastPathComponent.split(separator:".").first ?? ""),
                                                                     fileType:"mp3")
    return localefile
   }

   func genrateQuranRemoteUrl()->URL?{

       return self.url;
   }
    
    @Published var progress:CGFloat=0
    @Published var url:URL?
    @Published var status:Download.Status?
    @Published var fileDownloadService:FileDownloadService?

    
    override init() {
        super.init();
    }
    init(progress:CGFloat,url:URL,status:Download.Status) {
        self.progress=progress
        self.url=url
        self.status=status
    }
    
    func donwload(object:QuranItemViewModel)->Action{
        let action = {
            if let  remoteUrl:URL = object.genrateQuranRemoteUrl(){
                defaultAppDownloadManager.downloadAction(remoteUrl: remoteUrl, localFile: object.localFile()) { status, progressValue, sessionTaskStatus in
                    self.progress = progressValue ?? 0.0
                    self.status = status
                }
            }
        }
        return action;
    }

}
