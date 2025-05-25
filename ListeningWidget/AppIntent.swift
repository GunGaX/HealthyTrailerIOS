//
//  AppIntent.swift
//  ListeningWidget
//
//  Created by Dmytro Savka on 12.05.2025.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "", default: "")
    var favoriteEmoji: String
}
