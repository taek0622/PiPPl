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
    @EnvironmentObject var appVersionManager: AppVersionManager
    @Binding var appInfoPath: NavigationPath
    @State private var isOpenSafariView = false
    @State private var isOldVersion = false
    @State private var safariViewType: SafariViewType?
    @State private var isMailSend = false
    @State private var isShowingAlert = false
    @State private var alertType: AlertType = .latestVersion
    @State private var cacheCapacity = "0B"

    enum SafariViewType: Identifiable {
        case developer, license

        var id: String {
            switch self {
                case .developer: return "developer"
                case .license: return "license"
            }
        }

        var url: URL {
            switch self {
                case .developer:
                    return URL(string: "https://github.com/taek0622")!
                case .license:
                    return URL(string: "https://pippl.notion.site/e318bd246e894b348ece6387e68270de")!
            }
        }
    }

    enum AlertType: Identifiable {
        case cantSendMail, latestVersion, clearCache

        var id: String {
            switch self {
                case .cantSendMail: return "cantSendMail"
                case .latestVersion: return "latestVersion"
                case .clearCache: return "clearCache"
            }
        }

        var title: String {
            switch self {
                case .cantSendMail: return AppText.cantSendMailAlertTitle
                case .latestVersion: return AppText.latestVersionAlertTitle
                case .clearCache: return AppText.clearAllCache
            }
        }

        var message: String {
            switch self {
                case .cantSendMail: return AppText.cantSendMailAlertBody
                case .latestVersion: return AppText.latestVersionAlertBody
                case .clearCache: return AppText.clearCacheAlertBody
            }
        }
    }

    var body: some View {
        List {
            Button {
                appInfoPath.append(AppInfoViewSelection.noticeView)
            } label: {
                HStack {
                    Text(AppText.notice)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .fontWeight(.medium)
                }
            }
            Button(AppText.developerInfo) {
                safariViewType = .developer
            }
            Button(AppText.customerService) {
                if !MFMailComposeViewController.canSendMail() {
                    alertType = .cantSendMail
                    isShowingAlert = true
                } else {
                    isMailSend = true
                }
            }
            Button(AppText.license) {
                safariViewType = .license
            }
            Button {
                Task {
                    if appVersionManager.updateState == .latest {
                        alertType = .latestVersion
                        isShowingAlert = true
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
            Button {
                alertType = .clearCache
                isShowingAlert = true
            } label: {
                HStack {
                    Text(AppText.clearAllCache)
                        .foregroundStyle(.red)
                    Spacer()
                    Text(cacheCapacity)
                        .foregroundStyle(.gray)
                        .font(.system(size: 14))
                }
            }
        }
        .fullScreenCover(item: $safariViewType, content: { type in
            SafariView(url: type.url)
        })
        .sheet(isPresented: $isMailSend, content: {
            CustomerServiceMailView()
        })
        .alert(alertType.title, isPresented: $isShowingAlert, actions: {
            switch alertType {
                case .cantSendMail:
                    Button(AppText.confirm) {}
                case .latestVersion:
                    Button(AppText.confirm) {}
                case .clearCache:
                    Button(AppText.confirm, role: .destructive) {
                        Task {
                            await ThumbnailDiskCache.shared.removeAllThumbnails()
                            ThumbnailMemoryCache.shared.removeAllThumbnails()
                            cacheCapacity = ThumbnailDiskCache.shared.cacheSizeString()
                        }
                    }

                    Button(AppText.cancel, role: .cancel) {}
            }
        }, message: {
            Text(alertType.message)
        })
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
        .onAppear {
            cacheCapacity = ThumbnailDiskCache.shared.cacheSizeString()
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
