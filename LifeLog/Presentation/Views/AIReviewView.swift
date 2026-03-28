import SwiftUI

struct AIReviewView: View {
    @State private var viewModel: StatsViewModel
    private var lang = LanguageManager.shared

    init(viewModel: StatsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                aiSection(
                    title: lang.localizedString("ai.journalReview"),
                    content: viewModel.journalReview,
                    isLoading: viewModel.isLoadingReview,
                    action: { viewModel.generateJournalReview() }
                )

                aiSection(
                    title: lang.localizedString("ai.weeklyReport"),
                    content: viewModel.weeklyReport,
                    isLoading: viewModel.isLoadingWeekly,
                    action: { viewModel.generateWeeklyReport() }
                )

                aiSection(
                    title: lang.localizedString("ai.monthlyReport"),
                    content: viewModel.monthlyReport,
                    isLoading: viewModel.isLoadingMonthly,
                    action: { viewModel.generateMonthlyReport() }
                )
            }
            .padding()
        }
        .navigationTitle(lang.localizedString("ai.title"))
    }

    private func aiSection(title: String, content: String?, isLoading: Bool, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            if isLoading {
                HStack {
                    ProgressView()
                    Text(lang.localizedString("ai.analyzing"))
                        .foregroundStyle(.secondary)
                }
            } else if let content {
                Text(content)
                    .font(.body)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Button(action: action) {
                    Label(lang.localizedString("ai.generate"), systemImage: "sparkles")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
