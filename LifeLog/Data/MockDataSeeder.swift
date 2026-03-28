import Foundation
import SwiftData

struct MockDataSeeder {
    let modelContext: ModelContext

    private static let seededKey = "MockDataSeeded"

    var isAlreadySeeded: Bool {
        UserDefaults.standard.bool(forKey: Self.seededKey)
    }

    func seedIfNeeded() {
        guard !isAlreadySeeded else { return }
        seed()
        UserDefaults.standard.set(true, forKey: Self.seededKey)
    }

    func seed() {
        let useCase = JournalUseCase(modelContext: modelContext)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        for entry in Self.mockEntries {
            guard let date = calendar.date(byAdding: .day, value: entry.daysAgo * -1, to: today) else { continue }
            let noteDate = calendar.date(byAdding: .hour, value: entry.hour, to: date) ?? date
            useCase.addEntry(
                text: entry.text,
                date: noteDate,
                mood: entry.mood,
                tags: entry.tags,
                isPinned: entry.isPinned
            )
        }
    }

    // MARK: - Mock Entries

    private struct MockEntry {
        let daysAgo: Int
        let hour: Int
        let text: String
        let mood: String?
        let tags: [String]
        let isPinned: Bool
    }

    private static let mockEntries: [MockEntry] = [
        // Today (day 0)
        MockEntry(daysAgo: 0, hour: 8, text: "Woke up feeling refreshed after a solid 8 hours of sleep. Morning routine went smoothly — meditation, coffee, and a quick walk around the block. Ready to tackle the day.", mood: "😄", tags: ["health", "personal"], isPinned: false),
        MockEntry(daysAgo: 0, hour: 13, text: "Had a productive meeting with the team about the new feature rollout. Everyone seems aligned on the timeline. Need to finalize the API design by Friday.", mood: "😊", tags: ["work"], isPinned: false),

        // Yesterday (day 1)
        MockEntry(daysAgo: 1, hour: 9, text: "Struggled to get out of bed today. Didn't sleep well — kept thinking about the upcoming presentation. Need to prepare more thoroughly to feel confident.", mood: "😕", tags: ["work", "personal"], isPinned: false),
        MockEntry(daysAgo: 1, hour: 18, text: "Went for a 5K run after work. It was tough but I pushed through. Running always clears my head. Feeling much better now.", mood: "😊", tags: ["health"], isPinned: true),
        MockEntry(daysAgo: 1, hour: 21, text: "Called Mom and Dad tonight. They're planning a trip to visit next month — really looking forward to it. Haven't seen them since the holidays.", mood: "😄", tags: ["family"], isPinned: false),

        // Day 2
        MockEntry(daysAgo: 2, hour: 10, text: "Spent the morning learning about SwiftUI animations. Built a cool card flip effect that I'm proud of. The documentation is getting better but Stack Overflow is still essential.", mood: "😊", tags: ["learning", "work"], isPinned: false),
        MockEntry(daysAgo: 2, hour: 15, text: "Budgeting session for the month. Realized I've been spending too much on dining out. Setting a $200 limit for restaurants this month.", mood: "😐", tags: ["finance"], isPinned: false),

        // Day 3
        MockEntry(daysAgo: 3, hour: 7, text: "Early morning gym session. Hit a new personal record on deadlifts — 225 lbs! Been working toward this for months. Consistency is paying off.", mood: "😄", tags: ["health", "goals"], isPinned: true),
        MockEntry(daysAgo: 3, hour: 14, text: "Team standup was frustrating. The backend changes keep breaking our integration tests. Need to set up better CI/CD pipelines to catch these earlier.", mood: "😕", tags: ["work"], isPinned: false),
        MockEntry(daysAgo: 3, hour: 20, text: "Date night with a friend at the new Italian place downtown. The pasta was incredible. Good conversations about life goals and where we want to be in 5 years.", mood: "😄", tags: ["social"], isPinned: false),

        // Day 5
        MockEntry(daysAgo: 5, hour: 9, text: "Terrible headache all morning. Took some medicine and tried to rest but couldn't really focus on anything. Skipped my workout.", mood: "😢", tags: ["health"], isPinned: false),
        MockEntry(daysAgo: 5, hour: 16, text: "Feeling a bit better in the afternoon. Managed to do some light reading — started 'Atomic Habits' by James Clear. The chapter on habit stacking is really practical.", mood: "😐", tags: ["learning", "personal"], isPinned: false),

        // Day 7
        MockEntry(daysAgo: 7, hour: 10, text: "Weekly review day. Looked back at my goals for the week — completed 4 out of 6. The two I missed were both related to the side project. Need to carve out dedicated time for it.", mood: "😊", tags: ["goals", "personal"], isPinned: false),
        MockEntry(daysAgo: 7, hour: 14, text: "Brainstorming session for the side project. Came up with a new feature idea — AI-powered daily reflections. Sketched out the basic architecture. Exciting possibilities.", mood: "😄", tags: ["creativity", "work"], isPinned: true),
        MockEntry(daysAgo: 7, hour: 19, text: "Family video call. My sister announced she got promoted! So proud of her. We're planning a celebration dinner when everyone's in town.", mood: "😄", tags: ["family", "social"], isPinned: false),

        // Day 10
        MockEntry(daysAgo: 10, hour: 8, text: "Rough start to the week. The project deadline got moved up by two weeks. Feeling overwhelmed but trying to break it down into manageable chunks.", mood: "😕", tags: ["work"], isPinned: false),
        MockEntry(daysAgo: 10, hour: 12, text: "Lunch walk helped clear my mind. Made a priority list and identified the three most critical tasks. If I focus on those, the rest will follow.", mood: "😐", tags: ["work", "personal"], isPinned: false),
        MockEntry(daysAgo: 10, hour: 20, text: "Tried a new recipe — Thai green curry from scratch. Turned out surprisingly well! Cooking is becoming a nice creative outlet.", mood: "😊", tags: ["creativity", "personal"], isPinned: false),

        // Day 12
        MockEntry(daysAgo: 12, hour: 11, text: "Finally fixed that bug that's been haunting me for three days. It was a race condition in the async handler. The relief is unreal.", mood: "😄", tags: ["work"], isPinned: false),
        MockEntry(daysAgo: 12, hour: 17, text: "Signed up for an online course on machine learning. Always wanted to understand how recommendation systems work. First module was surprisingly accessible.", mood: "😊", tags: ["learning", "goals"], isPinned: false),

        // Day 14
        MockEntry(daysAgo: 14, hour: 9, text: "Two weeks into my new morning routine. Meditation streak is at 14 days. I can already feel the difference — less reactive, more intentional with my time.", mood: "😄", tags: ["health", "goals", "personal"], isPinned: true),
        MockEntry(daysAgo: 14, hour: 15, text: "Code review feedback was harsh but fair. My error handling needs work. Taking it as a learning opportunity rather than criticism.", mood: "😐", tags: ["work", "learning"], isPinned: false),
        MockEntry(daysAgo: 14, hour: 21, text: "Watched a documentary about space exploration. It's humbling how small our problems are in the grand scheme of things. Feeling grateful for everything I have.", mood: "😊", tags: ["personal"], isPinned: false),

        // Day 17
        MockEntry(daysAgo: 17, hour: 10, text: "Traveled to a nearby city for a tech conference. The keynote on AI ethics was thought-provoking. Met some interesting people during the networking session.", mood: "😄", tags: ["travel", "learning", "social"], isPinned: false),
        MockEntry(daysAgo: 17, hour: 22, text: "Hotel room feels lonely. Missing my usual routine and my own bed. But grateful for the experience and new connections.", mood: "😐", tags: ["travel", "personal"], isPinned: false),

        // Day 20
        MockEntry(daysAgo: 20, hour: 8, text: "Feeling really down today. Nothing specific happened, just one of those days where everything feels heavy. Going to try to be gentle with myself.", mood: "😢", tags: ["personal"], isPinned: false),
        MockEntry(daysAgo: 20, hour: 14, text: "Forced myself to go for a walk. The sunshine helped a little. Reminded myself that bad days are temporary and it's okay to not be okay.", mood: "😕", tags: ["health", "personal"], isPinned: false),
        MockEntry(daysAgo: 20, hour: 19, text: "Called my best friend and talked for an hour. They always know how to make me laugh. Feeling a bit lighter now. Connection is medicine.", mood: "😊", tags: ["social", "personal"], isPinned: false),

        // Day 23
        MockEntry(daysAgo: 23, hour: 9, text: "Started tracking my expenses with a new app. Spent 30 minutes categorizing last month's transactions. Eye-opening to see where the money actually goes.", mood: "😐", tags: ["finance", "goals"], isPinned: false),
        MockEntry(daysAgo: 23, hour: 16, text: "Pair programming session with a junior developer. Teaching others really solidifies your own understanding. They asked great questions I hadn't considered.", mood: "😊", tags: ["work", "social"], isPinned: false),

        // Day 25
        MockEntry(daysAgo: 25, hour: 7, text: "5 AM wake-up for a sunrise hike. The view from the top was absolutely breathtaking. Sometimes you need to disconnect from screens and reconnect with nature.", mood: "😄", tags: ["health", "travel"], isPinned: true),
        MockEntry(daysAgo: 25, hour: 13, text: "Spent the afternoon painting. Haven't picked up a brush in months. It's messy and imperfect and I love it. Art doesn't have to be good to be meaningful.", mood: "😊", tags: ["creativity"], isPinned: false),

        // Day 28
        MockEntry(daysAgo: 28, hour: 10, text: "Performance review at work went better than expected. Manager highlighted my growth in technical leadership. Got a small raise too. Hard work is being noticed.", mood: "😄", tags: ["work", "goals"], isPinned: true),
        MockEntry(daysAgo: 28, hour: 18, text: "Celebrated with dinner at my favorite restaurant. Treated myself without guilt. It's important to acknowledge wins, big and small.", mood: "😄", tags: ["social", "personal", "finance"], isPinned: false),

        // Day 30
        MockEntry(daysAgo: 30, hour: 9, text: "First day of the month — setting intentions. Top 3 goals: ship the new feature, maintain gym consistency, read 2 books. Writing them down makes them feel real.", mood: "😊", tags: ["goals", "personal"], isPinned: true),
        MockEntry(daysAgo: 30, hour: 15, text: "Organized my workspace. Decluttered the desk, cleaned the monitor, sorted cables. A tidy space really does lead to a tidier mind.", mood: "😊", tags: ["personal"], isPinned: false),
        MockEntry(daysAgo: 30, hour: 20, text: "Evening yoga session. My flexibility is slowly improving. The instructor said something that stuck with me: 'Progress isn't always visible, but it's always happening.'", mood: "😊", tags: ["health", "personal"], isPinned: false),
    ]

    /// Remove all seeded data and reset the flag.
    static func reset() {
        UserDefaults.standard.removeObject(forKey: seededKey)
    }
}
