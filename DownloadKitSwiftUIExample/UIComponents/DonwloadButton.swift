//
//  DonwloadButton.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import Foundation
import SwiftUI
import DownloadKit
#if canImport(RealmSwift)

import RealmSwift
import Realm
struct DonwloadButton: View {
    @State var width:CGFloat=10
    @Binding  var progress: CGFloat
    @Binding  var status: Download.Status?
    @Binding  var fileDownloadService: FileDownloadService?

    var action:() -> Void
    var body: some View {
        ZStack{
            Button.init {
                action();
            } label: {
                switch (status ??  .notDownloaded){
                case .notDownloaded:
                    notDownloadStyle();
                    
                case .downloaded:
                     downloaded();
                    
                case .downloading:
                    let status = fileDownloadService?.state ?? .suspended
                    switch status {
                       case .running:
                        runningStyle();
                       case .suspended:
                        pauseStyle();
                       case .canceling:
                        pauseStyle();
                       case .completed:
                        downloaded();
                       @unknown default:
                        ZStack{}
                       }
               }
            }
        }
    }
    func progresView()->some View{
       let view = ZStack{
            Circle.init()
            .trim(from: 0, to: 1)
            .stroke(lineWidth: 2)
            .foregroundColor(Color("#E4E4E4"))
            .frame(width: width, height: width)

            Circle()
                .trim(from: 0, to:progress)
                .stroke(lineWidth: 2)
                .foregroundColor(Color("CircleProgress.partialTrackColor"))
                .rotationEffect(Angle(degrees: 180))
                .shadow(radius:8)
                .rotationEffect(.degrees(90))
                .frame(width: width, height: width)
        }
        return view;
    }
    
    func pauseStyle()->some View{
        let view = ZStack{
            progresView();
            Image("ic_download").foregroundColor(Color("#514F4F")).frame(width: width, height: width)
        }
        return view;
    }
    func runningStyle()->some View{
        let view = ZStack{
            progresView();
            Image("ic_pauseDownload").foregroundColor(Color("#514F4F"))
        }
        return view
    }
    func notDownloadStyle()->some View{
        let view = ZStack{
            Image("ic_download").foregroundColor(Color("#514F4F")).frame(width: width, height: width)
        }
        return view
    }
    func downloaded()->some View{
       let view = ZStack{
           Circle().foregroundColor(Color.clear).frame(width: width, height: width)
        }
    return view
    }
}
#endif
