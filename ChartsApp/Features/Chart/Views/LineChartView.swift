//
//  LineChartView.swift
//  ChartsApp
//
//  Created by Andrew Trach on 13.04.2025.
//

import SwiftUI
import Charts
import ComposableArchitecture

struct LineChartView: View {
    // MARK: - Properties
    let dataPoints: [ChartDataPoint]
    let selectedIndex: Int?
    let onSelectPoint: (Int?) -> Void
    let selectedPeriod: ChartPeriod
    
    @State private var isDragging: Bool = false
    @State private var chartScale: CGFloat = 1.0
    @State private var chartOffset: CGFloat = 0.0
    @State private var lastDragValue: CGFloat = 0.0
    
    // Scale constraints
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 4.0
    private let quickZoomScale: CGFloat = 5.0
    
    // MARK: - Computed properties
    
    /// Extended set of points with additional points at the edges
    private var expandedDataPoints: [ChartDataPoint] {
        guard !dataPoints.isEmpty else { return [] }
        
        // Take first and last points to create additional ones
        let firstPoint = dataPoints.first!
        let lastPoint = dataPoints.last!
        
        // Create logical continuation into the past (before the first point)
        let daysBefore: Double = selectedPeriod == .week ? 1.0 :
        (selectedPeriod == .month ? 3.0 : 15.0)
        let paddingBeforeDate = Calendar.current.date(
            byAdding: .day,
            value: Int(-daysBefore),
            to: firstPoint.date
        ) ?? firstPoint.date
        let paddingBefore = ChartDataPoint(
            value: firstPoint.value, date: paddingBeforeDate,
            isSelectable: false
        )
        
        // Create logical continuation into the future (after the last point)
        let daysAfter: Double = selectedPeriod == .week ? 1.0 :
        (selectedPeriod == .month ? 3.0 : 15.0)
        let paddingAfterDate = Calendar.current.date(
            byAdding: .day,
            value: Int(daysAfter),
            to: lastPoint.date
        ) ?? lastPoint.date
        let paddingAfter = ChartDataPoint(
            value: lastPoint.value, date: paddingAfterDate,
            isSelectable: false
        )
        
        // Return extended dataset with additional points
        return [paddingBefore] + dataPoints + [paddingAfter]
    }
    
    /// Visible points to display on the chart
    private var visibleDataPoints: [ChartDataPoint] {
        guard selectedPeriod == .year && chartScale > 1.0 else {
            return expandedDataPoints
        }
        
        guard !expandedDataPoints.isEmpty else { return [] }
        
        // Always use standard logic to determine visible area
        let totalPoints = expandedDataPoints.count
        let visiblePointsCount = Int(ceil(CGFloat(totalPoints) / chartScale))
        let normalizedOffset = min(max(chartOffset, 0), 1.0)
        let maxStartIndex = max(0, totalPoints - visiblePointsCount)
        let startIndex = min(Int(normalizedOffset * CGFloat(maxStartIndex)), maxStartIndex)
        let endIndex = min(startIndex + visiblePointsCount, totalPoints)
        
        return Array(expandedDataPoints[startIndex..<endIndex])
    }
    
    /// Data for display on X axis
    private var axisDataPoints: [ChartDataPoint] {
        // Return only real points (without extra edge points)
        return dataPoints
    }
    
    // MARK: - Main view
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let selectedIndex = selectedIndex, selectedIndex < dataPoints.count {
                    selectedIndexChartView(selectedIndex: selectedIndex)
                } else {
                    standardChartView()
                }
            }
            .chartXScale(domain: getDateDomain())
            .chartYScale(domain: getValueDomain())
            .chartXAxis {
                AxisMarks(values: getAxisValues()) { _ in
                    AxisTick(stroke: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .foregroundStyle(AppConstants.Colors.white.opacity(0.5))
                    
                    AxisValueLabel {
                        Color.clear.frame(height: 2)
                    }
                }
            }
            .chartYAxis(.hidden)
            .chartBackground { _ in Color.clear }
            .chartOverlay(content: chartOverlayView)
        }
    }
    
    // MARK: - Chart display functions
    /// Standard chart view when no point is selected
    private func standardChartView() -> some View {
        Chart {
            // Area under the line with gradient
            ForEach(expandedDataPoints) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    yStart: .value("Min", 0),
                    yEnd: .value("Amount", point.value)
                )
                .foregroundStyle(chartAreaGradient())
                .interpolationMethod(.catmullRom)
            }
            
            // Line for all points
            ForEach(visibleDataPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Amount", point.value)
                )
                .foregroundStyle(AppConstants.Colors.chartGreen)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .interpolationMethod(.catmullRom)
            }
        }
    }
    
    /// Chart with selected point
    private func selectedIndexChartView(selectedIndex: Int) -> some View {
        ZStack {
            // Get the selected point
            let selectedPoint = dataPoints[selectedIndex]
            
            // Check if the selected point is visible in the current visible area
            let isSelectedPointVisible = visibleDataPoints.contains {
                $0.date == selectedPoint.date && ($0.isSelectable == nil || $0.isSelectable == true)
            }
            
            // First chart - shows only the part up to the selected point
            Chart {
                // Area under the line
                ForEach(visibleDataPoints) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        yStart: .value("Min", 0),
                        yEnd: .value("Amount", point.value)
                    )
                    .foregroundStyle(chartAreaGradient())
                    .interpolationMethod(.catmullRom)
                }
                
                // Line for the active part
                ForEach(visibleDataPoints.filter { $0.date <= selectedPoint.date }) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Amount", point.value)
                    )
                    .foregroundStyle(AppConstants.Colors.chartGreen)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                }
                
                // Green point for the selected value if it's visible
                if isSelectedPointVisible {
                    PointMark(
                        x: .value("Selected Date", selectedPoint.date),
                        y: .value("Selected Amount", selectedPoint.value)
                    )
                    .foregroundStyle(AppConstants.Colors.chartGreen)
                    .symbolSize(100)
                }
            }
            
            // Second chart - shows the part after the selected point with reduced opacity
            Chart {
                let futurePoints = visibleDataPoints.filter { $0.date >= selectedPoint.date }
                ForEach(futurePoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Amount", point.value)
                    )
                    .foregroundStyle(AppConstants.Colors.chartGreen.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                }
                
                // White vertical line, only if selected point is visible
                if isSelectedPointVisible {
                    RuleMark(
                        x: .value("Selected Date", selectedPoint.date),
                        yStart: .value("Min", getMinDataValue()),
                        yEnd: .value("Amount", selectedPoint.value)
                    )
                    .foregroundStyle(AppConstants.Colors.white)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                }
            }
            .zIndex(10)
        }
    }
    
    /// Overlay for handling user interaction
    @ViewBuilder
    private func chartOverlayView(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { location in
                    handleTapGesture(location: location, proxy: proxy, geometry: geometry)
                }
                .onTapGesture(count: 2) { location in
                    handleDoubleTapGesture(location: location, proxy: proxy, geometry: geometry)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDragGesture(value: value, proxy: proxy, geometry: geometry)
                        }
                        .onEnded { _ in
                            lastDragValue = 0
                            isDragging = false
                        }
                )
        }
    }
    
    // MARK: - Gesture handling
    
    private func handleDoubleTapGesture(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        // Handle double tap only for yearly chart
        guard selectedPeriod == .year, let plotFrame = proxy.plotFrame else { return }
        
        // If already zoomed to maximum, return to normal size
        if chartScale >= quickZoomScale * 0.9 {
            chartScale = minScale
            chartOffset = 0 // Reset offset
            return
        }
        
        // Calculate relative touch position
        let xPosition = location.x - geometry[plotFrame].origin.x
        let relativePosition = xPosition / geometry[plotFrame].width
        
        chartScale = quickZoomScale
        
        // Determine zoom center based on touch point
        if relativePosition < 0.25 {
            chartOffset = 0 // Start of chart
        } else if relativePosition > 0.75 {
            chartOffset = 1.0 // End of chart
        } else {
            // Center at touch point
            chartOffset = relativePosition - 0.25
        }
    }
    
    /// Handle tap gesture for point selection
    private func handleTapGesture(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let xPosition = location.x - geometry[plotFrame].origin.x
        
        // Check if touch is within chart bounds
        if xPosition < 0 || xPosition > geometry[plotFrame].width {
            // Touch outside chart bounds - cancel selection
            onSelectPoint(nil)
            return
        }
        
        // If there's a selected point, check if the touch was on the point itself (pin)
        if let selectedIndex = selectedIndex, selectedIndex < dataPoints.count {
            let selectedPoint = dataPoints[selectedIndex]
            
            // Check if this point is visible
            if visibleDataPoints.contains(where: { $0.date == selectedPoint.date }) {
                // Manual way to determine the point position on the chart
                let visibleStartDate = visibleDataPoints.first?.date ?? Date()
                let visibleEndDate = visibleDataPoints.last?.date ?? Date()
                let timeRange = visibleEndDate.timeIntervalSince(visibleStartDate)
                
                if timeRange > 0 {
                    // Normalize point position relative to visible range
                    let pointTimeFromStart = selectedPoint.date.timeIntervalSince(visibleStartDate)
                    let normalizedPosition = pointTimeFromStart / timeRange
                    
                    // Convert normalized position to screen coordinates
                    let pixelPosition = geometry[plotFrame].minX + normalizedPosition * geometry[plotFrame].width
                    
                    // Define touch area for the point
                    let pinSize: CGFloat = 30 // Increase area for convenience
                    let pinRect = CGRect(x: pixelPosition - pinSize/2,
                                         y: geometry[plotFrame].minY,
                                         width: pinSize,
                                         height: geometry[plotFrame].height)
                    
                    // If tapped on pin area - cancel selection
                    if pinRect.contains(location) {
                        onSelectPoint(nil)
                        return
                    }
                }
            }
        }
        
        // Standard logic for point selection
        if !visibleDataPoints.isEmpty {
            let relativeXPosition = xPosition / geometry[plotFrame].width
            let dataIndex = findClosestPointIndex(at: relativeXPosition)
            
            if dataIndex >= 0 && dataIndex < dataPoints.count {
                // Toggle selection if tapping on same point
                if selectedIndex == dataIndex {
                    onSelectPoint(nil)
                } else {
                    onSelectPoint(dataIndex)
                }
            }
        }
    }
    
    /// Handle drag gesture for more precise point selection
    private func handleDragGesture(value: DragGesture.Value, proxy: ChartProxy, geometry: GeometryProxy) {
        isDragging = true
        
        guard let plotFrame = proxy.plotFrame, !visibleDataPoints.isEmpty else { return }
        
        let location = value.location
        let xPosition = location.x - geometry[plotFrame].origin.x
        
        // Check if drag is within chart bounds
        if xPosition < 0 || xPosition > geometry[plotFrame].width {
            return
        }
        
        let relativeXPosition = xPosition / geometry[plotFrame].width
        let dataIndex = findClosestPointIndex(at: relativeXPosition)
        
        if dataIndex >= 0 && dataIndex < dataPoints.count {
            onSelectPoint(dataIndex)
        }
    }
    
    // MARK: - Helper methods
    
    /// Create gradient for chart area
    private func chartAreaGradient() -> LinearGradient {
        LinearGradient(
            colors: [
                AppConstants.Colors.chartGreen.opacity(0.3),
                AppConstants.Colors.chartGreen.opacity(0.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// Get range for X axis
    private func getDateDomain() -> ClosedRange<Date> {
        guard !visibleDataPoints.isEmpty else {
            return Date()...Date()
        }
        
        // Use first and last elements of visible data
        let startDate = visibleDataPoints.first?.date ?? Date()
        let endDate = visibleDataPoints.last?.date ?? Date()
        
        return startDate...endDate
    }
    
    /// Get range for Y axis with special handling for negative values
    private func getValueDomain() -> ClosedRange<Double> {
        guard !visibleDataPoints.isEmpty else {
            return 0...100
        }
        
        // Exclude additional points from Y axis value range calculation
        let selectablePoints = visibleDataPoints.filter {
            $0.isSelectable == nil || $0.isSelectable == true
        }
        
        let values = selectablePoints.map { $0.value }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 100
        
        // Handle different cases based on data range
        if maxValue < 0 {
            // All negative values
            let lowerBuffer = abs(minValue) * 0.1
            // For negative values, set upper bound to 0
            return (minValue - lowerBuffer)...abs(minValue)
        } else if minValue > 0 {
            // All positive values
            let upperBuffer = maxValue * 0.1
            return 0...(maxValue + upperBuffer)
        } else {
            // Mix of positive and negative values
            let totalRange = abs(maxValue - minValue)
            let buffer = totalRange * 0.1
            return (minValue - buffer)...(maxValue + buffer)
        }
    }
    
    /// Get axis values based on selected period
    private func getAxisValues() -> [Date] {
        // Use values depending on period
        switch selectedPeriod {
        case .week:
            return axisDataPoints.map { $0.date }
        case .month:
            return axisDataPoints.map { $0.date }
        case .year:
            // For yearly view, show only each month or less when zooming
            if chartScale > 2.0 {
                return axisDataPoints.map { $0.date }
            } else {
                let step = max(1, axisDataPoints.count / 30)
                return strideThrough(array: axisDataPoints, by: step).map { $0.date }
            }
        }
    }
    
    // Helper function for creating array with step
    private func strideThrough<T>(array: [T], by step: Int) -> [T] {
        guard step > 0, !array.isEmpty else { return array }
        
        var result = [T]()
        var index = 0
        
        while index < array.count {
            result.append(array[index])
            index += step
        }
        
        return result
    }
    
    /// Find index of closest point based on relative position
    private func findClosestPointIndex(at relativePosition: CGFloat) -> Int {
        guard !visibleDataPoints.isEmpty else { return -1 }
        
        let exactIndex = relativePosition * CGFloat(visibleDataPoints.count - 1)
        let visibleIndex = Int(round(exactIndex))
        let boundedVisibleIndex = max(0, min(visibleDataPoints.count - 1, visibleIndex))
        
        // Find date for this point in visible data
        if boundedVisibleIndex >= 0 && boundedVisibleIndex < visibleDataPoints.count {
            let point = visibleDataPoints[boundedVisibleIndex]
            
            // If point is marked as non-selectable, return -1
            if let isSelectable = point.isSelectable, !isSelectable {
                return -1
            }
            
            // Find corresponding index in full dataset (without additional points)
            return dataPoints.firstIndex(where: { $0.date == point.date }) ?? -1
        }
        
        return -1
    }
    
    /// Get minimum data value for vertical line
    private func getMinDataValue() -> Double {
        guard !visibleDataPoints.isEmpty else { return 0 }
        
        let values = visibleDataPoints.map { $0.value }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 0
        
        if maxValue < 0 {
            let lowerBuffer = abs(minValue) * 0.1
            return minValue - lowerBuffer
        } else if minValue > 0 {
            return 0.0
        } else {
            let totalRange = abs(maxValue - minValue)
            let buffer = totalRange * 0.1
            return minValue - buffer
        }
    }
}
