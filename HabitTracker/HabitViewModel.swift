import SwiftUI
import Combine

class HabitViewModel: ObservableObject {

    @Published var habits: [Habit] = []

    private let storageKey = "SavedHabits"

    init() {

        loadHabits()
        checkDailyReset()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHabitFromWatch(_:)),
            name: .habitReceivedFromWatch,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCompletionFromWatch(_:)),
            name: .habitCompletionToggled,
            object: nil
        )
    }

    // MARK: - Add Habit

    func addHabit(title: String, time: Date) {

        let newHabit = Habit(title: title, time: time)

        habits.append(newHabit)

        sortHabits()
        saveHabits()

        WatchConnectivityManager.shared.sendHabits(habits)
    }

    // MARK: - Delete Habit

    func deleteHabit(at offsets: IndexSet) {

        habits.remove(atOffsets: offsets)

        saveHabits()

        WatchConnectivityManager.shared.sendHabits(habits)
    }

    // MARK: - Toggle Habit (Phone)

    func toggleHabit(_ habit: Habit) {

        if let index = habits.firstIndex(where: { $0.id == habit.id }) {

            habits[index].isCompleted.toggle()

            saveHabits()

            WatchConnectivityManager.shared.sendHabits(habits)
        }
    }

    // MARK: - Habit From Watch

    @objc private func handleHabitFromWatch(_ notification: Notification) {

        if let newHabit = notification.object as? Habit {

            habits.append(newHabit)

            sortHabits()

            saveHabits()

            WatchConnectivityManager.shared.sendHabits(habits)
        }
    }

    // MARK: - Completion From Watch

    @objc private func handleCompletionFromWatch(_ notification: Notification) {

        if let habitID = notification.object as? UUID {

            if let index = habits.firstIndex(where: { $0.id == habitID }) {

                habits[index].isCompleted.toggle()

                saveHabits()

                WatchConnectivityManager.shared.sendHabits(habits)
            }
        }
    }

    // MARK: - Sort

    private func sortHabits() {
        habits.sort { $0.time < $1.time }
    }

    // MARK: - Save

    private func saveHabits() {

        if let encoded = try? JSONEncoder().encode(habits) {

            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    // MARK: - Load

    private func loadHabits() {

        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {

            habits = decoded
        }
    }

    // MARK: - Daily Reset

    func resetHabitsForNewDay() {

        for index in habits.indices {

            habits[index].isCompleted = false
        }

        saveHabits()

        WatchConnectivityManager.shared.sendHabits(habits)
    }

    private func checkDailyReset() {

        let today = Calendar.current.startOfDay(for: Date())

        let lastReset = UserDefaults.standard.object(forKey: "LastHabitReset") as? Date ?? Date.distantPast

        if lastReset < today {

            resetHabitsForNewDay()

            UserDefaults.standard.set(today, forKey: "LastHabitReset")
        }
    }

    // MARK: - Progress

    var completedCount: Int {
        habits.filter { $0.isCompleted }.count
    }
}
