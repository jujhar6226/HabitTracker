import SwiftUI

struct AddHabitView: View {
    
    @ObservedObject var viewModel: HabitViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var time = Date()
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 30) {
                
                // Habit Name Section
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Habit Name")
                        .font(.system(size: 18, weight: .medium))
                    
                    TextField("Enter habit name", text: $title)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                }
                
                Divider()
                
                // Time Section
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Time")
                        .font(.system(size: 18, weight: .medium))
                    
                    DatePicker(
                        "",
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.addHabit(title: title, time: time)
                        dismiss()
                    }
                }
            }
        }
    }
}
