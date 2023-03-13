//
//  ListItemsViewModel.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//
import Foundation
import DownloadKit
typealias Action = ()->Void
class ListItemsViewModel:NSObject,ObservableObject{
    @Published  var adLoaded = false
    @Published  var list:[SoundItemViewModel] = [SoundItemViewModel].init()
    @Published  var showDownload = false

    override init() {
        super.init();
        list.append(url(stringUrl:"https://nfcard.online/Salah/Quran/MishariAlAfasi/001.mp3"))
        list.append(url(stringUrl:"https://nfcard.online/Salah/Quran/MishariAlAfasi/002.mp3"))
        list.append(url(stringUrl:"https://nfcard.online/Salah/Quran/MishariAlAfasi/003.mp3"))
        list.append(url(stringUrl:"https://nfcard.online/Salah/Quran/MishariAlAfasi/004.mp3"))
        list.append(url(stringUrl:"https://nfcard.online/Salah/Quran/MishariAlAfasi/005.mp3"))
        list.append(url(stringUrl:"https://nfcard.online/Salah/Quran/MishariAlAfasi/006.mp3"))
        list.append(url(stringUrl:"https://nfcard.online/Salah/Quran/MishariAlAfasi/007.mp3"))
        list.append(url(stringUrl:"https://nfcard.online/Salah/Quran/MishariAlAfasi/008.mp3"))
        list.append(url(stringUrl:"https://nfcard.online/Salah/Quran/MishariAlAfasi/009.mp3"))

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
    func cellAction(_ quranItemViewModel:SoundItemViewModel)->Action{
        let action:Action = {
        };
        return action;
    }
    
}
