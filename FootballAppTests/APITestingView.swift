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
    @State private var showQuickLogin = false
    
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
                        StatusHeaderCard(tester: tester, onQuickLogin: {
                            showQuickLogin = true
                        })
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
            .sheet(isPresented: $showQuickLogin) {
                QuickLoginView(onLoginSuccess: {
                    tester.checkToken()
                    showQuickLogin = false
                })
            }
        }
    }
}

// MARK: - Status Header Card
struct StatusHeaderCard: View {
    @ObservedObject var tester: APITester
    let onQuickLogin: () -> Void
    @State private var showCopyConfirmation = false
    @State private var showDebugAlert = false
    @State private var debugMessage = ""
    @State private var showShareSheet = false
    @State private var shareContent = ""
    
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
                    
                    // Debug: Show token preview
                    if let token = APITokenManager.shared.currentToken {
                        Text("Token: \(token.prefix(15))...")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Refresh Token Button (for debugging)
                Button(action: {
                    tester.checkToken()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.gray.opacity(0.6))
                        .clipShape(Circle())
                }
                
                // Copy Logs Button
                if totalTests > 0 {
                    // Share/Export Button
                    Button(action: {
                        shareContent = generateLogText()
                        showShareSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.caption)
                            Text("Export")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .clipShape(Capsule())
                    }
                    
                    // Copy Full Logs Button
                    Button(action: copyTestLogs) {
                        HStack(spacing: 4) {
                            Image(systemName: showCopyConfirmation ? "checkmark" : "doc.on.doc")
                                .font(.caption)
                            Text(showCopyConfirmation ? "Copied!" : "Full")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(showCopyConfirmation ? Color.green : Color.purple)
                        .clipShape(Capsule())
                    }
                    
                    // Copy Summary Button
                    Button(action: copySummary) {
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.caption)
                            Text("Quick")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                    }
                }
                
                // Quick Login Button
                if !tester.hasToken {
                    Button(action: onQuickLogin) {
                        Text("Login")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
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
        .alert("Clipboard Debug", isPresented: $showDebugAlert) {
            Button("OK") { }
        } message: {
            Text(debugMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareContent])
        }
    }
    
    // Extract log generation into reusable function
    private func generateLogText() -> String {
        print("🔨 Generating log text...")
        print("   - Total tests: \(totalTests)")
        print("   - Passed: \(passedTests)")
        print("   - Failed: \(failedTests)")
        print("   - Results dictionary count: \(tester.results.count)")
        print("   - Endpoints array count: \(tester.endpoints.count)")
        
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        var logText = """
        ==========================================
        API TEST RESULTS
        ==========================================
        Generated: \(formatter.string(from: timestamp))
        
        SUMMARY
        ==========================================
        Total Tests: \(totalTests)
        Passed: \(passedTests) ✅
        Failed: \(failedTests) ❌
        Success Rate: \(totalTests > 0 ? String(format: "%.1f%%", Double(passedTests) / Double(totalTests) * 100) : "0%")
        
        AUTHENTICATION
        ==========================================
        Token Status: \(tester.hasToken ? "✅ Available" : "❌ Missing")
        Token Value: \(APITokenManager.shared.currentToken?.prefix(20) ?? "None")...
        
        
        """
        
        print("   - Header length: \(logText.count) chars")
        
        logText += """
        DETAILED RESULTS
        ==========================================
        
        """
        
        print("   - After adding 'DETAILED RESULTS' header: \(logText.count) chars")
        
        // Sort endpoints by result status (failed first, then passed)
        let sortedEndpoints = tester.endpoints.sorted { endpoint1, endpoint2 in
            let result1 = tester.results[endpoint1.id]
            let result2 = tester.results[endpoint2.id]
            
            if result1 == nil && result2 != nil { return false }
            if result1 != nil && result2 == nil { return true }
            
            let success1 = result1?.success ?? false
            let success2 = result2?.success ?? false
            
            if success1 != success2 {
                return !success1 // Failed tests first
            }
            
            return endpoint1.name < endpoint2.name
        }
        
        print("   - Sorted endpoints count: \(sortedEndpoints.count)")
        
        var processedCount = 0
        for endpoint in sortedEndpoints {
            guard let result = tester.results[endpoint.id] else { 
                print("   ⚠️ Skipping \(endpoint.name) - no result found")
                continue 
            }
            
            processedCount += 1
            let status = result.success ? "✅ PASS" : "❌ FAIL"
            
            let endpointSection = """
            
            ------------------------------------------
            [\(status)] \(endpoint.name)
            ------------------------------------------
            Method: \(endpoint.method)
            Path: \(endpoint.path)
            Requires Auth: \(endpoint.requiresAuth ? "Yes" : "No")
            Response Time: \(Int(result.responseTime * 1000))ms
            Status: \(result.success ? "Success" : "Failed")
            
            """
            
            logText += endpointSection
            
            if let error = result.error {
                logText += """
                Error:
                \(error)
                
                """
            }
            
            if let responseData = result.responseData {
                // Limit response data to first 500 chars to avoid huge logs
                let truncatedData = responseData.count > 500 ? 
                    String(responseData.prefix(500)) + "\n... (truncated, \(responseData.count) total chars)" : 
                    responseData
                
                logText += """
                Response Data:
                \(truncatedData)
                
                """
            }
        }
        
        print("   - Processed \(processedCount) endpoints")
        print("   - Before footer: \(logText.count) chars")
        
        logText += """
        
        ==========================================
        END OF REPORT
        ==========================================
        
        """
        
        print("   ✅ Final log length: \(logText.count) chars")
        
        return logText
    }
    
    private func copySummary() {
        print("📋 Quick Summary button tapped")
        
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        var summary = """
        📊 API Test Summary - \(formatter.string(from: timestamp))
        
        Results: \(passedTests)/\(totalTests) passed (\(totalTests > 0 ? String(format: "%.0f%%", Double(passedTests) / Double(totalTests) * 100) : "0%"))
        Token: \(tester.hasToken ? "✅" : "❌")
        
        """
        
        // Failed tests
        if failedTests > 0 {
            summary += "\n❌ FAILED (\(failedTests)):\n"
            for endpoint in tester.endpoints {
                if let result = tester.results[endpoint.id], !result.success {
                    summary += "  • \(endpoint.name)\n"
                    summary += "    \(endpoint.method) \(endpoint.path)\n"
                    if let error = result.error {
                        summary += "    Error: \(error)\n"
                    }
                    summary += "\n"
                }
            }
        }
        
        // Passed tests
        if passedTests > 0 {
            summary += "\n✅ PASSED (\(passedTests)):\n"
            for endpoint in tester.endpoints {
                if let result = tester.results[endpoint.id], result.success {
                    summary += "  • \(endpoint.name) (\(Int(result.responseTime * 1000))ms)\n"
                }
            }
        }
        
        print("📋 Summary length: \(summary.count) chars")
        print(summary)
        
        // Copy to clipboard
        UIPasteboard.general.string = summary
        
        #if !os(watchOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        
        showCopyConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showCopyConfirmation = false
        }
    }
    
    private func copyTestLogs() {
        print("📋 Copy Logs button tapped")
        print("📋 Total tests available: \(totalTests)")
        print("📋 Results count: \(tester.results.count)")
        print("📋 Endpoints count: \(tester.endpoints.count)")
        
        // Early return if no tests have been run
        if totalTests == 0 {
            let emptyMessage = """
            ⚠️ NO TEST RESULTS AVAILABLE
            
            Please run tests first by tapping "Test All Endpoints" or testing individual endpoints.
            
            Once tests are complete, copy logs again to see detailed results.
            """
            UIPasteboard.general.string = emptyMessage
            print("⚠️ No tests to copy - clipboard set to warning message")
            
            #if !os(watchOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            #endif
            
            showCopyConfirmation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showCopyConfirmation = false
            }
            return
        }
        
        // Generate the log text
        let logText = generateLogText()
        
        print("📋 Generated log report:")
        print("   - Total length: \(logText.count) characters")
        print("   - Lines: \(logText.components(separatedBy: "\n").count)")
        print("   - First 300 chars:\n\(logText.prefix(300))")
        
        // Print the FULL log to console (as backup)
        print("\n" + String(repeating: "=", count: 50))
        print("📄 FULL LOG OUTPUT (copy from console if clipboard fails):")
        print(String(repeating: "=", count: 50))
        print(logText)
        print(String(repeating: "=", count: 50) + "\n")
        
        // Copy to clipboard - use explicit method
        DispatchQueue.main.async {
            // Clear clipboard first
            UIPasteboard.general.items = []
            
            // Set the string explicitly
            UIPasteboard.general.setValue(logText, forPasteboardType: "public.utf8-plain-text")
            
            // Also set it the standard way as backup
            UIPasteboard.general.string = logText
            
            print("📋 Clipboard copy initiated")
            
            // Verify after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let copiedText = UIPasteboard.general.string {
                    print("✅ Clipboard verification:")
                    print("   - Length: \(copiedText.count) characters")
                    print("   - Matches generated: \(copiedText == logText)")
                    print("   - Last 100 chars: \(copiedText.suffix(100))")
                    
                    if copiedText.count != logText.count {
                        print("⚠️ WARNING: Size mismatch!")
                        print("   Expected: \(logText.count) chars")
                        print("   Got: \(copiedText.count) chars")
                        print("   Missing: \(logText.count - copiedText.count) chars")
                    } else {
                        print("✅ Full content copied successfully!")
                    }
                    
                    // Debug message for alert
                    self.debugMessage = """
                    ✅ Copied \(copiedText.count) characters
                    
                    Tests: \(self.totalTests)
                    Passed: \(self.passedTests)
                    Failed: \(self.failedTests)
                    
                    Check Xcode console for full details
                    """
                    
                    // Enable this to see debug info
                    // self.showDebugAlert = true
                } else {
                    print("❌ Failed to verify clipboard content")
                    self.debugMessage = "❌ Clipboard copy may have failed"
                }
            }
            
            // Show confirmation with haptic feedback
            #if !os(watchOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
            
            self.showCopyConfirmation = true
            
            // Reset after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.showCopyConfirmation = false
            }
        }
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

// MARK: - Quick Login View
struct QuickLoginView: View {
    let onLoginSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = "test@example.com"
    @State private var password = "Password123"
    @State private var isLoggingIn = false
    @State private var isRegistering = false
    @State private var isSettingUpProfile = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showSetupOption = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                } header: {
                    Text("Quick Test Login/Register")
                } footer: {
                    Text("Try logging in first. If the user doesn't exist, register a new one.")
                        .font(.caption)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if let successMessage = successMessage {
                    Section {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                Section {
                    // Login Button
                    Button(action: login) {
                        HStack {
                            if isLoggingIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            Text(isLoggingIn ? "Logging in..." : "Login")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoggingIn || isRegistering || isSettingUpProfile || email.isEmpty || password.isEmpty)
                    
                    // Register Button
                    Button(action: { showSetupOption = true; register() }) {
                        HStack {
                            if isRegistering {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            Text(isRegistering ? "Creating Account..." : "Register New Account")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoggingIn || isRegistering || isSettingUpProfile || email.isEmpty || password.isEmpty)
                }
                
                // Setup Profile Button (only shows after successful registration/login)
                if showSetupOption {
                    Section {
                        Button(action: setupTestProfile) {
                            HStack {
                                if isSettingUpProfile {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                }
                                Text(isSettingUpProfile ? "Setting up profile..." : "🔧 Complete Test Profile")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(isSettingUpProfile)
                    } header: {
                        Text("Optional: Setup Test Data")
                    } footer: {
                        Text("This will complete the user's profile and generate workout/nutrition plans. Recommended for full API testing.")
                            .font(.caption)
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 Troubleshooting Tips")
                            .font(.subheadline.bold())
                        
                        Text("• If you get 401 errors: User doesn't exist or wrong password")
                            .font(.caption)
                        
                        Text("• If you get 500 errors: Backend issue (mail server, database, etc.)")
                            .font(.caption)
                        
                        Text("• After registering, tap 'Complete Test Profile' for better test results")
                            .font(.caption)
                        
                        Text("• Only 4 tests passing? The user needs profile data - tap setup button!")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Quick Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func login() {
        isLoggingIn = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.login(email: email, password: password)
                
                await MainActor.run {
                    // Store the token
                    APITokenManager.shared.currentToken = response.token
                    
                    // Debug: Verify token was stored
                    let storedToken = APITokenManager.shared.currentToken
                    print("🔐 DEBUG - Token after login:")
                    print("   Response token: \(response.token.prefix(20))...")
                    print("   Stored token: \(storedToken?.prefix(20) ?? "NIL")...")
                    print("   Token matches: \(response.token == storedToken)")
                    
                    successMessage = "✅ Login successful!\n\nToken: \(response.token.prefix(20))..."
                    isLoggingIn = false
                    showSetupOption = true  // Show option to complete profile
                    
                    // Don't dismiss immediately - let them setup profile if needed
                }
            } catch {
                await MainActor.run {
                    isLoggingIn = false
                    
                    // Parse error for better messages
                    if let apiError = error as? APIError {
                        errorMessage = apiError.errorDescription ?? apiError.message
                    } else if (error as NSError).code == -1001 {
                        errorMessage = "Request timed out. Is your Laravel server running?"
                    } else if (error as NSError).code == -1004 {
                        errorMessage = "Could not connect to server. Check your baseURL configuration."
                    } else {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func register() {
        isRegistering = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.register(
                    name: "Test User",
                    email: email,
                    password: password,
                    passwordConfirmation: password
                )
                
                await MainActor.run {
                    // Store the token
                    APITokenManager.shared.currentToken = response.token
                    
                    // Debug: Verify token was stored
                    let storedToken = APITokenManager.shared.currentToken
                    print("🔐 DEBUG - Token after registration:")
                    print("   Response token: \(response.token.prefix(20))...")
                    print("   Stored token: \(storedToken?.prefix(20) ?? "NIL")...")
                    print("   Token matches: \(response.token == storedToken)")
                    
                    successMessage = "✅ Account created!\n\nToken: \(response.token.prefix(20))...\n\nNow tap 'Complete Test Profile' below."
                    isRegistering = false
                    showSetupOption = true  // Show the setup button
                }
            } catch {
                await MainActor.run {
                    isRegistering = false
                    
                    // Parse error for better messages
                    if let apiError = error as? APIError {
                        if let validationErrors = apiError.errors {
                            // Show first validation error
                            let firstError = validationErrors.values.first?.first ?? apiError.message
                            errorMessage = firstError
                        } else {
                            errorMessage = apiError.message
                        }
                    } else if (error as NSError).code == -1001 {
                        errorMessage = "Request timed out. Is your Laravel server running?"
                    } else if (error as NSError).code == -1004 {
                        errorMessage = "Could not connect to server. Check your baseURL configuration."
                    } else {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func setupTestProfile() {
        isSettingUpProfile = true
        errorMessage = nil
        successMessage = "Setting up test data..."
        
        Task {
            var steps: [String] = []
            
            do {
                // Step 1: Complete profile with comprehensive test data
                successMessage = "📝 Completing profile..."
                
                let profileData = OnboardingData(
                    discipline: "Football",
                    position: "Midfielder",
                    inClub: true,
                    matchDay: "Saturday",
                    trainingDays: ["Monday", "Wednesday", "Friday"],
                    trainingFocus: "Technical",
                    level: "Intermediate",
                    hasInjury: false,
                    injuryLocation: nil,
                    trainingLocation: "Gym",
                    gymPreferences: ["Strength", "Cardio"],
                    cardioPreferences: ["Running"],
                    outdoorPreferences: ["Field Training"],
                    homePreferences: ["Bodyweight"],
                    name: "Test User",
                    gender: "male",
                    height: 180,
                    weight: 75,
                    age: 25,
                    country: "France",
                    region: "Île-de-France",
                    proLevel: "Amateur",
                    idealWeight: 73,
                    birthDate: Date(timeIntervalSince1970: 820454400), // 1996-01-01
                    activityLevel: "Moderate",
                    goal: "Performance",
                    morphology: "Athletic",
                    hormonalIssues: "None",
                    isVegetarian: false,
                    mealsPerDay: "3",
                    breakfastPreferences: ["Continental"],
                    badHabits: nil,
                    snackingHabits: "Occasional",
                    vegetableConsumption: "Daily",
                    fishConsumption: "Weekly",
                    meatConsumption: "Weekly",
                    dairyConsumption: "Daily",
                    sugaryFoodConsumption: "Rarely",
                    cerealConsumption: "Daily",
                    starchyFoodConsumption: "Daily",
                    sugaryDrinkConsumption: "Rarely",
                    eggConsumption: "Weekly",
                    fruitConsumption: "Daily",
                    takesMedication: false,
                    hasDiabetes: false,
                    familyHistory: nil,
                    medicalHistory: nil
                )
                
                _ = try await APIService.shared.updateUserProfile(profileData)
                steps.append("✅ Profile completed")
                
                // Step 2: Generate workout plan
                await MainActor.run {
                    successMessage = "💪 Generating workout plan..."
                }
                
                _ = try await APIService.shared.generateWorkoutPlan()
                steps.append("✅ Workout plan generated")
                
                // Step 3: Add a test progress entry  
                await MainActor.run {
                    successMessage = "📊 Adding test progress..."
                }
                
                // Create a proper encodable struct for progress
                struct ProgressRequest: Encodable {
                    let date: String
                    let workout_completed: String
                    let weight: Double
                    let mood: String
                    let notes: String
                }
                
                let progressBody = ProgressRequest(
                    date: "2025-12-18",
                    workout_completed: "Test Workout - Monday",
                    weight: 75.0,
                    mood: "energized",
                    notes: "Initial test entry from API testing"
                )
                
                // Use the generic request method
                let _: UserProgress = try await APIService.shared.request(
                    endpoint: "/api/user-progress",
                    method: "POST",
                    body: progressBody
                )
                steps.append("✅ Progress logged")
                
                // Success!
                await MainActor.run {
                    let stepsSummary = steps.joined(separator: "\n")
                    successMessage = "🎉 Setup complete!\n\n\(stepsSummary)\n\nYou can now test all endpoints!"
                    isSettingUpProfile = false
                    
                    // Auto-dismiss after showing success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        onLoginSuccess()
                    }
                }
                
            } catch {
                await MainActor.run {
                    isSettingUpProfile = false
                    
                    let stepsSummary = steps.isEmpty ? "Setup failed" : steps.joined(separator: "\n")
                    
                    if let apiError = error as? APIError {
                        errorMessage = "⚠️ \(stepsSummary)\n\nError: \(apiError.message)"
                    } else {
                        errorMessage = "⚠️ \(stepsSummary)\n\nError: \(error.localizedDescription)"
                    }
                    
                    // Even if setup partially failed, still allow closing
                    showSetupOption = false
                }
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    APITestingView()
}
