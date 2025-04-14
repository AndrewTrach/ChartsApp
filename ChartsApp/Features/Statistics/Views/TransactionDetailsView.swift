//
//  TransactionDetailsView.swift
//  ChartsApp
//
//  Created by Andrew Trach on 14.04.2025.
//

import ComposableArchitecture
import SwiftUI
import Foundation
import SwiftUI
import ComposableArchitecture

struct TransactionDetailsView: View {
    // MARK: - Properties
    let store: StoreOf<TransactionDetailsFeature>
    
    // MARK: - Basic interface structure
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: AppConstants.Paddings.large) {
                logoView
                
                transactionInfoView(viewStore: viewStore)
                
                Text(viewStore.transaction.formattedAmount())
                    .font(AppConstants.Fonts.transactionAmount)
                    .foregroundColor(AppConstants.Colors.black)
                
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton(viewStore: viewStore)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Details")
                        .font(AppConstants.Fonts.detailsTitle)
                        .foregroundColor(AppConstants.Colors.black)
                }
            }
        }
    }
    
    // MARK: - Interface components
    private var logoView: some View {
        Circle()
            .fill(AppConstants.Colors.logoBackground)
            .frame(width: AppConstants.Sizes.logoSize, height: AppConstants.Sizes.logoSize)
            .overlay(
                Text("LOGO")
                    .font(AppConstants.Fonts.subheadline)
                    .foregroundColor(AppConstants.Colors.white)
            )
            .padding(.top, AppConstants.Paddings.large)
    }
    
    private func transactionInfoView(viewStore: ViewStore<TransactionDetailsFeature.State, TransactionDetailsFeature.Action>) -> some View {
        VStack(spacing: AppConstants.Paddings.small) {
            Text(viewStore.transaction.accountName)
                .font(AppConstants.Fonts.transactionName)
                .foregroundColor(AppConstants.Colors.black)
            
            Text(viewStore.transaction.description)
                .font(AppConstants.Fonts.transactionDescription)
                .foregroundColor(AppConstants.Colors.secondary)
        }
    }
    
    private func backButton(viewStore: ViewStore<TransactionDetailsFeature.State, TransactionDetailsFeature.Action>) -> some View {
        Button(action: {
            viewStore.send(.backButtonTapped)
        }) {
            Image(systemName: "chevron.left")
                .font(AppConstants.Fonts.backButton)
                .foregroundColor(AppConstants.Colors.black)
        }
    }
}

