//
//  AppConstants.swift
//  ChartsApp
//
//  Created by Andrew Trach on 14.04.2025.
//

import Foundation
import SwiftUI

enum AppConstants {
    // MARK: - Colors
    enum Colors {
        static let primary = Color("Primary")
        static let background = Color.white
        static let secondary = Color.secondary
        static let positive = Color.green
        static let negative = Color.red
        static let handle = Color.gray.opacity(0.5)
        static let divider = Color.gray.opacity(0.2)
        static let darkGreen = Color(hex: "112B20")
        static let white = Color.white
        static let black = Color.black
        static let logoBackground = Color.gray.opacity(0.3)
        static let yellow = Color.yellow
        static let whiteFaded = Color.white.opacity(0.6)
        static let whiteMediumFaded = Color.white.opacity(0.7)
        static let whiteMoreFaded = Color.white.opacity(0.8)
        static let whiteSlight = Color.white.opacity(0.2)
        static let chartGreen = Color(hex: "25C685")
    }
    
    // MARK: - Fonts
    enum Fonts {
        static let title = Font.title
        static let title2 = Font.title2.weight(.bold)
        static let headline = Font.headline
        static let subheadline = Font.subheadline
        static let body = Font.body
        static let largeTitle = Font.largeTitle
        static let caption = Font.caption
        
        static let accountName = Font.headline
        static let accountDescription = Font.subheadline
        static let amount = Font.headline
        static let emptyStateTitle = Font.headline
        static let emptyStateSubtitle = Font.subheadline
        
        // Specific fonts
        static let statisticsTitle = Font.system(size: 17, weight: .medium)
        static let detailsTitle = Font.headline
        static let backButton = Font.system(size: 18, weight: .semibold)
        static let transactionName = Font.system(size: 24, weight: .medium)
        static let transactionDescription = Font.system(size: 17, weight: .regular)
        static let transactionAmount = Font.system(size: 36, weight: .bold)
        
        // Fonts for ChartView
        static let balanceMain = Font.system(size: 48, weight: .medium)
        static let balanceDecimal = Font.system(size: 24, weight: .medium)
        static let dateInfo = Font.system(size: 16, weight: .medium)
        static let periodTab = Font.system(size: 16, weight: .medium)
    }
    
    // MARK: - Sizes
    enum Sizes {
        static let cornerRadius: CGFloat = 16
        static let handleHeight: CGFloat = 20
        static let iconSize: CGFloat = 44
        static let handleWidth: CGFloat = 40
        static let handleThickness: CGFloat = 5
        static let logoSize: CGFloat = 80
    
        static let chartHeight: CGFloat = 200
        static let periodTabHeight: CGFloat = 40
        static let progressScale: CGFloat = 1.5

        enum Statistics {
            static let minAccountsHeightMultiplier: CGFloat = 0.45
            static let maxAccountsHeightMultiplier: CGFloat = 0.95
        }
    }
    
    enum Paddings {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let regular: CGFloat = 16
        static let large: CGFloat = 20
        static let extraLarge: CGFloat = 30
        static let xxLarge: CGFloat = 40
        static let horizontal24: CGFloat = 24
        
        static let horizontal = EdgeInsets(
            top: 0,
            leading: regular,
            bottom: 0,
            trailing: regular
        )
        
        static let verticalItem = EdgeInsets(
            top: medium,
            leading: 0,
            bottom: medium,
            trailing: 0
        )
        
        static let headerPadding = EdgeInsets(
            top: small,
            leading: large,
            bottom: medium,
            trailing: large
        )
    }
    
    // MARK: - Animations
    enum Animations {
        static let standard = Animation.spring()
    }
}
