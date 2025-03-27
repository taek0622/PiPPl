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
    @State private var url = URL(string: "https://www.google.com")!

    var body: some View {
        List {
            NavigationLink("공지사항") {
                NoticeView()
            }
            Button("개발자 정보") {
                url = URL(string: "https://github.com/taek0622")!
                isOpenSafariView = true
            }
            Text("고객센터")
            Button("라이센스") {
                url = URL(string: "https://pippl.notion.site/e318bd246e894b348ece6387e68270de")!
                isOpenSafariView = true
            }
            Button("버전 정보") {
                isSelectAppVersion = true
            }
        }
        .fullScreenCover(isPresented: $isOpenSafariView, content: {
            SafariView(url: url)
        })
        .alert("최신 버전", isPresented: $isSelectAppVersion) {
            Button("확인") {
                isSelectAppVersion = false
            }
        } message: {
            Text("앱이 최신 버전입니다.")
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
