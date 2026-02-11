import SwiftUI

struct SettingsView: View {
    @AppStorage("reminderOffset") private var reminderOffset: Double = 5.0
    
    var body: some View {
        Form {
            Section {
                LabeledContent {
                    Picker("", selection: $reminderOffset) {
                        Text("At time of event").tag(0.0)
                        Text("1 minute before").tag(1.0)
                        Text("3 minutes before").tag(3.0)
                        Text("5 minutes before").tag(5.0)
                        Text("10 minutes before").tag(10.0)
                        Text("15 minutes before").tag(15.0)
                    }
                    .labelsHidden()
                    .fixedSize()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reminder Time")
                                .font(.headline)
                        }
                    }
                }
            } footer: {
                Text("MeetNow will show a full-screen overlay this many minutes before your meeting starts to make sure you're never late.")
                    .padding(.top, 8)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 150)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
