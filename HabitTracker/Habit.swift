import Foundation

struct Habit: Identifiable, Codable {
    var id = UUID()
    var title: String
    var time: Date
    var isCompleted: Bool = false
}
