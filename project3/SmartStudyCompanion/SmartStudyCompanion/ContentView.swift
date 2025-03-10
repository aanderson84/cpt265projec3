import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var timeRemaining = 25 * 60 // default is 25 minutes
    @State private var isActive = false
    @State private var isBreak = false
    @State private var customMinutes = "25"
    @State private var subject = "General"
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.2) // Fixed opacity issue
                        .foregroundColor(.gray)
                    Circle()
                        .trim(from: 0.0, to: CGFloat(1.0 - Double(timeRemaining) / (25.0 * 60)))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .foregroundColor(isBreak ? .blue : .green)
                        .rotationEffect(.degrees(-90))
                    Text(timeString(time: timeRemaining))
                        .font(.system(size: 50, weight: .bold))
                }
                .frame(width: 200, height: 200)
                
                // Controls
                HStack(spacing: 20) {
                    Button(action: { startTimer() }) {
                        Text("Start")
                            .font(.title2)
                            .padding() // Fixed padding typo
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    Button(action: { stopTimer() }) {
                        Text("Stop")
                            .font(.title2)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                Button("Reset") { resetTimer() }
                    .font(.title3)
                
                // Custom Input
                HStack {
                    TextField("Minutes", text: $customMinutes)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                    TextField("Subject", text: $subject)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
            }
            
            NavigationLink(destination: StatsView()) {
                Text("View Stats")
                    .font(.title3)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule()) // Fixed typo here
            }
        }
        .navigationTitle("Smart Study")
        .onReceive(timer) { _ in
            if isActive && timeRemaining > 0 {
                timeRemaining -= 1
            } else if isActive && timeRemaining == 0 {
                endSession()
            }
        }
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        if let minutes = Int(customMinutes), minutes > 0 {
            timeRemaining = minutes * 60
        }
        isActive = true
    }
    
    func stopTimer() {
        isActive = false
    }
    
    func resetTimer() {
        isActive = false
        timeRemaining = (Int(customMinutes) ?? 25) * 60
        isBreak = false
    }
    
    func endSession() {
        isActive = false
        saveSession()
        if !isBreak {
            // Start 5 minute Break
            isBreak = true
            timeRemaining = 5 * 60
            isActive = true
        } else {
            isBreak = false
            timeRemaining = (Int(customMinutes) ?? 25) * 60
        }
    }
    
    func saveSession() {
        let newSession = StudySession(context: viewContext)
        newSession.timestamp = Date()
        newSession.duration = Int32(isBreak ? 5 * 60 : (Int(customMinutes) ?? 25) * 60)
        newSession.subject = subject
        newSession.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save session: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
