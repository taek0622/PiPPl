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

    @State private var isOpenSafariView = false
    @State private var isOldVersion = false
    @State private var isSelectAppVersion = false
    @State private var updateState: UpdateState = .latest
    @State private var url = URL(string: "https://www.google.com")!
    @State private var isMailSend = false
    @State private var isUnavailableMail = false
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
                    updateState = await appVersionManager.checkNewUpdate()

                    if updateState == .latest {
                        isSelectAppVersion = true
                    } else {
                        isOldVersion = true
                    }
                }
            } label: {
                HStack {
                    Text(AppText.versionInfo)
                    Spacer()
                    Text("\(appVersionManager.downloadedAppVersion.major).\(appVersionManager.downloadedAppVersion.minor).\(appVersionManager.downloadedAppVersion.patch)")
                        .foregroundStyle(.gray)
                        .font(.system(size: 16))
                }
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
