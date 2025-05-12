//
//  AppInfoView.swift
//  PiPPl
//
//  Created by 김민택 on 5/23/24.
//

import MessageUI
import SafariServices
import SwiftUI

struct AppInfoView: View {
    enum AppInfoAction {
        case none
        case developerInfo
        case customerService
        case license
        case versionInfo
    }

    @EnvironmentObject var appVersionManager: AppVersionManager
    @State private var isOpenSafariView = false
    @State private var isOldVersion = false
    @State private var isSelectAppVersion = false
    @State private var url = URL(string: "https://www.google.com")!
    @State private var isMailSend = false
    @State private var isUnavailableMail = false
    @State private var isClearCache: Bool = false
    @Binding var appInfoPath: NavigationPath

    var body: some View {
        List {
            Button(AppText.notice) {
                appInfoPath.append(AppInfoViewSelection.noticeView)
            }
            Button(AppText.developerInfo) {
                url = URL(string: "https://github.com/taek0622")!
                isOpenSafariView = true
            }
            Button(AppText.customerService) {
                if !MFMailComposeViewController.canSendMail() {
                    isUnavailableMail = true
                } else {
                    isMailSend = true
                }
            }
            Button(AppText.license) {
                url = URL(string: "https://pippl.notion.site/e318bd246e894b348ece6387e68270de")!
                isOpenSafariView = true
            }
            Button {
                Task {
                    if appVersionManager.updateState == .latest {
                        isSelectAppVersion = true
                    } else {
                        isOldVersion = true
                    }
                }
            } label: {
                HStack {
                    Text(AppText.versionInfo)
                    Spacer()
                    Text(appVersionManager.downloadedAppVersion.versionString)
                        .foregroundStyle(.gray)
                        .font(.system(size: 16))
                }
            }
            Button(AppText.clearAllCache, role: .destructive) {
                isClearCache = true
            }
        }
        .fullScreenCover(isPresented: $isOpenSafariView, content: {
            SafariView(url: url)
        })
        .sheet(isPresented: $isMailSend, content: {
            CustomerServiceMailView()
        })
        .alert(AppText.cantSendMailAlertTitle, isPresented: $isUnavailableMail, actions: {
            Button(AppText.confirm) {
                isUnavailableMail = false
            }
        }, message: {
            Text(AppText.cantSendMailAlertBody)
        })
        .alert(AppText.latestVersionAlertTitle, isPresented: $isSelectAppVersion) {
            Button(AppText.confirm) {
                isSelectAppVersion = false
            }
        } message: {
            Text(AppText.latestVersionAlertBody)
        }
        .alert(appVersionManager.updateState.updateAlertTitle, isPresented: $isOldVersion) {
            Button(appVersionManager.updateState.updateAlertPrimaryAction) {
                let appStoreOpenURL = "itms-apps://itunes.apple.com/app/apple-store/\(appVersionManager.iTunesID)"
                guard let url = URL(string: appStoreOpenURL) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }

            if appVersionManager.updateState == .recommended || appVersionManager.updateState == .available {
                Button(AppText.updateAvailableAlertPostponeAction, role: .cancel) {}
            }
        } message: {
            Text(appVersionManager.updateState.updateAlertBody)
        }
        .alert(AppText.clearAllCache, isPresented: $isClearCache) {
            Button(AppText.confirm, role: .destructive) {
                ThumbnailDiskCache.shared.removeAllThumbnails()
                ThumbnailMemoryCache.shared.removeAllThumbnails()
            }

            Button(AppText.cancel, role: .cancel) {}
        } message: {
            Text(AppText.clearCacheAlertBody)
        }
        .navigationDestination(for: AppInfoViewSelection.self) { view in
            switch view {
                case .noticeView:
                    NoticeView()
                case .licenseView:
                    EmptyView()
            }
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
        AppInfoView(appInfoPath: .constant(NavigationPath()))
    }
}
