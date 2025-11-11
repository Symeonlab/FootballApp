//
//  ErrorLogger.swift
//  FootballApp
//
//  Created by AI Assistant
//

import Foundation
import OSLog

/// A comprehensive error logging system for the app
/// Logs errors to console, file, and analytics
final class ErrorLogger {
    static let shared = ErrorLogger()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.dipodi.app", category: "ErrorLogger")
    private let fileManager = FileManager.default
    private var logFileURL: URL?
    
    private init() {
        setupLogFile()
    }
    
    // MARK: - Setup
    
    private func setupLogFile() {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let logsDirectory = documentsPath.appendingPathComponent("Logs", isDirectory: true)
        
        // Create logs directory if it doesn't exist
        if !fileManager.fileExists(atPath: logsDirectory.path) {
            try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        }
        
        // Create log file with date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        logFileURL = logsDirectory.appendingPathComponent("dipodi-\(dateString).log")
    }
    
    // MARK: - Public Logging Methods
    
    /// Log an error with context
    func logError(_ error: Error, context: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let message = """
        ❌ ERROR in \(fileName):\(line) \(function)
        Context: \(context)
        Error: \(error.localizedDescription)
        """
        
        log(message, level: .error)
        
        // Print to console in debug mode
        #if DEBUG
        print(message)
        #endif
    }
    
    /// Log a warning
    func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let fullMessage = "⚠️ WARNING in \(fileName):\(line) \(function)\n\(message)"
        log(fullMessage, level: .warning)
        
        #if DEBUG
        print(fullMessage)
        #endif
    }
    
    /// Log general info
    func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let fullMessage = "ℹ️ INFO in \(fileName):\(line) \(function)\n\(message)"
        log(fullMessage, level: .info)
        
        #if DEBUG
        print(fullMessage)
        #endif
    }
    
    /// Log a critical error that might cause a crash
    func logCritical(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        var fullMessage = "🔥 CRITICAL in \(fileName):\(line) \(function)\n\(message)"
        
        if let error = error {
            fullMessage += "\nError: \(error.localizedDescription)"
        }
        
        log(fullMessage, level: .critical)
        
        #if DEBUG
        print(fullMessage)
        #endif
        
        // In production, you might want to send this to a crash reporting service
        // like Firebase Crashlytics or Sentry
    }
    
    /// Log network errors
    func logNetworkError(_ error: Error, endpoint: String, statusCode: Int? = nil) {
        var message = "🌐 NETWORK ERROR\nEndpoint: \(endpoint)\nError: \(error.localizedDescription)"
        if let code = statusCode {
            message += "\nStatus Code: \(code)"
        }
        log(message, level: .error)
        
        #if DEBUG
        print(message)
        #endif
    }
    
    /// Log API response errors
    func logAPIError(endpoint: String, statusCode: Int, responseBody: String?) {
        var message = "🌐 API ERROR\nEndpoint: \(endpoint)\nStatus Code: \(statusCode)"
        if let body = responseBody {
            message += "\nResponse: \(body)"
        }
        log(message, level: .error)
        
        #if DEBUG
        print(message)
        #endif
    }
    
    // MARK: - Private Methods
    
    private func log(_ message: String, level: LogLevel) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logEntry = "[\(timestamp)] [\(level.rawValue)] \(message)\n\n"
        
        // Log to OSLog
        switch level {
        case .info:
            logger.info("\(message)")
        case .warning:
            logger.warning("\(message)")
        case .error:
            logger.error("\(message)")
        case .critical:
            logger.critical("\(message)")
        }
        
        // Write to file
        writeToFile(logEntry)
    }
    
    private func writeToFile(_ message: String) {
        guard let fileURL = logFileURL else { return }
        
        DispatchQueue.global(qos: .background).async {
            guard let data = message.data(using: .utf8) else { return }
            
            if self.fileManager.fileExists(atPath: fileURL.path) {
                // Append to existing file
                if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    try? fileHandle.close()
                }
            } else {
                // Create new file
                try? data.write(to: fileURL, options: .atomic)
            }
        }
    }
    
    // MARK: - Log Management
    
    /// Get the current log file contents
    func getLogContents() -> String? {
        guard let fileURL = logFileURL else { return nil }
        return try? String(contentsOf: fileURL, encoding: .utf8)
    }
    
    /// Clear old log files (older than 7 days)
    func clearOldLogs() {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let logsDirectory = documentsPath.appendingPathComponent("Logs", isDirectory: true)
        
        guard let logFiles = try? fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        for fileURL in logFiles {
            if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
               let creationDate = attributes[.creationDate] as? Date,
               creationDate < sevenDaysAgo {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    /// Export logs for debugging
    func exportLogs() -> URL? {
        guard let fileURL = logFileURL else { return nil }
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    // MARK: - Log Level
    
    enum LogLevel: String {
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
    }
}

// MARK: - Convenience Extensions

extension Error {
    /// Log this error using the global logger
    func log(context: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        ErrorLogger.shared.logError(self, context: context, file: file, function: function, line: line)
    }
}

// MARK: - View Extension for Error Handling

import SwiftUI

extension View {
    /// Handle errors in SwiftUI with automatic logging
    func handleError(_ error: Binding<Error?>, context: String = "") -> some View {
        self.onChange(of: error.wrappedValue.map { ObjectIdentifier($0 as AnyObject) }) { _, _ in
            if let err = error.wrappedValue {
                ErrorLogger.shared.logError(err, context: context)
            }
        }
    }
}
