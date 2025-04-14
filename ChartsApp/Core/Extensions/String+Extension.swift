//
//  String+Extension.swift
//  ChartsApp
//
//  Created by Andrew Trach on 14.04.2025.
//

import Foundation
import SwiftUI

extension String {
    // Get the first letter of the string
    var firstLetter: String {
        guard let first = self.first else { return "" }
        return String(first)
    }
    
    // Truncate the string to a specified length and add ellipsis at the end
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            let endIndex = self.index(self.startIndex, offsetBy: length)
            return String(self[..<endIndex]) + trailing
        }
        return self
    }
    
    // Convert hex color code to UIColor
    func colorFromHex() -> Color {
        let scanner = Scanner(string: self)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000ff) / 255.0
        
        return Color(red: r, green: g, blue: b)
    }
}
