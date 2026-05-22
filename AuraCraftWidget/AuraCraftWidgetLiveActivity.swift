//
//  AuraCraftWidgetLiveActivity.swift
//  AuraCraftWidget
//
//  Created by MNyberg on 22/05/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AuraCraftWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AuraCraftWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AuraCraftWidgetAttributes.self) { context in
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

extension AuraCraftWidgetAttributes {
    fileprivate static var preview: AuraCraftWidgetAttributes {
        AuraCraftWidgetAttributes(name: "World")
    }
}

extension AuraCraftWidgetAttributes.ContentState {
    fileprivate static var smiley: AuraCraftWidgetAttributes.ContentState {
        AuraCraftWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AuraCraftWidgetAttributes.ContentState {
         AuraCraftWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AuraCraftWidgetAttributes.preview) {
   AuraCraftWidgetLiveActivity()
} contentStates: {
    AuraCraftWidgetAttributes.ContentState.smiley
    AuraCraftWidgetAttributes.ContentState.starEyes
}
