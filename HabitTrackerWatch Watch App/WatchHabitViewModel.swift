import SwiftUI
import Combine
import WatchConnectivity
import UserNotifications
import WatchKit

class WatchHabitViewModel: NSObject, ObservableObject {
    
    @Published var habits: [Habit] = [] {
        didSet {
            scheduleNotifications()
        }
    }
    
    override init() {
        super.init()
        activateSession()
        requestNotificationPermission()
        scheduleBackgroundRefresh()
    }
    
    // MARK: - Watch Connectivity
    
    private func activateSession() {
        guard WCSession.isSupported() else { return }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
        
        print("⌚ Watch WCSession activated")
    }
    
    // Send new habit to iPhone
    func sendHabitToPhone(title: String, time: Date) {
        
        let session = WCSession.default
        
        guard session.isReachable else {
            print("⌚ Phone not reachable")
            return
        }
        
        session.sendMessage(
            [
                "title": title,
                "time": time.timeIntervalSince1970
            ],
            replyHandler: nil,
            errorHandler: nil
        )
    }
    
    // MARK: - Toggle Completion
    
    func toggleHabit(_ habit: Habit) {
        
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            
            habits[index].isCompleted.toggle()
            
            let session = WCSession.default
            
            if session.isReachable {
                
                session.sendMessage(
                    [
                        "habitID": habit.id.uuidString,
                        "toggleComplete": true
                    ],
                    replyHandler: nil,
                    errorHandler: nil
                )
            }
        }
    }
    
    var completedCount: Int {
        habits.filter { $0.isCompleted }.count
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, _ in
                if granted {
                    print("⌚ Notification permission granted")
                }
            }
    }
    
    private func scheduleNotifications() {
        
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
        
        for habit in habits {
            
            guard !habit.isCompleted else { continue }
            
            let interval = habit.time.timeIntervalSinceNow
            
            if interval > 0 {
                
                let content = UNMutableNotificationContent()
                content.title = "Habit Reminder"
                content.body = habit.title
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: interval,
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: habit.id.uuidString,
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    // MARK: - Background Refresh
    
    private func scheduleBackgroundRefresh() {
        
        let targetDate = Date().addingTimeInterval(600) // 10 minutes
        
        WKExtension.shared().scheduleBackgroundRefresh(
            withPreferredDate: targetDate,
            userInfo: nil
        ) { error in
            
            if let error = error {
                print("❌ Background refresh scheduling failed:", error)
            } else {
                print("⌚ Background refresh scheduled")
            }
        }
    }
}

extension WatchHabitViewModel: WCSessionDelegate {
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
    
    // Receive habit list from iPhone
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String : Any]) {
        
        if let habitData = applicationContext["habits"] as? [[String: Any]] {
            
            DispatchQueue.main.async {
                self.habits = habitData.compactMap { dict in
                    
                    guard let idString = dict["id"] as? String,
                          let id = UUID(uuidString: idString),
                          let title = dict["title"] as? String,
                          let timeInterval = dict["time"] as? TimeInterval,
                          let isCompleted = dict["isCompleted"] as? Bool
                    else { return nil }
                    
                    return Habit(
                        id: id,
                        title: title,
                        time: Date(timeIntervalSince1970: timeInterval),
                        isCompleted: isCompleted
                    )
                }
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {}
    
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any]) {}
}
