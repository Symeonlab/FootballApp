//
//  ProgressTrackingView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI

struct ProgressTrackingView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    // When embedded, only show a summary
    var isEmbedded: Bool = false

    var body: some View {
        if viewModel.isLoading && viewModel.progressLogs.isEmpty {
            ProgressView()
        } else if viewModel.progressLogs.isEmpty {
            Text("progress.no_logs".localizedString)
                .font(.subheadline)
                .foregroundColor(.secondary)
        } else {
            if isEmbedded {
                List {
                    ForEach(Array(viewModel.progressLogs.prefix(3))) { log in
                        ProgressRow(log: log)
                    }
                    
                    if viewModel.progressLogs.count > 3 {
                        NavigationLink(destination: FullProgressListView(viewModel: viewModel)) {
                            Text(String(format: "progress.view_all".localizedString, viewModel.progressLogs.count))
                                .foregroundColor(Color.theme.primary)
                        }
                    }
                }
                .listStyle(.plain)
                .frame(height: viewModel.progressLogs.count > 3 ? 200 : 150)
                .navigationTitle("")
            } else {
                List {
                    ForEach(viewModel.progressLogs) { log in
                        ProgressRow(log: log)
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("profile.full_progress".localizedString)
            }
        }
    }
}

// This is the full-screen list view
struct FullProgressListView: View {
    @ObservedObject var viewModel: ProfileViewModel
    var body: some View {
        List(viewModel.progressLogs) { log in
            ProgressRow(log: log)
        }
        .navigationTitle("profile.full_progress".localizedString)
        .onAppear {
            viewModel.fetchProgressLogs() // Refresh when view appears
        }
    }
}

// A single row in the progress list
struct ProgressRow: View {
    let log: UserProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(log.date.formattedDate()) // You'll need to create this helper
                .font(.headline)
            
            HStack(spacing: 15) {
                if let weight = log.weight {
                    Label(String(format: "%.1f kg", weight), systemImage: "body.scale")
                }
                if let mood = log.mood, !mood.isEmpty {
                    Text(mood)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.theme.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            if let notes = log.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 3)
            }
        }
        .padding(.vertical, 5)
    }
}

// --- ADD THIS HELPER to a new file, e.g., 'String+Extensions.swift' ---
extension String {
    func formattedDate() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        if let date = formatter.date(from: self) {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
        return self
    }
}
