//
//  FileDownloadServiceView.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import Foundation
import SwiftUI
struct FileDownloadServiceView: View {
    @StateObject var viewModel:FileDownloadServiceViewModel=FileDownloadServiceViewModel.init()

  var body: some View {
      VStack(spacing:24){
          VStack{
              HStack{
                  ProgressView(value: viewModel.progress)
                      .progressViewStyle(.linear)
                      .padding()
              }
              HStack{
                  Text(self.viewModel.bufferLength ?? "0")
                  Spacer()
                  Text(self.viewModel.contentLength ?? "0")
              }
          }
          Button.init(action:self.viewModel.resumeAction, label:{Text("Resume")})
          Button.init(action:self.viewModel.startAction, label:{Text("Start")})
          Button.init(action:self.viewModel.stopAction, label:{Text("Stop")})
          Button.init(action:self.viewModel.restartAction, label:{Text("Restart")})
          Button.init(action:self.viewModel.pauseAction, label:{Text("Pause")})
          Button.init(action:self.viewModel.getDownloadStatusAction, label:{Text("Get Download Status")})
          Button.init(action:self.viewModel.resumDownloadFromLocalFileAction, label:{Text("Resum download from local file")})
      }
  }

}
