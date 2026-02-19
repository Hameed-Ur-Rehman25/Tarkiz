import os.log
import Foundation

final class Logger {
    static let shared = Logger()
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.focuspauseflow.app"
    
    private init() {}
    
    func debug(_ message: String, file: String = #file, function: String = #function) {
        log(message, type: .debug, file: file, function: function)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function) {
        log(message, type: .info, file: file, function: function)
    }
    
    func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function) {
        var fullMessage = message
        if let error = error {
            fullMessage += " | Error: \(error.localizedDescription)"
        }
        log(fullMessage, type: .error, file: file, function: function)
    }
    
    private func log(_ message: String, type: OSLogType, file: String, function: String) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(fileName):\(function)] \(message)"
        
        #if DEBUG
        print("🔵 [\(type.emoji)] \(logMessage)")
        #endif
        
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: "General"), type: type, logMessage)
    }
}

extension OSLogType {
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .error: return "❌"
        case .fault: return "🔥"
        default: return "📝"
        }
    }
}
