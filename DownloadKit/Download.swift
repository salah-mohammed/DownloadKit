//
//  Download.swift
//  DownloadKit
//
//  Created by Salah on 6/16/19.
//  Copyright © 2019 Salah. All rights reserved.
//
import UIKit
#if canImport(Realm)
#if canImport(RealmSwift)
import Realm
import RealmSwift

open class Download: Object {
    open var percentageDownloaded:Float{
        return  Float(recivedBytesCount) / Float(totalBytesCount);
    }
    public enum Status{
    case notDownloaded
    case downloaded
    case downloading
    }
    @objc dynamic open var id:Int = 0
    @objc dynamic open var recivedBytesCount:Int = 0
    @objc dynamic open var totalBytesCount:Int = 0
    @objc dynamic open var url:String="";
    @objc dynamic open var cacheUrl:String="";
    @objc dynamic open var localFileStringUrl:String="";
    @objc dynamic open var featureName:String=AppDownloadManager.defaultFeatureName;
    //
    @objc dynamic open var intObject1:Int=0;
    @objc dynamic open var intObject2:Int=0;
    //
    @objc dynamic open var stringObject1:String="";
    @objc dynamic open var stringObject2:String="";
    //
    @objc dynamic open var doubleObject1:Double=0.0;
    @objc dynamic open var doubleObject2:Double=0.0;
    @objc dynamic open var sessionTask:Int = -1;
    var cacheUrl2:URL?{
        return URL.init(fileURLWithPath: cacheUrl, isDirectory: true, relativeTo: nil);
    }
//    var sessionTaskStatus:URLSessionTask.State?{
//        if sessionTask != -1{
//            return URLSessionTask.State.init(rawValue:sessionTask)
//        }
//        return nil
//    }
   
    open var localFileUrl:URL?{
        return URL(fileURLWithPath:localFileStringUrl);
    }
    
    open var status:Status?{
        if self.totalBytesCount == 0 && recivedBytesCount == 0 {
            return .notDownloaded;
        }else
        if self.totalBytesCount > 0 && recivedBytesCount == 0 {
        return .notDownloaded;
        }else
        if self.totalBytesCount ==  recivedBytesCount{
        return .downloaded;
        }else
        if self.totalBytesCount > 0 && recivedBytesCount > 0 {
        return .downloading;
        }
        return nil;
    }
    open override class func primaryKey() -> String? {
        return "id"
    }
    public static func IncrementaID() -> Int?{
       
        if let realm = AppDownloadManager.realm{
        let RetNext: NSArray = Array(realm.objects(self).sorted(byKeyPath:"id")) as NSArray;
        let last:Download? = RetNext.lastObject as? Download
        if RetNext.count > 0 {
            let valor = last?.id ?? 0;
            
            return  valor + 1
        } else {
            return 1
        }
        }else{return nil}
    }
    public static func download(_ featureName:String?,remoteUrl:String)->Download?{
        var object = AppDownloadManager.realm?.objects(Download.self).filter({ (item) -> Bool in
            return remoteUrl == item.url && (featureName ?? AppDownloadManager.defaultFeatureName) == item.featureName
        }).first;
        if object == nil{
        AppDownloadManager.realm?.bs_write({ (realm) in
        if object == nil,let id:Int = Download.IncrementaID() {
               object = Download();
               object?.id = id
               object?.url = remoteUrl
               object?.featureName = featureName ?? AppDownloadManager.defaultFeatureName
            realm.add(object!, update: .all);
           }
        })
        }
        return object;
    }
    open func update(totalBytesCount:Int,_ recivedBytesCount:Int,handler:((Download)->Void)?){
        AppDownloadManager.realm?.bs_write({ (realm) in
        var object:Download=self
        object.totalBytesCount = totalBytesCount
        object.recivedBytesCount = recivedBytesCount
        realm.add(object, update: .all);
        handler?(object);
        })
    }

    open func update(tempCacheUrl:URL?,handler:((Download)->Void)?){
        AppDownloadManager.realm?.bs_write({ (realm) in
        var object:Download=self
            object.cacheUrl = tempCacheUrl?.path ?? ""
        realm.add(object, update: .all);
        handler?(object);
        })
    }
    open func update(_ localFileUrl:URL,handler:((Download)->Void)?){
        AppDownloadManager.realm?.bs_write({ (realm) in
        var object:Download=self
        object.localFileStringUrl = localFileUrl.path
        realm.add(object, update: .all);
        handler?(object);
        })
    }
//    open func update(_ sessionTask:URLSessionTask.State,handler:((Download)->Void)?){
//        DownloadKitManager.shared.realm?.bs_write({ (realm) in
//        var object:Download=self
//            object.sessionTask = sessionTask.rawValue
//        realm.add(object, update: .all);
//        handler?(object);
//        })
//    }
}
#endif
#endif
