//
//  ChartView.swift
//  ChartsApp
//
//  Created by Andrew Trach on 13.04.2025.
//

import SwiftUI
import ComposableArchitecture

struct ChartView: View {
    
    // MARK: - Properties
    let store: StoreOf<ChartFeature>
    
    // MARK: - Basic interface structure
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                balanceView(balance: viewStore.currentBalance)
                
                Text(viewStore.currentDate.formattedFull())
                    .font(AppConstants.Fonts.dateInfo)
                    .foregroundColor(AppConstants.Colors.whiteMediumFaded)
                    .padding(.bottom, AppConstants.Paddings.large)
                
                chartContentView(viewStore: viewStore)
                    .frame(height: AppConstants.Sizes.chartHeight)
                    .padding(.bottom, AppConstants.Paddings.xxLarge)
                
                periodSelectorView(viewStore: viewStore)
                    .padding(.horizontal, AppConstants.Paddings.horizontal24)
                    .padding(.bottom, AppConstants.Paddings.horizontal24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppConstants.Colors.darkGreen)
            .onAppear {
                viewStore.send(.periodSelected(.week))
            }
        }
    }
    
    // MARK: - Interface components
    private func balanceView(balance: Double) -> some View {
        let (integerPart, decimalPart) = balance.formattedAsAmount()
        
        return Group {
            Text("$")
                .font(AppConstants.Fonts.balanceMain)
                .foregroundColor(AppConstants.Colors.whiteFaded) +
            Text(integerPart)
                .font(AppConstants.Fonts.balanceMain)
                .foregroundColor(AppConstants.Colors.white) +
            Text(decimalPart)
                .font(AppConstants.Fonts.balanceDecimal)
                .foregroundColor(AppConstants.Colors.white)
        }
    }
    
    private func chartContentView(viewStore: ViewStore<ChartFeature.State, ChartFeature.Action>) -> some View {
        ZStack {
            if viewStore.isLoading {
                loadingView
            } else if let errorMessage = viewStore.errorMessage {
                errorView(message: errorMessage)
            } else if viewStore.dataPoints.isEmpty {
                emptyDataView
            } else {
                // Swift Charts
                chartView(viewStore: viewStore)
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.white))
            .scaleEffect(AppConstants.Sizes.progressScale)
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(AppConstants.Fonts.largeTitle)
                .foregroundColor(AppConstants.Colors.yellow)
            
            Text(message)
                .foregroundColor(AppConstants.Colors.white)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    
    private var emptyDataView: some View {
        Text("No data")
            .foregroundColor(AppConstants.Colors.whiteMoreFaded)
    }
    
    private func chartView(viewStore: ViewStore<ChartFeature.State, ChartFeature.Action>) -> some View {
        LineChartView(
            dataPoints: viewStore.dataPoints,
            selectedIndex: viewStore.selectedPoint,
            onSelectPoint: { index in
                viewStore.send(.pointSelected(index))
            },
            selectedPeriod: viewStore.selectedPeriod
        )
        .frame(height: AppConstants.Sizes.chartHeight)
    }
    
    private func periodSelectorView(viewStore: ViewStore<ChartFeature.State, ChartFeature.Action>) -> some View {
        HStack(spacing: 0) {
            Spacer()
            
            ForEach(ChartPeriod.allCases, id: \.self) { period in
                periodTabButton(
                    period: period,
                    isSelected: viewStore.selectedPeriod == period,
                    isDisabled: viewStore.isLoading,
                    action: {
                        viewStore.send(.periodSelected(period))
                    }
                )
            }
            
            Spacer()
        }
    }
    
    private func periodTabButton(
        period: ChartPeriod,
        isSelected: Bool,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(period.rawValue)
                .font(AppConstants.Fonts.periodTab)
                .fontWeight(.medium)
                .foregroundColor(AppConstants.Colors.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppConstants.Sizes.periodTabHeight)
                .background(
                    isSelected ?
                    Capsule().fill(AppConstants.Colors.whiteSlight) :
                    Capsule().fill(Color.clear)
                )
        }
        .disabled(isDisabled)
    }
}



