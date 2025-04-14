//
//  Double+Extansion.swift
//  ChartsApp
//
//  Created by Andrew Trach on 14.04.2025.
//

import Foundation

extension Double {
    // Format large numbers (integer part) with comma separators
    func formattedAsLargeNumber() -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        
        let formattedInteger = formatter.string(from: NSNumber(value: Int(self))) ?? "0"
        return formattedInteger
    }
    
    // Format only the decimal part of the number
    func formattedAsDecimal() -> String {
        let decimalPart = abs(self.truncatingRemainder(dividingBy: 1))
        if decimalPart == 0 {
            return ""
        }
        let decimal = String(format: ".%02d", Int(decimalPart * 100))
        return decimal
    }
    
    // Full amount formatting with separation of integer and decimal parts
    func formattedAsAmount() -> (integerPart: String, decimalPart: String) {
        return (self.formattedAsLargeNumber(), self.formattedAsDecimal())
    }
}
