import SwiftUI
import WatchKit

@main
struct HabitTrackerWatchApp: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self)
    var extensionDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        
        for task in backgroundTasks {
            
            if let refreshTask = task as? WKApplicationRefreshBackgroundTask {
                
                print("⌚ Background refresh executed")
                
                refreshTask.setTaskCompletedWithSnapshot(false)
                
            } else {
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}
