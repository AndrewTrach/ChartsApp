//
//  Transaction.swift
//  ChartsApp
//
//  Created by Andrew Trach on 14.04.2025.
//

import SwiftUI

/// Transaction model that matches CSV file structure
struct Transaction: Identifiable, Equatable {
    let id: String
    let date: Date
    let accountName: String
    let description: String
    let amount: Double
    
    // Formatted date for display
    func formattedDate(format: String = "dd.MM.yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

extension Transaction {
    // Returns the formatted amount
    func formattedAmount() -> String {
          let formatter = NumberFormatter()
          formatter.numberStyle = .currency
          formatter.currencySymbol = "$"
          formatter.usesGroupingSeparator = true
          formatter.groupingSeparator = ","
          formatter.groupingSize = 3
          formatter.minimumFractionDigits = 0
          formatter.maximumFractionDigits = 2
          return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
      }
    
    // Returns the formatted transaction date
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Returns full date and time information
    func formattedFullDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
