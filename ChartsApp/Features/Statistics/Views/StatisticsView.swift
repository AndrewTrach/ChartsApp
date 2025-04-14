//
//  StatisticsView.swift
//  ChartsApp
//
//  Created by Andrew Trach on 13.04.2025.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Statistics Screen
struct StatisticsView: View {
    // MARK: - Properties
    let store: StoreOf<StatisticsFeature>
    
    @State private var isAccountsExpanded: Bool = false
    
    // MARK: - Basic interface structure
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStackStore(
                self.store.scope(
                    state: \.path,
                    action: { .path($0) }
                )
            ) {
                mainContentView(viewStore: viewStore)
                    .ignoresSafeArea(edges: .bottom)
                    .onAppear {
                        viewStore.send(.loadAccounts)
                        viewStore.send(.chart(.periodSelected(.week)))
                    }
            } destination: { state in
                handleDestination(state: state)
            }
        }
    }
    
    // MARK: - Interface components
    private func mainContentView(viewStore: ViewStore<StatisticsFeature.State, StatisticsFeature.Action>) -> some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let minAccountsHeight = screenHeight * AppConstants.Sizes.Statistics.minAccountsHeightMultiplier
            let maxAccountsHeight = screenHeight * AppConstants.Sizes.Statistics.maxAccountsHeightMultiplier
            
            ZStack(alignment: .bottom) {
                AppConstants.Colors.darkGreen
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text("Statistics")
                        .font(AppConstants.Fonts.statisticsTitle)
                        .foregroundColor(AppConstants.Colors.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ChartView(store: store.scope(
                        state: \.chartState,
                        action: StatisticsFeature.Action.chart
                    ))
                    
                    Spacer(minLength: minAccountsHeight)
                }
                .frame(height: screenHeight)
                
                AccountsListView(
                    accounts: viewStore.filteredAccounts,
                    selectedPoint: viewStore.chartState.selectedPoint,
                    dataPoints: viewStore.chartState.dataPoints,
                    selectedPeriod: viewStore.chartState.selectedPeriod,
                    onSelectTransaction: { transaction in
                        viewStore.send(.selectTransaction(transaction))
                    },
                    isExpanded: $isAccountsExpanded
                )
                .frame(height: isAccountsExpanded ? maxAccountsHeight : minAccountsHeight)
            }
        }
    }
    
    @ViewBuilder
    private func handleDestination(state: StatisticsFeature.Path.State) -> some View {
        switch state {
        case .transactionDetails:
            CaseLet(
                /StatisticsFeature.Path.State.transactionDetails,
                action: StatisticsFeature.Path.Action.transactionDetails,
                then: TransactionDetailsView.init(store:)
            )
        }
    }
}


