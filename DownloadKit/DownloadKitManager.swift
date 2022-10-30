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
open class DownloadKitManager: NSObject {
    var realm:Realm?
    public static let shared: DownloadKitManager = { DownloadKitManager()} ()
    override init() {
        super.init()
        var config = Realm.Configuration()
        config.fileURL = config.fileURL?.deletingLastPathComponent().appendingPathComponent("DownloadKit.realm")
            autoreleasepool {
            do {
            self.realm = try? Realm(configuration: config)
            }catch let error as NSError {
        
                }
            }
    }
}
#endif
#endif
