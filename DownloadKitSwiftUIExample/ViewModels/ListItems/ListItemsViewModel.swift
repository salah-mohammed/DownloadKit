//
//  ListItemsViewModel.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//
#if canImport(RealmSwift)

import Foundation
import DownloadKit
typealias Action = ()->Void
class ListItemsViewModel:NSObject,ObservableObject{
    @Published  var adLoaded = false
    @Published  var list:[SoundItemViewModel] = [SoundItemViewModel].init()
    @Published  var showDownload = false

    override init() {
        super.init();
        list.append(url(stringUrl:"https://download.ourquraan.com/Mishary_Alafasy/001.mp3"))
        list.append(url(stringUrl:"https://download.ourquraan.com/Mishary_Alafasy/002.mp3"))
        list.append(url(stringUrl:"https://download.ourquraan.com/Mishary_Alafasy/003.mp3"))
        list.append(url(stringUrl:"https://download.ourquraan.com/Mishary_Alafasy/004.mp3"))
        list.append(url(stringUrl:"https://download.ourquraan.com/Mishary_Alafasy/005.mp3"))
        list.append(url(stringUrl:"https://download.ourquraan.com/Mishary_Alafasy/006.mp3"))
        list.append(url(stringUrl:"https://download.ourquraan.com/Mishary_Alafasy/007.mp3"))
        list.append(url(stringUrl:"https://download.ourquraan.com/Mishary_Alafasy/008.mp3"))
        list.append(url(stringUrl:"https://download.ourquraan.com/Mishary_Alafasy/009.mp3"))

    }
    func url(stringUrl:String)->SoundItemViewModel{
        var url = URL.init(string: stringUrl)!
        var downloadConfig = defaultAppDownloadManager.downloadConfig(remoteUrl:url)
        var item = SoundItemViewModel.init(progress: 0, url:url, status:.notDownloaded);
        item.status = downloadConfig.0
        item.progress = downloadConfig.1 ?? 0.0
        defaultAppDownloadManager.addfileService(url, localFile: item.localFile())
        defaultAppDownloadManager.downloadConfig(remoteUrl: url) { status, progress, fileState in
            item.progress=(progress ?? 0.0)
            item.status=status
        }
        self.showDownload = !defaultAppDownloadManager.donwloadAllIsActive
        defaultAppDownloadManager.downloadAllIsActiveHandler = { value in
            self.showDownload = !value
        }
        return item;
    }
    func action()->Action{
        let action:Action = {
        };
        return action;
    }
    func cellAction(_ soundItemViewModel:SoundItemViewModel)->Action{
        let action:Action = {
        };
        return action;
    }
    
}
#endif
