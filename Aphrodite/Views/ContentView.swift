//
//  ContentView.swift
//  Aphrodite
//
//  Copyright © 2020 Joey. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject public var model = CatalogModel()
    
    @State private var searchText : String = ""

    let title: String = "App Asset Catalogs"
    
    var body: some View {
                
        return VStack {
            HStack{
                Text(title).font(.title).bold()
                Spacer()
            }.padding([.horizontal, .top]).padding(.horizontal, 2.5)
                .offset(y: 10)
            SearchBar(text: $searchText, placeholder: "Search Catalogs")
                .padding(.horizontal, 10)
            List {
                ForEach(model.AppCARs.filter {
                    self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased())
                }, id: \.carID) { catalog in
                    CatalogCellView(catalog: catalog)
                    .padding(.vertical, 7.5)
                }
            }
            .padding(.trailing).padding(.horizontal, 2.5)
        }
    }
}
