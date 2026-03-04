import SwiftUI

struct AddHabitView: View {
    
    @ObservedObject var viewModel: WatchHabitViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var time = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Habit Title", text: $title)
                
                DatePicker(
                    "Time",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !title.isEmpty {
                            viewModel.sendHabitToPhone(title: title, time: time)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
