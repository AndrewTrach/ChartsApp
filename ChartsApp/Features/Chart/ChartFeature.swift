//
//  ChartFeature.swift
//  ChartsApp
//
//  Created by Andrew Trach on 13.04.2025.
//

import Foundation
import ComposableArchitecture

struct ChartFeature: Reducer {
    struct State: Equatable {
        var dataPoints: [ChartDataPoint] = []
        var selectedPeriod: ChartPeriod = .week
        var selectedPoint: Int? = nil
        var currentBalance: Double = 0.0
        var currentDate: Date = Date()
        var isLoading: Bool = false
        var errorMessage: String? = nil
        
        // Track date range in data
        var minDate: Date? = nil
        var maxDate: Date? = nil
    }
    
    enum Action: Equatable {
        case periodSelected(ChartPeriod)
        case dataPointsLoaded([ChartDataPoint])
        case pointSelected(Int?)
        case loadTransactionsFailed(String)
        case setCurrentBalance(Double)
        case setDataRange(min: Date?, max: Date?)
        case updateCurrentDate(Date)
    }
    
    @Dependency(\.transactionManager) var transactionManager
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .periodSelected(period):
            state.selectedPeriod = period
            state.selectedPoint = nil
            state.isLoading = true
            state.errorMessage = nil
            
            return .run { send in
                // Get data from CSV file
                let result = transactionManager.loadTransactionsFromBundle(fileName: "data")
                
                switch result {
                case .success(let transactions):
                    // First find the date range in the data if not set yet
                    if transactions.isEmpty {
                        await send(.loadTransactionsFailed("No data"))
                        return
                    }
                    
                    // Find min and max date in data
                    let dates = transactions.map { $0.date }
                    let minDate = dates.min() ?? Date()
                    let maxDate = dates.max() ?? Date()
                    
                    // Set date range
                    await send(.setDataRange(min: minDate, max: maxDate))
                    
                    // Filter transactions based on selected period and date range
                    let filteredTransactions = ChartFeatureUtils.filterTransactionsByPeriod(
                        transactions,
                        period: period,
                        minDate: minDate,
                        maxDate: maxDate
                    )
                    
                    // Convert transactions to data points for chart
                    let dataPoints = convertToChartDataPoints(filteredTransactions, period: period, minDate: minDate, maxDate: maxDate)
                    
                    // Calculate total balance for the period
                    let totalBalance = calculateTotalForPeriod(transactions, period: period, minDate: minDate, maxDate: maxDate)
                    
                    await send(.dataPointsLoaded(dataPoints))
                    await send(.setCurrentBalance(totalBalance))
                    
                    // Set appropriate default date based on period
                    let defaultDate = getDefaultDateForPeriod(period, minDate: minDate, maxDate: maxDate)
                    await send(.updateCurrentDate(defaultDate))
                    
                case .failure(let error):
                    await send(.loadTransactionsFailed(error.localizedDescription))
                }
            }
            
        case let .dataPointsLoaded(points):
            state.dataPoints = points
            state.isLoading = false
            
            // Update current date to match the selected point's date if exists
            if let lastIndex = state.selectedPoint, lastIndex < points.count {
                let lastPoint = points[lastIndex]
                return .send(.updateCurrentDate(lastPoint.date))
            }
            
            return .none
            
        case let .pointSelected(index):
            state.selectedPoint = index
            
            // Update current balance and date if a point is selected
            if let index = index, index < state.dataPoints.count {
                let point = state.dataPoints[index]
                // Update the date to match the selected point
                return .merge(
                    .send(.setCurrentBalance(point.value)),
                    .send(.updateCurrentDate(point.date))
                )
            }
            
            return .none
            
        case let .loadTransactionsFailed(message):
            state.errorMessage = message
            state.isLoading = false
            return .none
            
        case let .setCurrentBalance(balance):
            state.currentBalance = balance
            return .none
            
        case let .setDataRange(min: minDate, max: maxDate):
            state.minDate = minDate
            state.maxDate = maxDate
            return .none
            
        case let .updateCurrentDate(date):
            state.currentDate = date
            return .none
        }
    }
    
    // MARK: - Helper Methods
    // Helper method to get default date for different periods
    private func getDefaultDateForPeriod(_ period: ChartPeriod, minDate: Date, maxDate: Date) -> Date {
        let calendar = Calendar.current
        
        switch period {
        case .week:
            // For weekly view, use the actual last date in the data
            return maxDate
            
        case .month, .year:
            // Default value should always be the last day of the last month
            // of the last year available in the data
            let lastMonthComponents = calendar.dateComponents([.year, .month], from: maxDate)
            if let firstDayOfLastMonth = calendar.date(from: lastMonthComponents),
               let lastDayOfLastMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfLastMonth) {
                return lastDayOfLastMonth
            }
            
            return maxDate
        }
    }
    
    // Method to convert transactions to chart points based on period
    private func convertToChartDataPoints(
        _ transactions: [Transaction],
        period: ChartPeriod,
        minDate: Date,
        maxDate: Date
    ) -> [ChartDataPoint] {
        let calendar = Calendar.current
        var dataPoints: [ChartDataPoint] = []
        
        // Визначаємо відповідний часовий інтервал - використовуємо денний інтервал для всіх періодів
        // щоб забезпечити вибір точок по днях
        let dateInterval: Calendar.Component = .day
        
        // Define start and end date for the slice
        let (startDate, endDate) = calculateDateRange(for: period, minDate: minDate, maxDate: maxDate)
        
        // Create array of all dates in the specified range for display on the chart
        var allDates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            allDates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: dateInterval, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        // Group transactions by date
        var groupedByDate: [Date: [Transaction]] = [:]
        for transaction in transactions {
            // Normalize date - include day for all periods
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: transaction.date)
            
            if let normalizedDate = calendar.date(from: dateComponents) {
                var dateTransactions = groupedByDate[normalizedDate] ?? []
                dateTransactions.append(transaction)
                groupedByDate[normalizedDate] = dateTransactions
            }
        }
        
        // Calculate balance for each date
        var cumulativeBalance: Double = 0
        for date in allDates {
            let dateTransactions = groupedByDate[date] ?? []
            let dateTotal = dateTransactions.reduce(0) { $0 + $1.amount }
            cumulativeBalance += dateTotal
            
            dataPoints.append(ChartDataPoint(value: cumulativeBalance, date: date))
        }
        
        return dataPoints
    }
    
    // Helper method to determine date range based on period
    private func calculateDateRange(for period: ChartPeriod, minDate: Date, maxDate: Date) -> (Date, Date) {
        let calendar = Calendar.current
        
        switch period {
        case .week:
            // Use the actual last date from data
            let actualEndDate = maxDate
            
            // Find the date 6 days before the last day (to get 7 days total)
            let oneWeekBeforeLastDay = calendar.date(byAdding: .day, value: -6, to: actualEndDate) ?? actualEndDate
            
            return (oneWeekBeforeLastDay, actualEndDate)
            
        case .month:
            // Last month of the last year
            let lastMonthComponents = calendar.dateComponents([.year, .month], from: maxDate)
            let firstDayOfLastMonth = calendar.date(from: lastMonthComponents) ?? maxDate
            
            // Find the last day of the last month
            let lastDayOfLastMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfLastMonth) ?? maxDate
            
            return (firstDayOfLastMonth, lastDayOfLastMonth)
            
        case .year:
            // Entire data range - from first day of first month to last day of last month
            // Get the first day of the first month of the first year
            let firstYearComponents = calendar.dateComponents([.year, .month], from: minDate)
            let firstDayOfFirstMonth = calendar.date(from: firstYearComponents) ?? minDate
            
            // Get the last day of the last month of the last year
            let lastYearMonthComponents = calendar.dateComponents([.year, .month], from: maxDate)
            guard let firstDayOfLastMonth = calendar.date(from: lastYearMonthComponents),
                  let lastDayOfLastMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfLastMonth) else {
                return (minDate, maxDate)
            }
            
            return (firstDayOfFirstMonth, lastDayOfLastMonth)
        }
    }
    
    // Calculate total balance for period
    private func calculateTotalForPeriod(
        _ transactions: [Transaction],
        period: ChartPeriod,
        minDate: Date,
        maxDate: Date
    ) -> Double {
        let filteredTransactions = ChartFeatureUtils.filterTransactionsByPeriod(transactions, period: period, minDate: minDate, maxDate: maxDate)
        return filteredTransactions.reduce(0) { $0 + $1.amount }
    }
}
