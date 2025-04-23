//
//  AppInfoView.swift
//  PiPPl
//
//  Created by 김민택 on 5/23/24.
//

import SwiftUI
import SafariServices

struct AppInfoView: View {
    enum AppInfoAction {
        case none
        case developerInfo
        case customerService
        case license
        case versionInfo
    }

    @State private var isOpenSafariView = false
    @State private var isSelectAppVersion = false
    @State private var isOldVersion = false
    @State private var url = URL(string: "https://www.google.com")!
    let appVersionManager = AppVersionManager.shared

    var body: some View {
        List {
            NavigationLink(AppText.notice) {
                NoticeView()
            }
            Button(AppText.developerInfo) {
                url = URL(string: "https://github.com/taek0622")!
                isOpenSafariView = true
            }
            Text(AppText.customerService)
            Button(AppText.license) {
                url = URL(string: "https://pippl.notion.site/e318bd246e894b348ece6387e68270de")!
                isOpenSafariView = true
            }
            Button {
                Task {
                    isOldVersion = await appVersionManager.checkNewUpdate()
                    isSelectAppVersion = !isOldVersion
                }
            } label: {
                HStack {
                    Text(AppText.versionInfo)
                    Spacer()
                    Text(appVersionManager.downloadedAppVersion)
                        .foregroundStyle(.gray)
                }
            }
        }
        .fullScreenCover(isPresented: $isOpenSafariView, content: {
            SafariView(url: url)
        })
        .alert(AppText.latestVersionAlertTitle, isPresented: $isSelectAppVersion) {
            Button(AppText.latestVersionAlertAction) {
                isSelectAppVersion = false
            }
        } message: {
            Text(AppText.latestVersionAlertBody)
        }
        .alert(AppText.oldVersionAlertTitle, isPresented: $isOldVersion) {
            Button(AppText.oldVersionAlertAction) {
                let appStoreOpenURL = "itms-apps://itunes.apple.com/app/apple-store/\(appVersionManager.iTunesID)"
                guard let url = URL(string: appStoreOpenURL) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(AppText.oldVersionAlertBody)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ safariViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        AppInfoView()
    }
}
