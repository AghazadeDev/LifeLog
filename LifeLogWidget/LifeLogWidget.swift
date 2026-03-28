import WidgetKit
import SwiftUI

@main
struct LifeLogWidgetBundle: WidgetBundle {
    var body: some Widget {
        LifeLogWidget()
    }
}

struct LifeLogWidget: Widget {
    let kind: String = "LifeLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeLogTimelineProvider()) { entry in
            LifeLogWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("LifeLog")
        .description("Track your journaling streak and today's entries.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
