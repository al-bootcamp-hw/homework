//
//  ProductList.swift
//  SwiftUIViews
//
//  Created by user302959 on 9/8/26.
//

import SwiftUI

struct ProductList: View {
    @State private var products: [Product] = []
    
    var body: some View {
        NavigationStack {
            List(products) { product in
                NavigationLink("\(product.name) (Color: \(product.color))", value: product)
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self) {
                selectedItem in
                ProductDetails(product: selectedItem)
            }
        }
        .task {
            loadData()
        }
    }
    
    func loadData() {
        products = [
            Product(id: 1, name: "Laptop", productNumber: "001", color: "Blue", listPrice: 599.99),
            Product(id: 2, name: "Smartphone", productNumber: "002", color: "Red", listPrice: 499.99),
            Product(id: 3, name: "Headphones", productNumber: "003", color: "Black", listPrice: 199.99),
        ]
    }
}
