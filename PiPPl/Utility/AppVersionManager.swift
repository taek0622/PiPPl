//
//  AppVersionManager.swift
//  PiPPl
//
//  Created by 김민택 on 4/11/24.
//

import Foundation

class AppVersionManager: ObservableObject {
    @Published var updateState = UpdateState.latest
    @Published var isUpdateAlertOpened = false

    let iTunesID: String
    let downloadedAppVersion: Version

    init() {
        if let filePath = Bundle.main.path(forResource: "Properties", ofType: "plist"),
           let property = NSDictionary(contentsOfFile: filePath),
           let iTunesID = property["iTunesID"] as? String {
            self.iTunesID = iTunesID
        } else { self.iTunesID = "" }

        if let downloadedVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let versions = Version(downloadedVersionString) {
            self.downloadedAppVersion = versions
        } else { self.downloadedAppVersion = .init(0, 0, 0) }
    }

    func checkNewUpdate() async -> UpdateState {
        guard let requireVersion = try? await requestRequiredVersion() else { return . latest }
        guard let latestAppStoreVersion = try? await requestLatestAppStoreVersion() else { return .latest }

        if downloadedAppVersion >= latestAppStoreVersion {
            return .latest
        } else if requireVersion > downloadedAppVersion || latestAppStoreVersion.major > downloadedAppVersion.major || (latestAppStoreVersion.major == downloadedAppVersion.major && latestAppStoreVersion.minor > downloadedAppVersion.minor + 4) || (latestAppStoreVersion.major == downloadedAppVersion.major && latestAppStoreVersion.minor == downloadedAppVersion.minor && latestAppStoreVersion.patch > downloadedAppVersion.patch + 8) {
            return .required
        } else if (latestAppStoreVersion.major == downloadedAppVersion.major && latestAppStoreVersion.minor > downloadedAppVersion.minor + 2) || (latestAppStoreVersion.major == downloadedAppVersion.major && latestAppStoreVersion.minor == downloadedAppVersion.minor && latestAppStoreVersion.patch > downloadedAppVersion.patch + 4) {
            return .recommended
        }

        return .available
    }

    private func requestRequiredVersion() async throws -> Version {
        guard let url = URL(string: "https://raw.githubusercontent.com/taek0622/Version/refs/heads/main/PiPPl.json") else { return .init(major: 0, minor: 0, patch: 0) }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
              let requiredVersionString = json["requiredVersion"] as? String,
              let requiredVersion = Version(requiredVersionString)
        else { return .init(0, 0, 0) }

        return requiredVersion
    }

    private func requestLatestAppStoreVersion() async throws -> Version {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(iTunesID)")
        else { return .init(0, 0, 0) }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let latestAppStoreVersionString = results[0]["version"] as? String,
              let latestAppStoreVersion = Version(latestAppStoreVersionString)
        else { return .init(0, 0, 0) }

        return latestAppStoreVersion
    }
}
