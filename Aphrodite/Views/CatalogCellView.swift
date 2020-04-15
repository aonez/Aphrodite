//
//  CatalogCellView.swift
//  Aphrodite
//
//  Copyright © 2020 Joey. All rights reserved.
//

import SwiftUI

struct CatalogCellView: View {
    
    @State private var showDetails = false
    
    var catalog: AssetCatalog
    
    var body: some View {
        
        Button(action: {
            self.showDetails.toggle()
        }) {
            HStack {
                Image(uiImage: catalog.renditions.filter{$0.isImageType}.first?.previewImage ?? UIImage(systemName: "app")!)
                    .renderingMode(.original).resizable().scaledToFit()
                    .frame(width: 60, height: 60).cornerRadius(10).padding(.leading, 12.5).padding(.trailing, 17.5).shadow(radius: 5, x: 0, y: 5)
                VStack(alignment: .leading) {
                    Text(catalog.name).font(.headline).padding(.bottom, 3)
                    Text("\(catalog.renditions.count) Renditions").font(.footnote).offset(y: 3)
                }
                Spacer()
            }.sheet(isPresented: self.$showDetails, content: {
                CatalogDetailsView(isPresented: self.$showDetails, catalog: self.catalog)
            })
        }
    }
}

struct CatalogCellView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogCellView(catalog: CatalogModel().AppCARs[8])
    }
}
