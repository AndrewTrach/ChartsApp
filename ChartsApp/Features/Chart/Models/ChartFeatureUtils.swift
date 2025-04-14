//
//  ChartFeatureUtils.swift
//  ChartsApp
//
//  Created by Andrew Trach on 14.04.2025.
//

import Foundation

enum ChartFeatureUtils {
    static func filterTransactionsByPeriod(
        _ transactions: [Transaction],
        period: ChartPeriod,
        minDate: Date,
        maxDate: Date
    ) -> [Transaction] {
        let calendar = Calendar.current
        
        switch period {
        case .week:
            // For week, we need to find the last 7 days of available data
            let actualMaxDate = transactions.map { $0.date }.max() ?? maxDate
            
            // Get the date 6 days before the actual last date (to get 7 days total)
            guard let oneWeekBeforeLastDay = calendar.date(byAdding: .day, value: -6, to: actualMaxDate) else {
                return transactions
            }
            
            return transactions.filter { $0.date >= oneWeekBeforeLastDay && $0.date <= actualMaxDate }
            
        case .month:
            // Last month of the last year
            let lastDate = transactions.map { $0.date }.max() ?? maxDate
            let lastMonthComponents = calendar.dateComponents([.year, .month], from: lastDate)
            guard let firstDayOfLastMonth = calendar.date(from: lastMonthComponents) else {
                return transactions
            }
            
            // Find the last day of the last month
            guard let lastDayOfLastMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfLastMonth) else {
                return transactions
            }
            
            return transactions.filter { $0.date >= firstDayOfLastMonth && $0.date <= lastDayOfLastMonth }
            
        case .year:
            // Entire data range - first day of first month to last day of last month
            let firstMonthComponents = calendar.dateComponents([.year, .month], from: minDate)
            guard let firstDayOfFirstMonth = calendar.date(from: firstMonthComponents) else {
                return transactions
            }
            
            let lastMonthComponents = calendar.dateComponents([.year, .month], from: maxDate)
            guard let firstDayOfLastMonth = calendar.date(from: lastMonthComponents),
                  let lastDayOfLastMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfLastMonth) else {
                return transactions
            }
            
            return transactions.filter { $0.date >= firstDayOfFirstMonth && $0.date <= lastDayOfLastMonth }
        }
    }
}
