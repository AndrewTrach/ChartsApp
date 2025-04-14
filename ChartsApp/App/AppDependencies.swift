//
//  AppDependencies.swift
//  ChartsApp
//
//  Created by Andrew Trach on 13.04.2025.
//

import Foundation
import ComposableArchitecture

private enum TransactionManagerKey: DependencyKey {
    static let liveValue: TransactionManaging = CSVTransactionManager()
}

extension DependencyValues {
    var transactionManager: TransactionManaging {
        get { self[TransactionManagerKey.self] }
        set { self[TransactionManagerKey.self] = newValue }
    }
}
