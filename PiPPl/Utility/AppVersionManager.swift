//
//  AppVersionManager.swift
//  PiPPl
//
//  Created by 김민택 on 4/11/24.
//

import Foundation

    typealias Version = (major: Int, minor: Int, patch: Int)
class AppVersionManager: ObservableObject {

    static let shared = AppVersionManager()
    let iTunesID: String
    let downloadedAppVersion: Version

    private init() {
        if let filePath = Bundle.main.path(forResource: "Properties", ofType: "plist"),
           let property = NSDictionary(contentsOfFile: filePath),
           let iTunesID = property["iTunesID"] as? String {
            self.iTunesID = iTunesID
        } else { self.iTunesID = "" }

        if let downloadedVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let versions = downloadedVersionString.stringToVersion() {
            self.downloadedAppVersion = versions
        } else { self.downloadedAppVersion = (0, 0, 0) }
    }

    func checkNewUpdate() async -> UpdateState {
        guard let requireVersion = try? await requestRequiredVersion() else { return . latest }
        guard let latestAppStoreVersion = try? await requestLatestAppStoreVersion() else { return .latest }

        if downloadedAppVersion == latestAppStoreVersion {
            return .latest
        } else if requireVersion > downloadedAppVersion || latestAppStoreVersion.major > downloadedAppVersion.major || (latestAppStoreVersion.major == downloadedAppVersion.major && latestAppStoreVersion.minor > downloadedAppVersion.minor + 4) || (latestAppStoreVersion.major == downloadedAppVersion.major && latestAppStoreVersion.minor == downloadedAppVersion.minor && latestAppStoreVersion.patch > downloadedAppVersion.patch + 8) {
            return .required
        } else if (latestAppStoreVersion.major == downloadedAppVersion.major && latestAppStoreVersion.minor > downloadedAppVersion.minor + 2) || (latestAppStoreVersion.major == downloadedAppVersion.major && latestAppStoreVersion.minor == downloadedAppVersion.minor && latestAppStoreVersion.patch > downloadedAppVersion.patch + 4) {
            return .recommended
        }
        print(requireVersion, latestAppStoreVersion, downloadedAppVersion)

        return .available
    }

    private func requestRequiredVersion() async throws -> Version {
        guard let url = URL(string: "https://raw.githubusercontent.com/taek0622/Version/refs/heads/main/PiPPl.json") else { return (0, 0, 0) }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
              let requiredVersionString = json["requiredVersion"] as? String,
              let requiredVersion = requiredVersionString.stringToVersion()
        else { return (0, 0, 0) }

        return requiredVersion
    }

    private func requestLatestAppStoreVersion() async throws -> Version {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(iTunesID)")
        else { return (0, 0, 0) }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let latestAppStoreVersionString = results[0]["version"] as? String,
              let latestAppStoreVersion = latestAppStoreVersionString.stringToVersion()
        else { return (0, 0, 0) }

        return latestAppStoreVersion
    }
}

extension String {
    func stringToVersion() -> (major: Int, minor: Int, patch: Int)? {
        let versions = self.split(separator: ".").map { Int($0)! }
        guard versions.count >= 3 else { return nil }
        return (versions[0], versions[1], versions[2])
    }
}
