import SwiftUI
import CoreData

struct AchievementsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySession.timestamp, ascending: true)],
        animation: .default)
    private var sessions: FetchedResults<StudySession>
    
    var totalStudyTime: Int32 { //Total Seconds
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var longestSession: Int32 { //Seconds
        sessions.map { $0.duration }.max() ?? 0
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.8, green: 0.2, blue: 0.2)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Achievements")
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 15) {
                        //Total MileStones
                        AchievementRow(title: "1 Hour Scholar", goal: 3600, progress: totalStudyTime, isRecord: false)
                        AchievementRow(title: "6 Hour Master", goal: 21600, progress: totalStudyTime, isRecord: false)
                        AchievementRow(title: "24 Hour Legend", goal: 86400, progress: totalStudyTime, isRecord: false)
                        
                        //Longest Session
                        AchievementRow(title: "Marathon Session", goal: 7200, progress: longestSession, isRecord: true)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.0, green: 0.0, blue: 0.55), lineWidth: 10)
                    .padding(10)
            )
        }
    }
}

struct AchievementRow: View {
    let title: String
    let goal: Int32 //Seconds
    let progress: Int32
    let isRecord: Bool
    
    var progressFraction: Double {
        min(Double(progress) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            if isRecord {
                Text("Record: \(timeString(seconds: progress))")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.yellow)
            }else {
                ProgressView(value: progressFraction)
                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                    .frame(height: 10)
                Text("\(timeString(seconds: progress)) / \(timeString(seconds: goal))")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
    
    func timeString(seconds: Int32) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

#Preview {
    AchievementsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
