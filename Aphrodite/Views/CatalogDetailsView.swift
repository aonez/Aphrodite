//
//  CatalogDetailsView.swift
//  Aphrodite
//
//  Copyright © 2020 Joey. All rights reserved.
//

import SwiftUI

struct CatalogDetailsView: View {
    
    @Binding var isPresented: Bool
    @State private var searchText : String = ""
    @State private var showExportAlert = false
    @State private var showCompileAlert = false
    
    var catalog: AssetCatalog
    
    var body: some View {
        
        let imageAssets: [Rendition] = catalog.renditions.filter{$0.isImageType || $0.assetType == "Vector" || $0.assetType == "PDF"}
        
        return VStack {
            HStack{
                Text(catalog.name).font(.title).bold()
                Spacer()
                Button(action:{ self.isPresented = false }) {
                    ZStack {
                        Circle().foregroundColor(Color.secondary)
                            .frame(width: 25, height: 25)
                        Image(systemName: "multiply").foregroundColor(.secondary)
                    }
                }
            }.padding([.horizontal, .top]).padding(.horizontal, 2.5)
                .offset(y: 10)
            
            SearchBar(text: $searchText, placeholder: "Search Assets")
                .padding(.horizontal, 10)
            
            List {
                
                VStack(alignment: .leading){
                    HStack {
                        Spacer()
                        Button(action: {
                            self.export()
                        }) {
                            HStack {
                                Image(systemName: "tray.and.arrow.up").font(.callout)
                                Text("Export All")
                            }.padding(.vertical, 7.5).frame(width: 140)
                                .background(Color.blue.opacity(0.25))
                                .foregroundColor(.blue)
                                .cornerRadius(17.5)
                        }.buttonStyle(PlainButtonStyle())
                            .alert(isPresented: $showExportAlert) {
                                Alert(title: Text("Export Completed"), message: Text("Assets are exported to \(docURL)\(catalog.carID)/"), dismissButton: .default(Text("Okay")))
                        }
                        Spacer().frame(width: 25)
                        Button(action: {
                            self.recompile()
                        }) {
                            HStack {
                                Image(systemName: "tray.full").font(.callout)
                                Text("Recompile")
                            }.padding(.vertical, 7.5).frame(width: 140)
                                .background(Color.purple.opacity(0.25))
                                .foregroundColor(.purple)
                                .cornerRadius(17.5)
                        }.buttonStyle(PlainButtonStyle())
                            .alert(isPresented: $showCompileAlert) {
                                Alert(title: Text("Catalog Recompiled"), message: Text("The new Asset Catalog file is saved to \(docURL)\(catalog.carID)/"), dismissButton: .default(Text("Okay")))
                        }
                        Spacer()
                    }.padding(.vertical, 15)
                }
                
                if (imageAssets.filter{
                    self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased()) || $0.assetName.lowercased().contains(self.searchText.lowercased())
                }.count) > 0 {
                    ForEach(imageAssets.filter {
                        self.searchText.isEmpty ? true : $0.name.lowercased().contains(self.searchText.lowercased()) || $0.assetName.lowercased().contains(self.searchText.lowercased())
                    }, id: \.self) { rendition in
                        HStack {
                            Spacer()
                            VStack{
                                Image(uiImage: rendition.previewImage ?? UIImage(systemName: "app")!)
                                    .resizable().scaledToFit().frame(width: 72, height: 72)
                                    .padding(.bottom, 3)
                                VStack{
                                    Text(rendition.assetName)
                                        .font(.caption).padding(.top, 7).padding(.bottom, 2)
                                    Text(rendition.displayName)
                                        .font(.caption).foregroundColor(.secondary)
                                }.padding(.horizontal, 5)
                                    .frame(minWidth: 72)
                                    .overlay(Rectangle()
                                        .frame(height: 1.0, alignment: .bottom)
                                        .foregroundColor(Color.secondary)
                                        , alignment: .top)
                            }.padding(.bottom, 15)
                            Spacer()
                        }
                    }
                }
                
            }
        }
    }
    
    func export() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.catalog.exportAll()
            DispatchQueue.main.async {
                self.showExportAlert = true
            }
        }
    }
    
    func recompile() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.catalog.recompile()
            DispatchQueue.main.async {
                self.showCompileAlert = true
            }
        }
    }
    
}
