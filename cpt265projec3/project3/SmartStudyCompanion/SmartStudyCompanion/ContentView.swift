import SwiftUI
import CoreData
import AVKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var timeRemaining = 25 * 60
    @State private var initialTime = 25 * 60
    @State private var isActive = false
    @State private var isBreak = false
    @State private var customMinutes = "25"
    @State private var subject = "General"
    @State private var isLarge = false
    @State private var showAlert = false
    @State private var showAchievements = false
    @State private var totalMinutes = 0
    @AppStorage("selectedSound") private var selectedSound = "Badum-tss.mp3"
    @State private var isPaused = false
    @State private var pauseTimeRemaining = 5 * 60
    @State private var pauseInitialTime = 5 * 60

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Computed properties to simplify timer values
    private var currentTime: Int {
        isPaused ? pauseTimeRemaining : timeRemaining
    }
    private var currentInitialTime: Int {
        isPaused ? pauseInitialTime : initialTime
    }
    private var progressFraction: CGFloat {
        CGFloat(1.0 - Double(currentTime) / Double(currentInitialTime))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Image("Background")
                    .resizable()
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fill)
                VStack(spacing: 20) {
                    Text("Smart Study Companion")
                        .font(.system(size: 25))
                        .bold()
                        .foregroundColor(.black)
                        .kerning(2)
                        .multilineTextAlignment(.center)
                        .scaleEffect(x: 1, y: 1.5)
                        .padding(.vertical, -7)
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.5)
                            .foregroundColor(.white)
                        Circle()
                            .trim(from: 0.0, to: progressFraction)
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text(timeString(time: currentTime))
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(Color(red: 0.0, green: 0.0, blue: 0.5))
                    }
                    .frame(width: 200, height: 200)
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: { startTimer() }) {
                            Text("Start")
                                .font(.title3)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay(Rectangle().stroke(Color(red: 0.0, green: 0.0, blue: 0.55), lineWidth: 10))
                        }
                        .frame(width: 100)
                        Button(action: { stopTimer() }) {
                            Text("Stop")
                                .font(.title3)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay(Rectangle().stroke(Color(red: 0.0, green: 0.0, blue: 0.55), lineWidth: 10))
                        }
                        .frame(width: 100)
                        Button(action: { resetTimer() }) {
                            Text("Reset")
                                .font(.title3)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay(Rectangle().stroke(Color(red: 0.0, green: 0.0, blue: 0.55), lineWidth: 10))
                        }
                        .frame(width: 100)
                    }
                    Spacer()
                    HStack {
                        TextField("Minutes", text: $customMinutes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                        TextField("Subject", text: $subject)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                    }
                    .padding(.horizontal)
                    HStack(spacing: 30) {
                        Button(action: { saveSession() }) {
                            Text("Record Session")
                                .font(.title3)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay(Rectangle().stroke(Color(red: 0.0, green: 0.0, blue: 0.55), lineWidth: 10))
                        }
                        .frame(width: 200)
                        Button(action: { pauseSession() }) {
                            Text(isPaused ? "Resume" : "Pause Session")
                                .font(.title3)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay(Rectangle().stroke(Color(red: 0.0, green: 0.0, blue: 0.55), lineWidth: 10))
                        }
                        .frame(width: 200)
                    }
                    Spacer()
                    HStack(spacing: 80) {
                        NavigationLink(destination: SessionsView()) {
                            Text("Sessions")
                                .font(.title3)
                                .padding()
                                .foregroundColor(.white)
                        }
                        NavigationLink(destination: AchievementsView()) {
                            Text("Achievements")
                                .font(.title3)
                                .padding()
                                .foregroundColor(.white)
                        }
                        NavigationLink(destination: SettingsView()) {
                            Text("Settings")
                                .font(.title3)
                                .padding()
                                .foregroundColor(.white)
                        }
                    }
                    .background(Color(red: 0.0, green: 0.0, blue: 0.55))
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .onReceive(timer) { _ in
                        if isActive && !isPaused && timeRemaining > 0 {
                            timeRemaining -= 1
                        } else if isActive && !isPaused && timeRemaining == 0 {
                            endSession()
                        } else if isActive && isPaused && pauseTimeRemaining > 0 {
                            pauseTimeRemaining -= 1
                        } else if isActive && isPaused && pauseTimeRemaining == 0 {
                            resumeSession()
                        }
                    }
                    Spacer()
                }
            }
        }
    }

    class SoundManager {
        static let instance = SoundManager()
        var player: AVAudioPlayer?

        func playSound(soundFileName: String) {
            print("Attempting to play: Sounds/\(soundFileName)") // Debug
            guard let url = Bundle.main.url(forResource: "Sounds/\(soundFileName)", withExtension: nil) else {
                print("Sound file 'Sounds/\(soundFileName)' not found in bundle.")
                return
            }
            print("Found URL: \(url)") // Debug
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
                player?.play()
                print("Playing sound")
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }

    func startTimer() {
        if let minutes = Int(customMinutes), minutes > 0 {
            timeRemaining = minutes * 60
            initialTime = minutes * 60
        }
        isActive = true
    }

    func stopTimer() {
        isActive = false
        saveSession()
    }

    func resetTimer() {
        isActive = false
        timeRemaining = (Int(customMinutes) ?? 25) * 60
        initialTime = timeRemaining
        isBreak = false
        isPaused = false
        pauseTimeRemaining = 5 * 60
        pauseInitialTime = 5 * 60
    }

    func endSession() {
        isActive = false
        saveSession()
        SoundManager.instance.playSound(soundFileName: selectedSound)
        if !isBreak {
            isBreak = true
            timeRemaining = 5 * 60
            initialTime = 5 * 60
            isActive = true
        } else {
            isBreak = false
            timeRemaining = (Int(customMinutes) ?? 25) * 60
            initialTime = timeRemaining
        }
    }

    func saveSession() {
        let newSession = StudySession(context: viewContext)
        newSession.timestamp = Date()
        let elapsedTime = isBreak ? (5 * 60 - timeRemaining) : (initialTime - timeRemaining)
        newSession.duration = Int32(elapsedTime)
        newSession.subject = subject
        newSession.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        do {
            try viewContext.save()
        } catch {
            print("Failed to save session: \(error)")
        }
    }

    func pauseSession() {
        if isActive && !isPaused {
            isPaused = true
            pauseTimeRemaining = 5 * 60
            pauseInitialTime = 5 * 60
        } else if isPaused {
            resumeSession()
        }
    }

    func resumeSession() {
        isPaused = false
        SoundManager.instance.playSound(soundFileName: "minecraft-villager-sound.mp3")
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
