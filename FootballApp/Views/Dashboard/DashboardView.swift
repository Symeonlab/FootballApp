//
//  DashboardView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

//
//  DashboardView.swift
//  FootballApp
//

import SwiftUI

struct DashboardView: View {
    
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                } else if let metrics = viewModel.metrics {
                    VStack(spacing: 20) {
                        Text("Dashboard")
                            .font(.largeTitle.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // --- FIX: Pass the 'stats' object, not the whole viewmodel ---
                        DashboardStatsView(stats: metrics.stats)
                        
                        if let chartData = metrics.chart {
                            // TODO: Add your LineChartView
                            Text("Chart Goes Here")
                                .frame(height: 200)
                        }
                        
                        Text("Recent Activity")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(metrics.my_latest_progress ?? []) { log in
                            // TODO: Add your ProgressRowView
                            Text("Progress: \(log.date)")
                        }
                    }
                    .padding()
                } else {
                    Text(viewModel.errorMessage ?? "Failed to load metrics.")
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                viewModel.fetchDashboardMetrics()
            }
        }
    }
}

// MARK: - Sub-views

struct DashboardStatsView: View {
    // --- FIX: This view receives 'DashboardStats', not a ViewModel ---
    let stats: DashboardStats?

    var body: some View {
        HStack(spacing: 12) {
            statCard(
                title: "dashboard.progress.weight",
                value: "\(stats?.total_users ?? 0)",
                systemImage: "person.fill",
                color: .blue
            )
            statCard(
                title: "dashboard.progress.waist",
                value: "\(stats?.new_users_week ?? 0)",
                systemImage: "person.fill.badge.plus",
                color: .green
            )
            statCard(
                title: "dashboard.progress.chest",
                value: "\(stats?.total_progress_logs ?? 0)",
                systemImage: "chart.bar.fill",
                color: .orange
            )
        }
    }
    // --- END OF FIX ---
    
    private func statCard(title: LocalizedStringKey, value: String, systemImage: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2.bold())
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(Color.theme.textPrimary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.surface)
        .cornerRadius(12)
    }
}

