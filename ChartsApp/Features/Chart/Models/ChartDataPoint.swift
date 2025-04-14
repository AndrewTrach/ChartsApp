//
//  ChartDataPoint.swift
//  ChartsApp
//
//  Created by Andrew Trach on 13.04.2025.
//

import Foundation

// Data model for chart points
struct ChartDataPoint: Identifiable, Equatable, Hashable {
    let id = UUID()
    let value: Double
    let date: Date
    var isSelectable: Bool?
}
