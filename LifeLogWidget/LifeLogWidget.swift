import WidgetKit
import SwiftUI

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
