//
//  LocalVideoGalleryView.swift
//  PiPPl
//
//  Created by 김민택 on 4/30/24.
//

import Photos
import SwiftUI

struct LocalVideoGalleryView: View {
    @State private var status = false
    @State private var isOldVersion: Bool = false
    @StateObject private var libraryManager = LocalVideoLibraryManager.shared
    @Environment(\.colorScheme) private var colorScheme
    private let appVersionManager = AppVersionManager.shared
    var rowItemCount: Double {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if UIDevice.current.orientation == .portrait {
                return 3
            } else {
                return 5
            }
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation == .portrait {
                return 5
            } else {
                return 7
            }
        }

        return 3
    }

    var body: some View {
        ZStack {
            if !status {
                Button(AppText.photoGalleryAccessPermissionButtonText) {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { stat in
                        switch stat {
                        case .notDetermined, .restricted, .denied:
                            status = false
                        case .authorized, .limited:
                            libraryManager.configureGallery()
                            status = true
                        @unknown default:
                            break
                        }
                    }
                }
            } else if libraryManager.videos.isEmpty {
                Button(AppText.photoGalleryNoVideoButtonText) {
                    libraryManager.configureGallery()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(UIScreen.main.bounds.width/rowItemCount), spacing: 1), count: Int(rowItemCount)), spacing: 1) {
                        ForEach(libraryManager.videos, id: \.id) { video in
                            NavigationLink {
                                LocalVideoPlayView(asset: video.asset)
                                    .toolbar(.hidden, for: .tabBar)
                            } label: {
                                ZStack(alignment: .bottomTrailing) {
                                    Image(uiImage: video.thumbnail ?? UIImage(ciImage: CIImage(color: .gray)))
                                        .resizable()
                                        .frame(height: UIScreen.main.bounds.width/rowItemCount)

                                    let duration = Int(video.asset.duration)
                                    Text("\(duration / 60):\(String(format: "%02d", duration % 60))")
                                        .foregroundStyle(.white)
                                        .padding(4)
                                }
                            }
                        }
                    }
                }
            }

            if libraryManager.isLoading {
                VStack {
                    ZStack {
                        Color(colorScheme == .light ? #colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.2196078431, alpha: 1) : #colorLiteral(red: 0.5490196078, green: 0.5490196078, blue: 0.5490196078, alpha: 1))
                        Color(colorScheme == .light ? #colorLiteral(red: 0.7019607843, green: 0.7019607843, blue: 0.7019607843, alpha: 0.82) : #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 0.82))
                        VStack {
                            HStack {
                                Text(AppText.photoGalleryLoadText)
                                Spacer()
                                Text("\(Int(libraryManager.videoLoadingProgress * 100))%")
                            }
                            ProgressView(value: libraryManager.videoLoadingProgress)
                        }
                        .frame(width: UIScreen.main.bounds.width / 3)
                    }
                }
            }
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
        .onAppear {
            switch libraryManager.status {
            case .notDetermined, .restricted, .denied:
                status = false
            case .authorized, .limited:
                status = true
                if libraryManager.videos.isEmpty {
                    libraryManager.configureGallery()
                }
            @unknown default:
                break
            }

            Task {
                isOldVersion = await appVersionManager.checkNewUpdate()
            }
        }
    }
}

#Preview {
    NavigationView {
        LocalVideoGalleryView()
    }
}
