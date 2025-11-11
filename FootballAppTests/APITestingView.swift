//
//  APITestingView.swift
//  FootballApp
//
//  Interactive API endpoint testing interface
//

import SwiftUI

struct APITestingView: View {
    @StateObject private var tester = APITester()
    @State private var selectedEndpoint: APIEndpoint?
    @State private var showResponse = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Colorful gradient background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.1),
                        Color.pink.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Status Header
                        StatusHeaderCard(tester: tester)
                            .padding(.horizontal)
                        
                        // Test All Button
                        Button(action: {
                            Task {
                                await tester.testAllEndpoints()
                            }
                        }) {
                            HStack(spacing: 12) {
                                if tester.isTesting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title3)
                                }
                                Text(tester.isTesting ? "Testing All Endpoints..." : "Test All Endpoints")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .disabled(tester.isTesting)
                        .padding(.horizontal)
                        
                        // Endpoints List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("API Endpoints")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            ForEach(tester.endpoints) { endpoint in
                                EndpointCard(
                                    endpoint: endpoint,
                                    result: tester.results[endpoint.id],
                                    onTest: {
                                        selectedEndpoint = endpoint
                                        Task {
                                            await tester.testEndpoint(endpoint)
                                        }
                                    },
                                    onViewResponse: {
                                        selectedEndpoint = endpoint
                                        showResponse = true
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("API Testing")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showResponse) {
                if let endpoint = selectedEndpoint,
                   let result = tester.results[endpoint.id] {
                    ResponseDetailView(endpoint: endpoint, result: result)
                }
            }
        }
    }
}

// MARK: - Status Header Card
struct StatusHeaderCard: View {
    @ObservedObject var tester: APITester
    
    var passedTests: Int {
        tester.results.values.filter { $0.success }.count
    }
    
    var failedTests: Int {
        tester.results.values.filter { !$0.success }.count
    }
    
    var totalTests: Int {
        tester.results.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Token Status
            HStack(spacing: 12) {
                Image(systemName: tester.hasToken ? "checkmark.shield.fill" : "xmark.shield.fill")
                    .font(.title2)
                    .foregroundColor(tester.hasToken ? .green : .red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Authentication Token")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text(tester.hasToken ? "Token Available" : "No Token - Login Required")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            
            // Test Results Summary
            if totalTests > 0 {
                HStack(spacing: 20) {
                    TestStatBubble(
                        icon: "checkmark.circle.fill",
                        count: passedTests,
                        label: "Passed",
                        color: .green
                    )
                    
                    TestStatBubble(
                        icon: "xmark.circle.fill",
                        count: failedTests,
                        label: "Failed",
                        color: .red
                    )
                    
                    TestStatBubble(
                        icon: "circle.fill",
                        count: totalTests,
                        label: "Total",
                        color: .blue
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

struct TestStatBubble: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title.bold())
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Endpoint Card
struct EndpointCard: View {
    let endpoint: APIEndpoint
    let result: TestResult?
    let onTest: () -> Void
    let onViewResponse: () -> Void
    
    var statusColor: Color {
        guard let result = result else { return .gray }
        return result.success ? .green : .red
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Method Badge
                Text(endpoint.method)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(methodColor)
                    .clipShape(Capsule())
                
                // Endpoint Name
                Text(endpoint.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Status Indicator
                if let result = result {
                    Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(statusColor)
                }
            }
            
            // Path
            Text(endpoint.path)
                .font(.caption.monospaced())
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(uiColor: .tertiarySystemBackground))
                )
            
            // Response Time
            if let result = result {
                HStack(spacing: 16) {
                    Label("\(Int(result.responseTime * 1000))ms", systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !result.success {
                        Text(result.error ?? "Unknown error")
                            .font(.caption)
                            .foregroundColor(.red)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onTest) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Test")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                
                if result != nil {
                    Button(action: onViewResponse) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text.magnifyingglass")
                            Text("View")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.purple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.purple.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(statusColor.opacity(result != nil ? 0.3 : 0), lineWidth: 2)
        )
    }
    
    var methodColor: Color {
        switch endpoint.method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        default: return .gray
        }
    }
}

// MARK: - Response Detail View
struct ResponseDetailView: View {
    let endpoint: APIEndpoint
    let result: TestResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Status
                    HStack {
                        Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(result.success ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.success ? "Success" : "Failed")
                                .font(.title3.bold())
                            
                            Text("\(Int(result.responseTime * 1000))ms response time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                    
                    // Error
                    if let error = result.error {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Error")
                                .font(.headline)
                            
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.red.opacity(0.1))
                                )
                        }
                    }
                    
                    // Response Data
                    if let data = result.responseData {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Response Data")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(data)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color(uiColor: .tertiarySystemBackground))
                                    )
                            }
                        }
                    }
                    
                    // Expected Format
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expected Format")
                            .font(.headline)
                        
                        Text(endpoint.expectedFormat)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.blue.opacity(0.05))
                            )
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(endpoint.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    APITestingView()
}
