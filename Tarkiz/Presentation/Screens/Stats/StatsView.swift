import SwiftUI
import Combine

// MARK: - Data Models

struct WeekDay: Identifiable {
    let id = UUID()
    let day: String
    let date: Int
    let value: Double // 0..1 normalized
}

struct SessionDay: Identifiable {
    let id = UUID()
    let label: String
    let hours: Int
    let minutes: Int
    let sessions: Int
    var isToday: Bool = false

    var totalMinutes: Int { hours * 60 + minutes }
    var progressFraction: Double { min(Double(totalMinutes) / 120.0, 1.0) }
}

// MARK: - StatsViewModel

class StatsViewModel: ObservableObject {
    let weekDays: [WeekDay] = [
        WeekDay(day: "MON", date: 27, value: 0),
        WeekDay(day: "TUE", date: 28, value: 0),
        WeekDay(day: "WED", date: 29, value: 0.2),
        WeekDay(day: "THU", date: 30, value: 0.5),
        WeekDay(day: "FRI", date: 31, value: 0.8),
        WeekDay(day: "SAT", date: 1,  value: 0.3),
        WeekDay(day: "SUN", date: 2,  value: 0),
    ]

    let avgTime = (hours: 1, minutes: 45)

    let sessionHistory: [SessionDay] = [
        SessionDay(label: "TODAY", hours: 0, minutes: 35, sessions: 2, isToday: true),
        SessionDay(label: "THU, JAN 30", hours: 1, minutes: 15, sessions: 3),
        SessionDay(label: "WED, JAN 29", hours: 0, minutes: 45, sessions: 2),
    ]
}

// MARK: - StatsView

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Text("Weekly Activity")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appForeground)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appMutedForeground)
                            }
                            Text("THIS WEEK")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appMutedForeground)
                                .tracking(1)
                        }
                        .padding(.top, 32)

                        // Avg Time
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Avg Protected Time")
                                .font(.system(size: 14))
                                .foregroundColor(.appMutedForeground)
                            Text("\(viewModel.avgTime.hours)h \(viewModel.avgTime.minutes)m")
                                .font(.system(size: 48, weight: .bold))
                                .tracking(-1)
                                .foregroundColor(.appForeground)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)

                        // Weekly Chart
                        WeeklyChart(days: viewModel.weekDays)
                            .frame(height: 192)
                            .padding(.horizontal, 24)

                        // Session History
                        VStack(spacing: 12) {
                            ForEach(viewModel.sessionHistory) { session in
                                SessionCard(session: session)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Weekly Chart

struct WeeklyChart: View {
    let days: [WeekDay]
    private let maxBarHeight: CGFloat = 120

    var body: some View {
        ZStack(alignment: .bottom) {
            // Grid lines
            VStack {
                gridLine(label: "2h")
                Spacer()
                gridLine(label: "1h")
                Spacer()
                gridLine(label: "30m")
                Spacer()
                Divider().background(Color.appMutedForeground.opacity(0.2))
            }

            // Bars + labels
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(days) { day in
                    VStack(spacing: 8) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.appPrimary.opacity(0.8))
                            .frame(width: 12, height: max(day.value * maxBarHeight, day.value > 0 ? 8 : 0))

                        VStack(spacing: 2) {
                            Text(day.day)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.appMutedForeground)
                            Text("\(day.date)")
                                .font(.system(size: 11))
                                .foregroundColor(.appMutedForeground)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 0)
        }
    }

    private func gridLine(label: String) -> some View {
        HStack {
            Divider()
                .frame(height: 1)
                .background(Color.appMutedForeground.opacity(0.2))
                .overlay(
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                        .foregroundColor(.appMutedForeground.opacity(0.2))
                )
            Spacer()
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.appMutedForeground)
        }
    }
}

// MARK: - Session Card

struct SessionCard: View {
    let session: SessionDay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if session.isToday {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
                Text(session.label)
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1)
                    .foregroundColor(.appMutedForeground)
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(session.hours)h \(session.minutes)m")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appForeground)
                    Text("\(session.sessions) session\(session.sessions != 1 ? "s" : "")")
                        .font(.system(size: 14))
                        .foregroundColor(.appMutedForeground)
                }
                Spacer()
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appSecondary)
                        .frame(width: 128, height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appMutedForeground.opacity(0.3))
                        .frame(width: 128 * session.progressFraction, height: 6)
                }
            }
        }
        .padding(20)
        .background(Color.appSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
