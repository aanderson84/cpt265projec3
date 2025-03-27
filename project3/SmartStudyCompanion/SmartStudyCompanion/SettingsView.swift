//
//  SettingsView.swift
//  SmartStudyCompanion
//




import SwiftUI
//This is just a rough draft of the idea for the sounds, what I want to do is use a case statement, depending on which case(Sound) is picked, itll change a value on the content view, which is where i think the module will come in handy. On the ContentView, ill have another case statement, with a variable that changes URL depending on the value that was pulled from the module
struct SettingsView: View {
    @AppStorage("selectedSound") private var selectedSound = "Badum-tss.mp3"
    //List of the sound files
    let soundOptions = [
        "Badum-tss.mp3",
        "bear-sound.mp3",
        "action-game-music-background.mp3",
        "ding-sound-effect-download.mp3",
        "farm-cow-sound-effect.mp3",
        "sad-violin-sound-effect.mp3",
        "ship-siren-sound.mp3",
        "low-beep-tone.mp3",
        "tinkling-bells-sound-effect.mp3",
        "miniature-bell-chime-sound-effect.mp3",
        "minecraft-villager-sound.mp3"
    ]
    
    var body: some View{
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Picker("Timer Sound", selection: $selectedSound) {
                ForEach(soundOptions, id: \.self) {sound in
                    Text(sound.replacingOccurrences(of: ".mp3|.wav|.m4a", with: "", options: .regularExpression))
                        .tag(sound)
                }
            }
            .pickerStyle(.menu)
            .padding()
            
            Spacer()
        }
        .background(Color.blue.opacity(0.1))
    }
}
