//
//  Logger.swift
//  Y-Tiles
//
//  Configurable logging framework for debugging and production use
//  Copyright 2025 Chris Yunker. All rights reserved.
//
import Foundation
import os.log

enum LogLevel: Int, CaseIterable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case off = 4
    
    var prefix: String {
        switch self {
        case .debug: return "🔍 [DEBUG]"
        case .info: return "ℹ️ [INFO]"
        case .warning: return "⚠️ [WARNING]"
        case .error: return "❌ [ERROR]"
        case .off: return ""
        }
    }
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        case .off: return .info
        }
    }
}

class Logger {
    static let shared = Logger()
    
    // Configuration
    private var currentLevel: LogLevel = .debug
    private var useOSLog: Bool = true
    private var logToConsole: Bool = true
    private let osLog = OSLog(subsystem: "com.cyunker.Y-Tiles", category: "general")
    
    private init() {
        // Configure based on build configuration
        #if DEBUG
        currentLevel = .debug
        logToConsole = false  // Use only OS Log to avoid duplicates
        useOSLog = true
        #else
        currentLevel = .error
        logToConsole = false
        useOSLog = true
        #endif
    }
    
    // Initialize with app startup - call this from your app delegate or main app
    static func initialize() {
        let logger = Logger.shared
        logger.info("Logger initialized - Level: \(logger.currentLevel), Console: \(logger.logToConsole)")
    }
    
    // MARK: - Configuration Methods
    
    func setLogLevel(_ level: LogLevel) {
        currentLevel = level
    }
    
    func enableOSLog(_ enabled: Bool) {
        useOSLog = enabled
    }
    
    func enableConsoleLog(_ enabled: Bool) {
        logToConsole = enabled
    }
    
    // MARK: - Logging Methods
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }
    
    // MARK: - Private Implementation
    
    private func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        guard level.rawValue >= currentLevel.rawValue else { return }
        guard currentLevel != .off else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let formattedMessage = "\(level.prefix) [\(fileName):\(line)] \(function): \(message)"
        
        if logToConsole {
            print(formattedMessage)
        }
        
        if useOSLog {
            os_log("%{public}@", log: osLog, type: level.osLogType, formattedMessage)
        }
    }
}

// MARK: - Global Convenience Functions

func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.debug(message, file: file, function: function, line: line)
}

func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.info(message, file: file, function: function, line: line)
}

func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.warning(message, file: file, function: function, line: line)
}

func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.error(message, file: file, function: function, line: line)
}