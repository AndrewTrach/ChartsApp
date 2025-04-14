//
//  StatisticsFeature.swift
//  ChartsApp
//
//  Created by Andrew Trach on 13.04.2025.
//

import ComposableArchitecture
import SwiftUI

struct StatisticsFeature: Reducer {
    struct State: Equatable {
        var chartState = ChartFeature.State()
        var accounts: [Transaction] = []
        var filteredAccounts: [Transaction] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var selectedTransaction: Transaction? = nil
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        case chart(ChartFeature.Action)
        case loadAccounts
        case accountsLoaded([Transaction])
        case loadAccountsFailed(String)
        case setFilteredAccounts([Transaction])
        case selectTransaction(Transaction?)
        case path(StackAction<Path.State, Path.Action>)
        case dismissTransactionDetails
    }
    
    struct Path: Reducer {
        enum State: Equatable {
            case transactionDetails(TransactionDetailsFeature.State)
        }
        
        enum Action: Equatable {
            case transactionDetails(TransactionDetailsFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.transactionDetails, action: /Action.transactionDetails) {
                TransactionDetailsFeature()
            }
        }
    }
    
    @Dependency(\.transactionManager) var transactionManager
    
    var body: some ReducerOf<Self> {
        Scope(state: \.chartState, action: /Action.chart) {
            ChartFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .loadAccounts:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    let result = transactionManager.loadTransactionsFromBundle(fileName: "data")
                    
                    switch result {
                    case .success(let transactions):
                        await send(.accountsLoaded(transactions))
                    case .failure(let error):
                        await send(.loadAccountsFailed(error.localizedDescription))
                    }
                }
                
            case let .accountsLoaded(accounts):
                state.accounts = accounts
                state.isLoading = false
                return .none
                
            case let .loadAccountsFailed(message):
                state.errorMessage = message
                state.isLoading = false
                return .none
                
            case .chart(let chartAction):
                if case .dataPointsLoaded = chartAction,
                   let minDate = state.chartState.minDate,
                   let maxDate = state.chartState.maxDate {
                    
                    let period = state.chartState.selectedPeriod
                    
                    if period == .year {
                        return .run { [accounts = state.accounts] send in
                            let filtered = await Task.detached(priority: .userInitiated) {
                                return ChartFeatureUtils.filterTransactionsByPeriod(
                                    accounts,
                                    period: period,
                                    minDate: minDate,
                                    maxDate: maxDate
                                )
                            }.value
                            
                            await send(.setFilteredAccounts(filtered))
                        }
                    } else {
                        return .run { [accounts = state.accounts] send in
                            let filtered = ChartFeatureUtils.filterTransactionsByPeriod(
                                accounts,
                                period: period,
                                minDate: minDate,
                                maxDate: maxDate
                            )
                            await send(.setFilteredAccounts(filtered))
                        }
                    }
                }
                return .none
                
            case let .setFilteredAccounts(filtered):
                state.filteredAccounts = filtered
                return .none
                
            case let .selectTransaction(transaction):
                state.selectedTransaction = transaction
                
                if let transaction = transaction {
                    state.path.append(.transactionDetails(TransactionDetailsFeature.State(transaction: transaction)))
                }
                
                return .none
                
            case .path(.element(id: _, action: .transactionDetails(.backButtonTapped))):
                return .send(.dismissTransactionDetails)
                
            case .dismissTransactionDetails:
                if !state.path.isEmpty {
                    state.path.removeLast()
                }
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}
