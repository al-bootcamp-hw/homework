//
//  ProductDetails.swift
//  SwiftUIViews
//
//  Created by user302959 on 9/8/26.
//

import SwiftUI

struct ProductDetails: View {
    var product: Product
    
    var body: some View {
        
        VStack {
            Text("Product #\(product.id)")
                .font(.largeTitle).font(.largeTitle)
                .fontWeight(.bold)
            Text("Name: \(product.name)")
                .font(Font.title)
                .textFieldStyle(.roundedBorder)
                .padding(20)
            Text("Product Number: \(product.productNumber)")
                .font(Font.title)
                .textFieldStyle(.roundedBorder)
                .padding(20)
            Text("Color: \(product.color)")
                .font(Font.title)
                .textFieldStyle(.roundedBorder)
                .padding(20)
            Text("List Price: $\(String(format: "%.2f", product.listPrice))")
                .font(Font.title)
                .textFieldStyle(.roundedBorder)
                .padding(20)
        }
    }
}
