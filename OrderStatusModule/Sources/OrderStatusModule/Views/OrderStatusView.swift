//
//  OrderStatusView.swift
//  OrderStatusModule
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI

public struct OrderStatusView: View {
    @StateObject private var viewModel: OrderStatusViewModel
    
    public init(baseURL: String, token: String, role: String) {
        self._viewModel = StateObject(wrappedValue: OrderStatusViewModel(baseURL: baseURL, token: token, role: role))
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                DiagonalBackgroundView()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search Section
                    searchSection
                    
                    // Content
                    contentView
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.loadOrders()
        }
        .onChange(of: viewModel.searchText) { _ in
            viewModel.searchOrders()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            // Title bar
            Rectangle()
                .fill(Color.black)
                .frame(height: 60)
                .overlay(
                    Text(OrderStatusLocalizationHelper.shared.localizedString(for: "screen.title"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            // App bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bag")
                        .foregroundColor(.black)
                    Text(OrderStatusLocalizationHelper.shared.localizedString(for: "app.name"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(OrderStatusLocalizationHelper.shared.localizedString(for: "appbar.my_orders"))
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(
                    OrderStatusLocalizationHelper.shared.localizedString(for: "search.placeholder"),
                    text: $viewModel.searchText
                )
                .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            
            Button(action: {
                viewModel.searchOrders()
            }) {
                Text(OrderStatusLocalizationHelper.shared.localizedString(for: "search.filter"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - Content View
    private var contentView: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.filteredOrders.isEmpty {
                emptyStateView
            } else {
                ordersListView
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(OrderStatusLocalizationHelper.shared.localizedString(for: "loading.orders"))
                .font(.body)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(OrderStatusLocalizationHelper.shared.localizedString(for: "empty.title"))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text(OrderStatusLocalizationHelper.shared.localizedString(for: "empty.message"))
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Orders List View
    private var ordersListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredOrders) { order in
                    OrderCardView(order: order, viewModel: viewModel)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Order Card View
struct OrderCardView: View {
    let order: OrderStatus
    let viewModel: OrderStatusViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Order ID
            Text(OrderStatusLocalizationHelper.shared.localizedString(for: "order.id", arguments: order.orderId))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            // Status
            if let statusType = viewModel.getStatusType(for: order) {
                HStack {
                    Text(OrderStatusLocalizationHelper.shared.localizedString(for: "order.status", arguments: statusType.localizedStatus))
                        .font(.body)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Status Pill
                    Text(statusType.localizedStatus)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.getStatusColor(for: statusType))
                        .cornerRadius(12)
                }
            }
            
            // View Details Button
            Button(action: {
                // TODO: Navigate to order details
            }) {
                Text(OrderStatusLocalizationHelper.shared.localizedString(for: "order.view_details"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Diagonal Background View
struct DiagonalBackgroundView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.teal.opacity(0.3),
                            Color.teal.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .overlay(
                    DiagonalLinesPattern()
                        .opacity(0.2)
                )
                .clipShape(
                    TriangleShape()
                        .rotation(.degrees(45))
                )
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.2),
                            Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.1)
                        ],
                        startPoint: .center,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(
                    TriangleShape()
                        .rotation(.degrees(225))
                )
        }
    }
}

struct DiagonalLinesPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let spacing: CGFloat = 8
                
                for i in stride(from: -width, through: width + height, by: spacing) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i + height, y: height))
                }
            }
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    OrderStatusView(
        baseURL: "http://localhost:8080",
        token: "mock_token",
        role: "user"
    )
}
