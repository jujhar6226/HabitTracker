//
//  HabitTrackerComplicationControl.swift
//  HabitTrackerComplication
//
//  Created by user290770 on 3/4/26.
//

import AppIntents
import SwiftUI
import WidgetKit

struct HabitTrackerComplicationControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "Jujhar.HabitTracker.watchkitapp.HabitTrackerComplication",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value,
                action: StartTimerIntent()
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

extension HabitTrackerComplicationControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}
