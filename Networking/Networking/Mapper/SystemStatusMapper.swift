import Foundation

/// Mapper: System Status
///
struct SystemStatusMapper: Mapper {

    /// Site Identifier associated to the system plugins that will be parsed.
    /// We're injecting this field via `JSONDecoder.userInfo` because the remote endpoints don't return the SiteID in the system plugin endpoint.
    ///
    let siteID: Int64

    /// (Attempts) to convert a dictionary into [SystemPlugin].
    ///
    func map(response: Data) throws -> [SystemPlugin] {
        let decoder = JSONDecoder()
        decoder.userInfo = [
            .siteID: siteID
        ]

        let systemStatus = try decoder.decode(SystemStatusEnvelope.self, from: response).systemStatus

        /// For now, we're going to override the networkActivated Bool in each plugin to convey active or inactive -- in order to
        /// avoid a core data change to add a Bool for activated
        /// This will be undone in #5269
        let activePlugins = systemStatus.activePlugins.map {
            $0.overrideNetworkActivated(isNetworkActivated: true)
        }
        let inactivePlugins = systemStatus.inactivePlugins.map {
            $0.overrideNetworkActivated(isNetworkActivated: false)
        }

        return activePlugins + inactivePlugins
    }
}

/// System Status endpoint returns the requested account in the `data` key. This entity
/// allows us to parse it with JSONDecoder.
///
private struct SystemStatusEnvelope: Decodable {
    let systemStatus: SystemStatus

    private enum CodingKeys: String, CodingKey {
        case systemStatus = "data"
    }
}
