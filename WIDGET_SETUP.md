# Widget Setup Instructions

The widget files are in `LifeLogWidget/`. To add the widget target in Xcode:

## Steps

1. **Add Widget Target**
   - File → New → Target → Widget Extension
   - Name: `LifeLogWidget`
   - Uncheck "Include Configuration App Intent"
   - Click Finish

2. **Replace Generated Files**
   - Delete the auto-generated Swift files in the new target
   - Add the files from `LifeLogWidget/` to the widget target

3. **Add App Groups Capability** (both targets)
   - Select the **LifeLog** main target → Signing & Capabilities → + App Groups
   - Add: `group.com.lifelog.shared`
   - Select the **LifeLogWidget** target → do the same

4. **Add Face ID Usage Description** (main target)
   - In Build Settings, add: `INFOPLIST_KEY_NSFaceIDUsageDescription = "LifeLog uses Face ID to protect your journal"`

5. **Enable iCloud** (main target)
   - Signing & Capabilities → + iCloud → check CloudKit
   - Use the default container

## How Widget Data Works

The main app writes stats to the shared `UserDefaults(suiteName: "group.com.lifelog.shared")`:
- `widget_today_count` — number of entries today
- `widget_current_streak` — current streak days
- `widget_dominant_mood` — today's dominant mood emoji

You need to add this code to `JournalUseCase` after saving:

```swift
func updateWidgetData() {
    let defaults = UserDefaults(suiteName: "group.com.lifelog.shared")
    defaults?.set(fetchTodayNotes().count, forKey: "widget_today_count")
    // Calculate and set streak and mood as needed
    WidgetCenter.shared.reloadAllTimelines()
}
```
