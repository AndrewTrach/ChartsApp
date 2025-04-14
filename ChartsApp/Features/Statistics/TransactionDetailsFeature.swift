//
//  TransactionDetailsFeature.swift
//  ChartsApp
//
//  Created by Andrew Trach on 14.04.2025.
//

import Foundation
import ComposableArchitecture

struct TransactionDetailsFeature: Reducer {
    struct State: Equatable {
        var transaction: Transaction
    }
    
    enum Action: Equatable {
        case backButtonTapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .backButtonTapped:
            return .none
        }
    }
}
