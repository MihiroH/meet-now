import SwiftUI

struct SettingsView: View {
    @AppStorage("reminderOffset") private var reminderOffset: Double = 5.0
    
    var body: some View {
        Form {
            Section(header: Text("General")) {
                Picker("Remind me:", selection: $reminderOffset) {
                    Text("At time of event").tag(0.0)
                    Text("1 minute before").tag(1.0)
                    Text("3 minutes before").tag(3.0)
                    Text("5 minutes before").tag(5.0)
                    Text("10 minutes before").tag(10.0)
                    Text("15 minutes before").tag(15.0)
                }
                .pickerStyle(MenuPickerStyle())
                
                Text("The overlay will appear this many minutes before your meeting starts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 350, height: 150)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
