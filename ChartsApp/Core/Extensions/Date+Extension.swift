//
//  Date+Extension.swift
//  ChartsApp
//
//  Created by Andrew Trach on 14.04.2025.
//

import Foundation

extension Date {
    // Get date in format "Monday, Jul 15, 2023"
    func formattedFull() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: self)
    }
    
    // Get date in format "15 July 2023"
    func formattedMedium() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    // Get date and time in format "15 July 2023, 14:30"
    func formattedMediumWithTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    // Format "MMM yyyy" (e.g., "Jul 2023")
    func formattedMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }
}
