//
//  AppVersionManager.swift
//  PiPPl
//
//  Created by 김민택 on 4/11/24.
//

import Foundation

class AppVersionManager {

    static let shared = AppVersionManager()
    var iTunesID: String {
        guard let filePath = Bundle.main.path(forResource: "Properties", ofType: "plist"),
              let property = NSDictionary(contentsOfFile: filePath),
              let iTunesID = property["iTunesID"] as? String
        else { return "" }

        return iTunesID
    }
    var downloadedAppVersion: String {
        guard let downloadedAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        return downloadedAppVersion
    }

    private init() {}

    func checkNewUpdate() async -> Bool {
        guard let latestAppStoreVersion = try? await getLatestAppStoreVersion() else { return false }

        let compareResult = downloadedAppVersion.compare(latestAppStoreVersion, options: .numeric)

        switch compareResult {
        case .orderedAscending:
            return true
        default:
            return false
        }
    }

    private func getLatestAppStoreVersion() async throws -> String {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(iTunesID)")
        else { return "" }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let latestAppStoreVersion = results[0]["version"] as? String
        else { return "" }

        return latestAppStoreVersion
    }
}
