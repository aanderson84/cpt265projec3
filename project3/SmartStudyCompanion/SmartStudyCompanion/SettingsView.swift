//
//  SettingsView.swift
//  SmartStudyCompanion
//




import SwiftUI
//This is just a rough draft of the idea for the sounds, what I want to do is use a case statement, depending on which case(Sound) is picked, itll change a value on the content view, which is where i think the module will come in handy. On the ContentView, ill have another case statement, with a variable that changes URL depending on the value that was pulled from the module
struct SettingsView: View {
    @State var selection = 0
    
    let sounds = ["sound 1", "sound 2", "sound 3"]
    var body: some View {
        VStack  {
            Picker(selection: $selection, label: Text("Sounds")) {
                ForEach(0..<sounds.count) { index in
                    Text(self.sounds[index]).tag(index)
                }
            }
            Text("Selected Sound: \(sounds[selection])")
                .padding(.bottom, 70 )
            
        }
    }
}

            
           
#Preview {
    SettingsView()
}
