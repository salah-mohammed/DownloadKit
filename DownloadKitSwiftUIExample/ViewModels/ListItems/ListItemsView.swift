//
//  ListItemsView.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import SwiftUI
import DownloadKit
#if canImport(RealmSwift)

struct ListItemsView: View {
    @StateObject var viewModel = ListItemsViewModel()

    var body: some View {
        ZStack {
            List {
                Section {
                    if viewModel.showDownload{
                        Button.init {
                            defaultAppDownloadManager.downloadAll();
                        } label: {
                            Text("Download All")
                        }
                    }
                }
            ForEach(viewModel.list, id: \.self) { item in
                ListItemView.init(viewModel: viewModel, rowViewModel: item)
            }
            }
            .listStyle(PlainListStyle())

        }
        .padding()
    }
}

struct ListItemsView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemsView()
    }
}
#endif
