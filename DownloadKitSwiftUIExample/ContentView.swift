//
//  ContentView.swift
//  DownloadKitSwiftUIExample
//
//  Created by SalahMohamed on 30/12/2022.
//  Copyright © 2022 Salah. All rights reserved.
//

import SwiftUI
import DownloadKit
struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

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
                QuranItemView.init(viewModel: viewModel, rowViewModel: item)
            }
            }
            .listStyle(PlainListStyle())

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
