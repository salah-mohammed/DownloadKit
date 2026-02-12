//
//  DownloadKitSwiftUIExampleApp.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import SwiftUI

@main
struct DownloadKitSwiftUIExampleApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                            Label("Download List", systemImage: "house")
                           }
                FileDownloadServiceView()
                      .tabItem {
                          Label("File Download Service", systemImage: "person")
                      }
                DownloadServiceView()
                      .tabItem {
                          Label("Download Service", systemImage: "person")
                      }
            }
        }
    }
}
