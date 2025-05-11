//
//  ListeningWidgetLiveActivity.swift
//  ListeningWidget
//
//  Created by Dmytro Savka on 12.05.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ListeningWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ListeningWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ListeningWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ListeningWidgetAttributes {
    fileprivate static var preview: ListeningWidgetAttributes {
        ListeningWidgetAttributes(name: "World")
    }
}

extension ListeningWidgetAttributes.ContentState {
    fileprivate static var smiley: ListeningWidgetAttributes.ContentState {
        ListeningWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ListeningWidgetAttributes.ContentState {
         ListeningWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ListeningWidgetAttributes.preview) {
   ListeningWidgetLiveActivity()
} contentStates: {
    ListeningWidgetAttributes.ContentState.smiley
    ListeningWidgetAttributes.ContentState.starEyes
}
