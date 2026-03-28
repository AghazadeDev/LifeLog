import SwiftUI

struct CalendarGridView: View {
    let calendarData: [Date: Int]
    let days: [DayEntry]
    var onDaySelected: ((DayEntry) -> Void)?

    @State private var displayedMonth = Calendar.current.startOfDay(for: .now)
    private var lang = LanguageManager.shared
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    init(calendarData: [Date: Int], days: [DayEntry], onDaySelected: ((DayEntry) -> Void)? = nil) {
        self.calendarData = calendarData
        self.days = days
        self.onDaySelected = onDaySelected
    }

    var body: some View {
        VStack(spacing: 12) {
            monthHeader
            weekdayHeader
            daysGrid
        }
        .padding(.horizontal)
    }

    private var monthHeader: some View {
        HStack {
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.headline)
            Spacer()
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        let daysInMonth = daysForMonth()
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(daysInMonth, id: \.self) { date in
                if let date {
                    dayCell(for: date)
                } else {
                    Text("")
                        .frame(height: 36)
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let startOfDay = calendar.startOfDay(for: date)
        let count = calendarData[startOfDay] ?? 0
        let isToday = calendar.isDateInToday(date)

        return Button {
            if let day = days.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                onDaySelected?(day)
            }
        } label: {
            Text("\(calendar.component(.day, from: date))")
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .frame(width: 36, height: 36)
                .background(heatColor(for: count))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isToday ? Color.accentColor : .clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func heatColor(for count: Int) -> Color {
        switch count {
        case 0: return Color(.systemGray6)
        case 1: return .green.opacity(0.2)
        case 2...3: return .green.opacity(0.4)
        case 4...5: return .green.opacity(0.6)
        default: return .green.opacity(0.8)
        }
    }

    private func daysForMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDay) - calendar.firstWeekday
        let offset = (firstWeekday + 7) % 7

        var result: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                result.append(date)
            }
        }
        return result
    }
}
