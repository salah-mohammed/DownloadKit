//
//  DownloadKitManager.swift
//  DownloadKit
//
//  Created by SalahMohamed on 24/10/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import UIKit
#if canImport(Realm)
#if canImport(RealmSwift)
import Realm
import RealmSwift
class DownloadKitManager: NSObject {
    typealias RealmObject = ()->Realm
    var realmObject:RealmObject?
    public func realmHandler(realmHandler:@escaping RealmObject){
        self.realmObject=realmHandler;
    }
    public static let shared: DownloadKitManager = { DownloadKitManager()} ()
    override init() {
        super.init()
        
    }
}
#endif
#endif
