//
//  ListeningWidget.swift
//  ListeningWidget
//
//  Created by Dmytro Savka on 12.05.2025.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.HealthyTrailerData")
        let isMonitoring = defaults?.bool(forKey: "isMonitoring") ?? false
        
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), isMonitoring: isMonitoring)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.HealthyTrailerData")
        let isMonitoring = defaults?.bool(forKey: "isMonitoring") ?? false
        
        return SimpleEntry(date: Date(), configuration: configuration, isMonitoring: isMonitoring)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let defaults = UserDefaults(suiteName: "group.HealthyTrailerData")
            let isMonitoring = defaults?.bool(forKey: "isMonitoring") ?? false
            
            let entry = SimpleEntry(date: entryDate, configuration: configuration, isMonitoring: isMonitoring)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

// MARK: - Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let isMonitoring: Bool
}

// MARK: - View
struct ListeningWidgetEntryView : View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            Color.gray
            
            VStack(spacing: 8) {
                Text("HealthyTrailer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .bold()

                if entry.isMonitoring {
                    Text("Monitoring data")
                        .foregroundColor(.green)
                } else {
                    Text("Not monitoring data")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
}

// MARK: - Widget Definition
struct ListeningWidget: Widget {
    let kind: String = "ListeningWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ListeningWidgetEntryView(entry: entry)
        }
        .contentMarginsDisabled()
    }
}
