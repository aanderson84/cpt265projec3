import SwiftUI
import CoreData
import AVKit


//I will be working on the achievements page tomorrow 3-26-25, I am all worked out today, still leave the achievements to me, I will also still code the sounds for the timers more tomorrow, just need to look more into it.
//If you have any design ideas for the separate pages, let me know
//I was struggling with the loading screen but my brain is fried, ive been coding since 9pm last night so I will fix it tomorrow
//I dont know the pros and cons between using coredata or a module to transfer data, but look into the module one, it seems very simple, only problem is that i dont think it saves after app is closed.
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var timeRemaining = 25 * 60 // default is 25 minutes
    @State private var initialTime = 25 * 60 // Added to start tracking time
    @State private var isActive = false
    @State private var isBreak = false
    @State private var customMinutes = "25"
    @State private var subject = "General"
    @State private var isLarge = false
    //pause button function, it says pause but I see that it is redundant with the stop button, maybe make it a new alert that has a 5 minute timer, this will have 1 default sound
    @State private var showAlert = false
    @State private var showAchievements = false
    //this is going to be used to track achievements, I believe that im going to use a module and transfer data onto that so that the achievements view can access values on the ContentView
    @State private var totalMinutes = 0
    //beginning of the soundManager
    //was watching a video on it but what i want to do when the timer hits 0, sound is played.
    //using a picker view on the settings view i believe would be best, i already did a small demo
    class SoundManager{
        static let instance = SoundManager()
        
        var player: AVAudioPlayer?
        
        func playSound() {
            
            guard let url = URL(string: "") else {
                return
            }
            do{
                
                
                player =  try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch let error {
                print("Error playing sound. \(error.localizedDescription)")
            }
        }
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        NavigationView {
            ZStack{
                Image("Background")
                    .resizable()
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fill)
                VStack(spacing:20) {
                    Text("Smart Study Companion")
                    
                        .font(.system( size: 25))
                        .bold()
                        .foregroundColor(.black)
                        .kerning(2)
                        .multilineTextAlignment(.center)
                        .scaleEffect(x: 1, y:1.5)
                        .padding(.vertical, -7)
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(lineWidth:20)
                            .opacity(0.5)
                            .foregroundColor(.white)
                        Circle()
                            .trim(from:0.0, to:CGFloat(1.0 - Double(timeRemaining)/(25.0 * 60)))
                            .stroke(style: StrokeStyle(lineWidth:20, lineCap:.round))
                            .rotationEffect(.degrees(-90))
                        Text(timeString(time: timeRemaining))
                            .font(.system(size:50, weight: .bold))
                            .foregroundColor(Color(red: 0.0, green: 0.0, blue:0.5))
                    }
                    .frame(width:200, height:200)
                    Spacer()
                    //control buttons
                    HStack (spacing:20){
                        Button(action: {startTimer()}) {
                            Text("Start")
                                .font(.title2)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay (
                                    Rectangle()
                                    //The color below was the closest to the blue i could get that was somewhat correct, this is the rgb filter for it
                                        .stroke(Color(red:0.0,green:0.0, blue:0.55), lineWidth: 10)
                                )
                        }
                        Button(action: {stopTimer()}) {
                            Text("Stop")
                                .font(.title2)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay (
                                    Rectangle()
                                        .stroke(Color(red:0.0,green:0.0, blue:0.55), lineWidth: 10)
                                )
                        }
                        Button(action: {resetTimer()}) {
                            Text("Reset")
                                .font(.title3)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay (
                                    Rectangle()
                                        .stroke(Color(red:0.0,green:0.0, blue:0.55), lineWidth: 10)
                                )
                        }
                    }
                    Spacer()
                    //Inputs
                    HStack{
                        TextField("Minutes", text:$customMinutes)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width:80)
                            .foregroundColor(.black)
                            .overlay (
                                Rectangle()
                                    .stroke(Color(red: 0.0, green: 0.0, blue: 0.55), lineWidth: 10)
                            )
                        TextField("Subject", text: $subject)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay (
                                Rectangle()
                                    .stroke(Color(red: 0.0, green: 0.0, blue: 0.55), lineWidth: 10)
                            )
                    }
                    .padding(.horizontal)
                    HStack(spacing: 30 ) {
                        Button(action: {saveSession()}) {
                            Text("Record Session")
                                .font(.title3)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay (
                                    Rectangle()
                                        .stroke(Color(red:0.0,green:0.0, blue:0.55), lineWidth: 10)
                                )
                        }
                        .frame(width: 209)
                        //not exactly symmetric
                        Button(action: {pauseSession()}) {
                            Text("Pause Session")
                                .font(.title3)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Rectangle())
                                .overlay (
                                    Rectangle()
                                        .stroke(Color(red:0.0,green:0.0, blue:0.55), lineWidth: 10)
                                )
                        }
                        .frame(width: 200)
                        //here is the alert,  should be able to add a 5 minute time to display here, and the okay button only become visible after the timer reaches 0
                        .alert("Break TIME!", isPresented: $showAlert) {
                            Button("OK", role: .cancel) {}
                        }
                }
                    Spacer()
                    //Navigation bar at the bottom of the screen, only thing that is distastful is the method that the pages change, so the sessions one on the left kinda just pops up, the other two change to a whole new view. Its because its using core data, another way to transfer data between views is by using a module, alot like c#
                    HStack (spacing: 80){
                        NavigationLink(destination: SessionsView()) {
                            Image(systemName: "list.bullet.rectangle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 50))
                                .padding(.horizontal, 10)
                            
                        }
                        NavigationLink(destination: AchievementsView()) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 50 ))
                                .padding(.horizontal, 10)
                                .frame(alignment: .center)
                        }
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 50))
                                .padding(.horizontal, 12)
                        }
                        .onReceive(timer) { _ in
                            if isActive && timeRemaining > 0 {
                                timeRemaining -= 1
                            }else if isActive && timeRemaining == 0 {
                                endSession()
                            }
                        }
                    }
                    .background(Color(red: 0.0, green: 0.0, blue: 0.55))
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    Spacer()
                    //ignore the bookmark i dont know how to get rid of it and im too many undos away to fix it
                }
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
            initialTime = minutes * 60 //Set intiial time when starting
        }
        isActive = true
    }
    
    func stopTimer() {
        isActive = false
        saveSession() // Option to save when stopping manually
    }
    
    func resetTimer() {
        isActive = false
        timeRemaining = (Int(customMinutes) ?? 25) * 60
        initialTime = timeRemaining // Reset Initial Time
        isBreak = false
    }
    
    func endSession() {
        isActive = false
        saveSession()
        if !isBreak {
            // Start 5 minute Break
            isBreak = true
            timeRemaining = 5 * 60
            initialTime = 5 * 60 // Set initial time for break
            isActive = true
        } else {
            isBreak = false
            timeRemaining = (Int(customMinutes) ?? 25) * 60
            initialTime = timeRemaining // Reset initial time for next study session.
        }
    }
    
    func pauseSession()  {
        showAlert = true
    }
    
    //when running the app, notice that it will record the customMinutes, instead of the customMinutes-duration, so if it is set to 25 minutes, it displays 25 minutes as the recorded time for the session no matter what
    func saveSession() {
            let newSession = StudySession(context: viewContext)
            newSession.timestamp = Date()
        //Calculate elapsed time: initialTime - timeRemaining
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
