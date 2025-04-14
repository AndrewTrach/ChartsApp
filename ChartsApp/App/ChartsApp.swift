//
//  ChartsApp.swift
//  ChartsApp
//
//  Created by Andrew Trach on 12.04.2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct ChartsApp: App {
    var body: some Scene {
        WindowGroup {
            StatisticsView(
                store: Store(
                    initialState: StatisticsFeature.State()
                ) {
                    StatisticsFeature()
                }
            )
            .preferredColorScheme(.light)
        }
    }
}
