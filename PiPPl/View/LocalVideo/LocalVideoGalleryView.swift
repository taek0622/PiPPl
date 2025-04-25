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
    private let libraryManager = LocalVideoLibraryManager.shared
    private let appVersionManager = AppVersionManager.shared
    var rowItemCount: Double {
        if UIDevice.current.systemName == "iOS" {
            if UIDevice.current.orientation == .portrait {
                return 3
            } else {
                return 5
            }
        } else if UIDevice.current.systemName == "iPadOS" {
            if UIDevice.current.orientation == .portrait {
                return 5
            } else {
                return 7
            }
        }

        return 3
    }

    var body: some View {
        VStack {
            if !status {
                Button(AppText.photoGalleryAccessPermissionButtonText) {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { stat in
                        switch stat {
                        case .notDetermined, .restricted, .denied:
                            status = false
                        case .authorized, .limited:
                            status = true
                            let collection = libraryManager.requestVideoAlbums()
                            let assets = libraryManager.requestVideos(in: collection.firstObject ?? PHAssetCollection())
                            assets.enumerateObjects { asset, _, _ in
                            }
                        @unknown default:
                            break
                        }
                    }
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

                                        let duration = Int(video.duration)
                                        Text("\(duration / 60):\(String(format: "%02d", duration % 60))")
                                            .foregroundStyle(.white)
                                            .padding(4)
                                    }
                                }
                            }
                        }
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
                let collection = libraryManager.requestVideoAlbums()
                let assets = libraryManager.requestVideos(in: collection.firstObject ?? PHAssetCollection())
                assets.enumerateObjects { asset, _, _ in
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
