//
//  LocalVideoLibraryManager.swift
//  PiPPl
//
//  Created by 김민택 on 1/18/24.
//

import Foundation
import Photos
import UIKit
import Dispatch

struct Video: Identifiable {
    let id = UUID()
    var asset: PHAsset
    var thumbnail: UIImage?
}

class LocalVideoLibraryManager: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {

    @Published var videos = [Video]()
    @Published var videoLoadingProgress: Double = 0.0
    @Published var isLoading = false
    private var assetFetchResult: PHFetchResult<PHAsset>?

    static let shared = LocalVideoLibraryManager()
    var status: PHAuthorizationStatus {
        get {
            PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
    }

    private init() {}

    func configureGallery() {
        guard let collection = requestVideoAlbums().firstObject else { return }
        let assets = requestVideos(in: collection)
        var newVideos = [Video]()
        var loadedCount = 0
        DispatchQueue.main.async {
            self.isLoading = true
        }

        assets.enumerateObjects { asset, _, _ in
            let thumbnail = self.requestThumbnail(asset)
            newVideos.append(.init(asset: asset, thumbnail: thumbnail))
            loadedCount += 1
            DispatchQueue.main.async {
                self.videoLoadingProgress = Double(loadedCount) / Double(assets.count)
            }
        }

        DispatchQueue.main.async {
            self.videos = newVideos
            self.isLoading = false
        }
    }

    func requestVideoAlbums() -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: PHFetchOptions())
    }

    func requestVideos(in collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: collection, options: PHFetchOptions())
    }

    func requestThumbnail(_ asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let thumbnailOption = PHImageRequestOptions()
        thumbnailOption.isSynchronous = true
        thumbnailOption.resizeMode = .exact
        let size = UIScreen.main.bounds.width / 3
        var thumbnail = UIImage()

        manager.requestImage(for: asset, targetSize: CGSize(width: size, height: size), contentMode: .aspectFill, options: thumbnailOption) { result, info in
            guard let result else { return }
            thumbnail = result
        }

        return thumbnail
    }
}
