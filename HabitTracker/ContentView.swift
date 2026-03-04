import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = HabitViewModel()
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                // Background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // Title
                    Text("HaboTack")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 10)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Habit List
                    List {
                        ForEach(viewModel.habits) { habit in
                            
                            HStack(spacing: 16) {
                                
                                // Checkbox
                                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundColor(habit.isCompleted ? .black : .gray)
                                    .onTapGesture {
                                        viewModel.toggleHabit(habit)
                                    }
                                
                                // Habit Title
                                Text(habit.title)
                                    .font(.system(size: 18, weight: .medium))
                                
                                Spacer()
                                
                                // Time
                                Text(habit.time, style: .time)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete(perform: viewModel.deleteHabit)
                    }
                    .listStyle(.plain)
                    
                    Spacer()
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            showAddSheet = true
                        } label: {
                            
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .padding(.trailing, 25)
                        .padding(.bottom, 25)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddHabitView(viewModel: viewModel)
            }
        }
    }
}
