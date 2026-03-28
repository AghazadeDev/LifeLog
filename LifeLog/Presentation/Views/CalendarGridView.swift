import SwiftUI

struct CalendarGridView: View {
    let calendarData: [Date: Int]
    let days: [DayEntry]
    var onDaySelected: ((DayEntry) -> Void)?

    @State private var displayedMonth = Calendar.current.startOfDay(for: .now)
    private var lang = LanguageManager.shared
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    init(calendarData: [Date: Int], days: [DayEntry], onDaySelected: ((DayEntry) -> Void)? = nil) {
        self.calendarData = calendarData
        self.days = days
        self.onDaySelected = onDaySelected
    }

    var body: some View {
        VStack(spacing: 12) {
            monthHeader
                .padding(.bottom, 4)
            weekdayHeader
            daysGrid
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var monthHeader: some View {
        HStack {
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
            }
            Spacer()
            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.headline)
            Spacer()
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
            }
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2.weight(.medium))
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
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
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
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(count > 0 ? .white : .primary)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(cellColor(count: count, isToday: isToday))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isToday ? Color.accentColor : .clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func cellColor(count: Int, isToday: Bool) -> Color {
        switch count {
        case 0: return .clear
        case 1: return .green.opacity(0.25)
        case 2...3: return .green.opacity(0.45)
        case 4...5: return .green.opacity(0.65)
        default: return .green.opacity(0.85)
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
