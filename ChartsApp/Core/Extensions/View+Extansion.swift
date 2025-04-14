//
//  View+Extansion.swift
//  ChartsApp
//
//  Created by Andrew Trach on 14.04.2025.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // Add common padding for list items
    func listItemPadding() -> some View {
        self.padding(.horizontal, AppConstants.Paddings.large)
            .padding(.vertical, AppConstants.Paddings.medium)
    }
    
    // Style for headline text
    func headlineStyle() -> some View {
        self.font(AppConstants.Fonts.headline)
            .foregroundColor(.primary)
    }
    
    // Style for subheadline text
    func subheadlineStyle() -> some View {
        self.font(AppConstants.Fonts.subheadline)
            .foregroundColor(.secondary)
    }
    
    // Style for amounts
    func amountStyle(isPositive: Bool) -> some View {
        self.font(AppConstants.Fonts.amount)
            .foregroundColor(isPositive ? AppConstants.Colors.positive : AppConstants.Colors.negative)
    }
}
