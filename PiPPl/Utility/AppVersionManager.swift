//
//  AppVersionManager.swift
//  PiPPl
//
//  Created by 김민택 on 4/11/24.
//

import Foundation

class AppVersionManager {

    static let shared = AppVersionManager()
    let iTunesID: String
    let downloadedAppVersion: String

    private init() {
        if let filePath = Bundle.main.path(forResource: "Properties", ofType: "plist"),
           let property = NSDictionary(contentsOfFile: filePath),
           let iTunesID = property["iTunesID"] as? String {
            self.iTunesID = iTunesID
        } else { self.iTunesID = "" }

        self.downloadedAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    func checkNewUpdate() async -> Bool {
        guard let latestAppStoreVersion = try? await requestLatestAppStoreVersion() else { return false }

        let compareResult = downloadedAppVersion.compare(latestAppStoreVersion, options: .numeric)

        switch compareResult {
        case .orderedAscending:
            return true
        default:
            return false
        }
    }

    private func requestLatestAppStoreVersion() async throws -> String {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(iTunesID)")
        else { return "" }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let latestAppStoreVersion = results[0]["version"] as? String
        else { return "" }

        return latestAppStoreVersion
    }
}
