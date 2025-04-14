//
//  CSVTransactionManager.swift
//  ChartsApp
//
//  Created by Andrew Trach on 12.04.2025.
//

import Foundation



/// Protocol defining transaction manager functionality
protocol TransactionManaging {
    /// All loaded transactions
    var transactions: [Transaction] { get }
    
    /// Load transactions from CSV file
    func loadTransactions(from filePath: String) -> Result<[Transaction], Error>
    
    /// Load transactions from CSV file in app bundle
    func loadTransactionsFromBundle(fileName: String) -> Result<[Transaction], Error>
    
    /// Filter transactions by date range
    func filterTransactions(from startDate: Date, to endDate: Date) -> [Transaction]
    
    /// Filter transactions by account
    func filterTransactions(byAccount accountName: String) -> [Transaction]
    
    /// Search transactions by description or account name
    func searchTransactions(query: String) -> [Transaction]
}

/// CSV Error Handling
enum CSVError: Error, LocalizedError {
    case fileNotFound
    case emptyFile
    case invalidHeaders
    case invalidRowFormat(Int)
    case invalidDate(Int, String)
    case invalidAmount(Int, String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "CSV file not found"
        case .emptyFile:
            return "CSV file is empty or contains only headers"
        case .invalidHeaders:
            return "Invalid CSV file headers"
        case .invalidRowFormat(let row):
            return "Invalid format in row \(row)"
        case .invalidDate(let row, let value):
            return "Invalid date format '\(value)' in row \(row)"
        case .invalidAmount(let row, let value):
            return "Invalid amount format '\(value)' in row \(row)"
        }
    }
}

/// Implementation of TransactionManaging protocol for CSV files
class CSVTransactionManager: TransactionManaging {
    
    // MARK: - Properties
    
    private(set) var transactions: [Transaction] = []
    private let dateFormatter = DateFormatter()
    
    // MARK: - Initialization
    
    init(dateFormat: String = "yyyy-MM-dd") {
        dateFormatter.dateFormat = dateFormat
    }
    
    // MARK: - TransactionManaging Protocol Implementation
    
    func loadTransactions(from filePath: String) -> Result<[Transaction], Error> {
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            return parseCSV(content)
        } catch {
            return .failure(error)
        }
    }
    
    func loadTransactionsFromBundle(fileName: String) -> Result<[Transaction], Error> {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
            return .failure(CSVError.fileNotFound)
        }
        
        return loadTransactions(from: path)
    }
    
    func filterTransactions(from startDate: Date, to endDate: Date) -> [Transaction] {
        return transactions.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    func filterTransactions(byAccount accountName: String) -> [Transaction] {
        return transactions.filter { $0.accountName == accountName }
    }
    
    func searchTransactions(query: String) -> [Transaction] {
        let lowercasedQuery = query.lowercased()
        return transactions.filter {
            $0.description.lowercased().contains(lowercasedQuery) ||
            $0.accountName.lowercased().contains(lowercasedQuery)
        }
    }
    
    // MARK: - Private Methods
    /// Parse CSV content
    private func parseCSV(_ content: String) -> Result<[Transaction], Error> {
        var parsedTransactions: [Transaction] = []
        
        // Split content into rows
        var rows = content.components(separatedBy: .newlines)
        
        // Check header existence and remove it
        guard rows.count > 1 else {
            return .failure(CSVError.emptyFile)
        }
        
        // Check headers
        let headers = rows.removeFirst().components(separatedBy: ",")
        let expectedHeaders = ["id", "date", "account_name", "description", "amount"]
        
        guard headers.count == expectedHeaders.count,
              zip(headers, expectedHeaders).allSatisfy({ $0.lowercased() == $1 }) else {
            return .failure(CSVError.invalidHeaders)
        }
        
        // Process data rows
        for (rowIndex, row) in rows.enumerated() {
            // Skip empty rows
            if row.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            // Advanced parsing that handles quotes and commas inside fields
            var columns: [String] = []
            var currentColumn = ""
            var insideQuotes = false
            
            for char in row {
                if char == "\"" {
                    insideQuotes.toggle()
                } else if char == "," && !insideQuotes {
                    columns.append(currentColumn)
                    currentColumn = ""
                } else {
                    currentColumn.append(char)
                }
            }
            columns.append(currentColumn) // Add the last column
            
            // Check correct number of columns
            guard columns.count == 5 else {
                return .failure(CSVError.invalidRowFormat(rowIndex + 1))
            }
            
            // Parse data
            let id = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let date = dateFormatter.date(from: columns[1].trimmingCharacters(in: .whitespacesAndNewlines)) else {
                return .failure(CSVError.invalidDate(rowIndex + 1, columns[1]))
            }
            
            let accountName = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let description = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let amount = Double(columns[4].trimmingCharacters(in: .whitespacesAndNewlines)) else {
                return .failure(CSVError.invalidAmount(rowIndex + 1, columns[4]))
            }
            
            // Create transaction
            let transaction = Transaction(
                id: id,
                date: date,
                accountName: accountName,
                description: description,
                amount: amount
            )
            
            parsedTransactions.append(transaction)
        }
        
        // Save parsed transactions
        transactions = parsedTransactions
        
        return .success(parsedTransactions)
    }
}
