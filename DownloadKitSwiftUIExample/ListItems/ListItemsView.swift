//
//  ListItemView.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import Foundation
import SwiftUI
struct ListItemView: View {
    @State var viewModel:ListItemsViewModel
    @StateObject var rowViewModel:SoundItemViewModel{
        didSet{
        }
    }

  var body: some View {
      Button.init(action: self.viewModel.cellAction(rowViewModel)) {
          VStack(spacing:7){
          HStack(spacing:5){
              Text(rowViewModel.url?.absoluteString ?? "").foregroundColor(Color.white)
              .foregroundColor(Color("BlackText"))
              .font(.system(size:16,weight:.regular))
              Spacer()
              DonwloadButton.init(width: 35, progress:$rowViewModel.progress,status:$rowViewModel.status,fileDownloadService:$rowViewModel.fileDownloadService, action:self.rowViewModel.donwload(object: self.rowViewModel))
          }
              Rectangle.init().frame(height: 1).foregroundColor(Color("#E8E8E8"))
          }
      }
  }

}
