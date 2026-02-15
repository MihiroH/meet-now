import Foundation
import ServiceManagement

class LaunchAtLoginManager: ObservableObject {
    @Published var isEnabled: Bool = false {
        didSet {
            updateService()
        }
    }

    init() {
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    private func updateService() {
        let service = SMAppService.mainApp

        if isEnabled {
            if service.status != .enabled {
                do {
                    try service.register()
                } catch {
                    print("Failed to register login item: \(error)")
                    // Reset on failure to reflect actual state
                    DispatchQueue.main.async {
                        self.isEnabled = false
                    }
                }
            }
        } else {
            if service.status == .enabled {
                do {
                    try service.unregister()
                } catch {
                    print("Failed to unregister login item: \(error)")
                    // Reset on failure
                    DispatchQueue.main.async {
                        self.isEnabled = true
                    }
                }
            }
        }
    }
}
