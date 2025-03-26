//
//  SessionsView.swift
//  SmartStudyCompanion
//


import SwiftUI
import CoreData

struct SessionsView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \StudySession.timestamp, ascending: false)], animation: .default)
    private var sessions: FetchedResults<StudySession>
   
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Stats")) {
                    Text("Total Sessions: \(sessions.count)")
                    Text("Total Time: \(totalTime()) min")
                }
                Section(header: Text("AI Suggestion")) {
                    Text(suggestion())
                        .italic()
                }
                Section(header: Text("Recent Sessions")) {
                    ForEach(sessions.prefix(5)) { session in
                        HStack {
                            Text(session.subject ?? "Unknown")
                            Spacer()
                            Text("\(session.duration / 60) min")
                        }
                    }
                }
            }
            .navigationTitle("Study Stats")
        }
    }
   
    func totalTime() -> Int {
        sessions.reduce(0) { $0 + Int($1.duration) } / 60
    }
   
    func suggestion() -> String {
        let avgDuration = sessions.isEmpty ? 25 : (totalTime() / sessions.count)
        if avgDuration > 40 {
            return "Try shorter sessions (20-30 min) to stay focused."
        }else if avgDuration < 15 {
            return "Consider longer sessions (25-35 min) for deepr study."
        }else {
            return "Your \(avgDuration) min sessions are spot on!"
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
