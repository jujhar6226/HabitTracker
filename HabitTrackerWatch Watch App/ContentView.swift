import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = WatchHabitViewModel()
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if !viewModel.habits.isEmpty {
                    Text("\(viewModel.completedCount) of \(viewModel.habits.count) Done")
                        .font(.headline)
                        .padding(.bottom, 5)
                }
                
                List(viewModel.habits) { habit in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(habit.title)
                            
                            Text(habit.time, style: .time)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(habit.isCompleted ? .green : .gray)
                            .onTapGesture {
                                viewModel.toggleHabit(habit)
                            }
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddHabitView(viewModel: viewModel)
            }
        }
    }
}
