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

    override private init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func configureGallery() {
        guard let collection = requestVideoAlbums().firstObject else { return }
        let assets = requestVideos(in: collection)
        self.assetFetchResult = assets
        updateVideos(assets)
    }

    func requestVideoAlbums() -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: PHFetchOptions())
    }

    func requestVideos(in collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: collection, options: PHFetchOptions())
    }

    func updateVideos(_ assets: PHFetchResult<PHAsset>) {
        var updatedVideos = [Video]()
        var loadedCount = 0
        self.isLoading = true

        assets.enumerateObjects { asset, _, _ in
            let thumbnail = self.requestThumbnail(asset)
            updatedVideos.append(.init(asset: asset, thumbnail: thumbnail))
            loadedCount += 1

            DispatchQueue.main.async {
                self.videoLoadingProgress = Double(loadedCount) / Double(assets.count)
            }
        }

        DispatchQueue.main.async {
            self.videos = updatedVideos
            self.isLoading = false
        }
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

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let assetsFetchResult = assetFetchResult, let changes = changeInstance.changeDetails(for: assetsFetchResult) else { return }

        DispatchQueue.main.async {
            self.assetFetchResult = changes.fetchResultAfterChanges

            if changes.hasIncrementalChanges {
                if let removed = changes.removedIndexes {
                    for idx in removed.reversed() {
                        self.videos.remove(at: idx)
                    }
                }

                if let inserted = changes.insertedIndexes {
                    for idx in inserted {
                        let asset = changes.fetchResultAfterChanges.object(at: idx)
                        let thumbnail = self.requestThumbnail(asset)
                        let video = Video(asset: asset, thumbnail: thumbnail)
                        self.videos.insert(video, at: idx)
                    }
                }

                if let changed = changes.changedIndexes {
                    for idx in changed {
                        let asset = changes.fetchResultAfterChanges.object(at: idx)
                        let thumbnail = self.requestThumbnail(asset)
                        let video = Video(asset: asset, thumbnail: thumbnail)
                        self.videos[idx] = video
                    }
                }
            } else {
                self.updateVideos(changes.fetchResultAfterChanges)
            }
        }
    }
}
