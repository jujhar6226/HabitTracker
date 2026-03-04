import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject {

    static let shared = WatchConnectivityManager()

    override init() {
        super.init()
        activateSession()
    }

    private func activateSession() {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        session.delegate = self
        session.activate()

        print("📱 iPhone WCSession activated")
    }

    // Send full habit list to Watch
    func sendHabits(_ habits: [Habit]) {

        let session = WCSession.default

        guard session.activationState == .activated else { return }

        let habitData = habits.map {
            [
                "id": $0.id.uuidString,
                "title": $0.title,
                "time": $0.time.timeIntervalSince1970,
                "isCompleted": $0.isCompleted
            ]
        }

        try? session.updateApplicationContext(["habits": habitData])
    }
}

extension WatchConnectivityManager: WCSessionDelegate {

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any]) {

        // Habit created from watch
        if let title = message["title"] as? String,
           let timeInterval = message["time"] as? TimeInterval {

            let newHabit = Habit(
                title: title,
                time: Date(timeIntervalSince1970: timeInterval)
            )

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .habitReceivedFromWatch,
                    object: newHabit
                )
            }
        }

        // Habit completion toggled from watch
        if let habitIDString = message["habitID"] as? String,
           let habitID = UUID(uuidString: habitIDString),
           message["toggleComplete"] as? Bool == true {

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .habitCompletionToggled,
                    object: habitID
                )
            }
        }
    }
}

extension Notification.Name {
    static let habitReceivedFromWatch = Notification.Name("habitReceivedFromWatch")
    static let habitCompletionToggled = Notification.Name("habitCompletionToggled")
}
