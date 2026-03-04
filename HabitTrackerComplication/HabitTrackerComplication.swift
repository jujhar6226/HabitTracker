import WidgetKit
import SwiftUI

struct HabitEntry: TimelineEntry {
    let date: Date
    let completed: Int
    let total: Int
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), completed: 2, total: 5)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> ()) {
        let entry = HabitEntry(date: Date(), completed: 2, total: 5)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> ()) {
        
        // Example data for now
        let entry = HabitEntry(date: Date(), completed: 2, total: 5)
        
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900)))
        
        completion(timeline)
    }
}

struct HabitTrackerComplicationEntryView : View {
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("\(entry.completed)/\(entry.total)")
                .font(.headline)
        }
    }
}

struct HabitTrackerComplication: Widget {
    
    let kind: String = "HabitTrackerComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HabitTrackerComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Progress")
        .description("Shows completed habits.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
