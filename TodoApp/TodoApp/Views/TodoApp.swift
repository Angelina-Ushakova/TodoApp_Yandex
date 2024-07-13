import SwiftUI
import CocoaLumberjackSwift

@main
struct TodoApp: App {
    
    init() {
        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
        DDLogVerbose("Verbose message")
        DDLogDebug("Debug message")
        DDLogInfo("Info message")
        DDLogWarn("Warn message")
        DDLogError("Error message")
    }
    
    var body: some Scene {
        WindowGroup {
            TodoListView()
        }
    }
}
