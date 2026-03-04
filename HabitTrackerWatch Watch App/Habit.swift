import Foundation

struct Habit: Identifiable {
    var id: UUID
    var title: String
    var time: Date
    var isCompleted: Bool
}
