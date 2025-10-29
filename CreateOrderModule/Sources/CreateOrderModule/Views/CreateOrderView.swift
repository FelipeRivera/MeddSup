//
//  CreateOrderView.swift
//  CreateOrderModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

public struct CreateOrderView: View {
    @StateObject private var viewModel: CreateOrderViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var quantities: [UUID: Int] = [:]
    
    private let localizationHelper = CreateOrderLocalizationHelper.shared
    
    public init(viewModel: CreateOrderViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // Product Catalog
                    productCatalogSection
                    
                    // Order Summary
                    if !viewModel.orderItems.isEmpty {
                        orderSummarySection
                    }
                    
                    // Action Buttons
                    actionButtonsSection
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(localizationHelper.localizedString(for: "createorder.title"))
                    .font(.system(size: 18, weight: .semibold))
            }
        }
        .alert("", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(localizationHelper.localizedString(for: "createorder.success"))
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "box.fill")
                    .font(.system(size: 16))
                Text("MeddiSuply")
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Spacer()
            
            Image(systemName: "cart.fill")
                .font(.system(size: 20))
        }
        .padding()
        .background(Color.white)
    }
    
    // MARK: - Product Catalog Section
    private var productCatalogSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localizationHelper.localizedString(for: "createorder.catalog.title"))
                .font(.system(size: 20, weight: .bold))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.products) { product in
                    ProductCard(
                        product: product,
                        quantity: Binding(
                            get: { quantities[product.id] ?? 0 },
                            set: { newValue in
                                quantities[product.id] = newValue
                                viewModel.addProduct(product, quantity: newValue)
                            }
                        ),
                        localizationHelper: localizationHelper
                    )
                }
            }
        }
    }
    
    // MARK: - Order Summary Section
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localizationHelper.localizedString(for: "createorder.summary.title"))
                .font(.system(size: 20, weight: .bold))
            
            VStack(spacing: 8) {
                ForEach(viewModel.orderItems) { item in
                    HStack {
                        Text(item.product.name)
                        Spacer()
                        Text("x\(item.quantity) - $\(String(format: "%.2f", item.totalPrice))")
                    }
                    .font(.system(size: 16))
                }
                
                Divider()
                
                HStack {
                    Text(localizationHelper.localizedString(for: "createorder.total.label"))
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Text("$\(String(format: "%.2f", viewModel.totalPrice))")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                viewModel.modifyOrder()
                quantities.removeAll()
            }) {
                Text(localizationHelper.localizedString(for: "createorder.modify.button"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .disabled(viewModel.orderItems.isEmpty || viewModel.isLoading)
            
            Button(action: {
                Task {
                    await viewModel.confirmOrder()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text(localizationHelper.localizedString(for: "createorder.confirm.button"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(viewModel.orderItems.isEmpty || viewModel.isLoading ? Color.gray : Color.green)
            .cornerRadius(8)
            .disabled(viewModel.orderItems.isEmpty || viewModel.isLoading)
        }
    }
}

// MARK: - Product Card
private struct ProductCard: View {
    let product: Product
    @Binding var quantity: Int
    let localizationHelper: CreateOrderLocalizationHelper
    
    var body: some View {
        VStack(spacing: 12) {
            // Product Image
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "pills.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                )
            
            // Product Name
            Text(product.name)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Product Price
            Text("$\(String(format: "%.2f", product.unitPrice))")
                .font(.system(size: 14, weight: .semibold))
            
            // Quantity Stepper
            VStack(alignment: .leading, spacing: 4) {
                Text(localizationHelper.localizedString(for: "createorder.quantity.label"))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Stepper(
                    value: $quantity,
                    in: 0...999
                ) {
                    Text("\(quantity)")
                        .font(.system(size: 14))
                        .frame(width: 40)
                }
                .labelsHidden()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        CreateOrderView(
            viewModel: CreateOrderViewModel(
                service: CreateOrderService(baseURL: "http://52.55.197.150/api/orders"),
                token: "mock_token"
            )
        )
    }
}

