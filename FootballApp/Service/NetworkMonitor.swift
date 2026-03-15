import Foundation
import Network
import Combine

/// Monitors network connectivity status
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.dipoddi.NetworkMonitor")

    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown

        var description: String {
            switch self {
            case .wifi: return "WiFi"
            case .cellular: return "Cellular"
            case .ethernet: return "Ethernet"
            case .unknown: return "Unknown"
            }
        }
    }

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.getConnectionType(path) ?? .unknown
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        }
        return .unknown
    }

    /// Check if connected to the internet
    var isOnline: Bool {
        isConnected
    }

    /// Check if on WiFi (good for large downloads)
    var isOnWiFi: Bool {
        connectionType == .wifi
    }

    /// Check if on cellular (may want to limit data usage)
    var isOnCellular: Bool {
        connectionType == .cellular
    }
}

// MARK: - Connectivity Alert Helper
extension NetworkMonitor {
    /// Returns a localized message for no connection
    var noConnectionMessage: String {
        "network.no_connection".localizedString
    }

    /// Returns a localized message for connection restored
    var connectionRestoredMessage: String {
        "network.connection_restored".localizedString
    }
}
