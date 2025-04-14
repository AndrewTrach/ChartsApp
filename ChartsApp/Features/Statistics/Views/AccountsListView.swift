//
//  AccountsListView.swift
//  ChartsApp
//
//  Created by Andrew Trach on 13.04.2025.
//

import SwiftUI

// MARK: - Accounts List View
struct AccountsListView: View {
    
    // MARK: - Properties
    let accounts: [Transaction]
    let selectedPoint: Int?
    let dataPoints: [ChartDataPoint]
    let selectedPeriod: ChartPeriod
    let onSelectTransaction: (Transaction) -> Void
    @Binding var isExpanded: Bool
    
    // MARK: - Computed properties
    private var filteredAccounts: [Transaction] {
        if let selectedPoint = selectedPoint, selectedPoint < dataPoints.count {
            let selectedDate = dataPoints[selectedPoint].date
            return accounts.filter { $0.date <= selectedDate }
        } else {
            return accounts
        }
    }
    
    // MARK: - Basic interface structure
    var body: some View {
        VStack(spacing: 0) {
            handleView
            headerView
            listContentView
        }
        .background(AppConstants.Colors.background)
        .cornerRadius(AppConstants.Sizes.cornerRadius, corners: [.topLeft, .topRight])
        .animation(AppConstants.Animations.standard, value: isExpanded)
        .gesture(dragGesture)
    }
    
    // MARK: - Interface components
    private var handleView: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .frame(
                width: AppConstants.Sizes.handleWidth,
                height: AppConstants.Sizes.handleThickness
            )
            .foregroundColor(AppConstants.Colors.handle)
            .padding(.vertical, AppConstants.Paddings.small)
            .frame(height: AppConstants.Sizes.handleHeight)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(AppConstants.Animations.standard) {
                    isExpanded.toggle()
                }
            }
    }
    
    private var headerView: some View {
        HStack {
            Text("Accounts")
                .font(AppConstants.Fonts.title2)
            
            Spacer()
        }
        .padding(AppConstants.Paddings.headerPadding)
    }
    
    private var listContentView: some View {
        Group {
            if filteredAccounts.isEmpty {
                emptyStateView
            } else {
                transactionListView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppConstants.Paddings.medium) {
            Image(systemName: "tray")
                .font(AppConstants.Fonts.largeTitle)
                .foregroundColor(AppConstants.Colors.secondary)
                .padding(.top, AppConstants.Paddings.extraLarge)
            
            Text("No transactions for this period")
                .font(AppConstants.Fonts.emptyStateTitle)
                .foregroundColor(AppConstants.Colors.secondary)
            
            Text("Try selecting a different time period")
                .font(AppConstants.Fonts.emptyStateSubtitle)
                .foregroundColor(AppConstants.Colors.secondary.opacity(0.8))
                .padding(.bottom, AppConstants.Paddings.extraLarge)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var transactionListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredAccounts) { transaction in
                    transactionRow(transaction)
                    
                    if transaction.id != filteredAccounts.last?.id {
                        Divider()
                            .padding(.leading, AppConstants.Sizes.iconSize + AppConstants.Paddings.medium)
                    }
                }
            }
            .padding(.bottom, AppConstants.Paddings.extraLarge)
        }
    }
    
    private func transactionRow(_ transaction: Transaction) -> some View {
        Button {
            onSelectTransaction(transaction)
        } label: {
            HStack {
                
                Circle()
                    .fill(AppConstants.Colors.secondary.opacity(0.3))
                    .frame(width: AppConstants.Sizes.iconSize, height: AppConstants.Sizes.iconSize)
                    .overlay(
                        Text(transaction.accountName.firstLetter)
                            .font(AppConstants.Fonts.headline)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.accountName)
                        .headlineStyle()
                    
                    Text(transaction.description)
                        .subheadlineStyle()
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(transaction.formattedAmount())
                    .amountStyle(isPositive: transaction.amount >= 0)
            }
            .listItemPadding()
            .contentShape(Rectangle())
        }
        .buttonStyle(TransactionRowButtonStyle())
    }
    
    // MARK: - DragGesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 50 && isExpanded {
                    withAnimation(AppConstants.Animations.standard) {
                        isExpanded = false
                    }
                }
                else if value.translation.height < -50 && !isExpanded {
                    withAnimation(AppConstants.Animations.standard) {
                        isExpanded = true
                    }
                }
            }
    }
}


