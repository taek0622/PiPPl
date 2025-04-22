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
    @State private var videos = [PHAsset]()
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
                            videos = []
                            assets.enumerateObjects { asset, _, _ in
                                videos.append(asset)
                            }
                        @unknown default:
                            break
                        }
                    }
                }
            } else {
                GeometryReader { geo in
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(geo.size.width/rowItemCount), spacing: 1), count: Int(rowItemCount)), spacing: 1) {
                            ForEach(videos, id: \.self) { video in
                                NavigationLink {
                                    LocalVideoPlayView(asset: video)
                                        .toolbar(.hidden, for: .tabBar)
                                } label: {
                                    ZStack(alignment: .bottomTrailing) {
                                        configureThumbnail(video)
                                            .resizable()
                                            .frame(height: geo.size.width/rowItemCount)

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
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .notDetermined, .restricted, .denied:
                status = false
            case .authorized, .limited:
                status = true
                let collection = libraryManager.requestVideoAlbums()
                let assets = libraryManager.requestVideos(in: collection.firstObject ?? PHAssetCollection())
                videos = []
                assets.enumerateObjects { asset, _, _ in
                    videos.append(asset)
                }
            @unknown default:
                break
            }

            Task {
                isOldVersion = await appVersionManager.checkNewUpdate()
            }
        }
    }

    private func configureThumbnail(_ asset: PHAsset) -> Image {
        let manager = PHImageManager.default()
        var thumbnail = Image(uiImage: UIImage(ciImage: CIImage(color: .gray)))
        let thumbnailOption = PHImageRequestOptions()
        thumbnailOption.isSynchronous = true
        thumbnailOption.resizeMode = .exact
        let size = UIScreen.main.bounds.width / 3

        manager.requestImage(for: asset, targetSize: CGSize(width: size, height: size), contentMode: .aspectFill, options: thumbnailOption) { result, info in
            guard let result else { return }
            thumbnail = Image(uiImage: result)
        }

        return thumbnail
    }
}

#Preview {
    NavigationView {
        LocalVideoGalleryView()
    }
}
