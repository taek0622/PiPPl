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
    var fileName: String?
    var creationDate: Date?
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

    func configureGallery() async {
        guard let collection = requestVideoAlbums().firstObject else { return }
        let assets = requestVideos(in: collection)
        self.assetFetchResult = assets
        await updateVideos(assets)
    }

    func requestVideoAlbums() -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: PHFetchOptions())
    }

    func requestVideos(in collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: collection, options: PHFetchOptions())
    }

    func updateVideos(_ assets: PHFetchResult<PHAsset>) async {
        await MainActor.run {
            self.videoLoadingProgress = 0
            self.isLoading = true
        }

        await withTaskGroup(of: (Int, Video).self) { group in
            for idx in 0..<assets.count {
                let asset = assets.object(at: idx)

                group.addTask {
                    let thumbnail = await self.requestThumbnail(asset)
                    let fileName = self.requestFileName(asset)
                    return (idx, Video(asset: asset, thumbnail: thumbnail, fileName: fileName, creationDate: asset.creationDate))
                }
            }

            var updatedResults = [(Int, Video)]()

            for await (idx, video) in group {
                updatedResults.append((idx, video))
                let progress = Double(updatedResults.count) / Double(assets.count)

                await MainActor.run {
                    self.videoLoadingProgress = progress
                }
            }

            let updatedVideos = updatedResults.sorted(by: { $0.0 < $1.0 }).map { $0.1 }

            await MainActor.run {
                self.videos = updatedVideos
                self.isLoading = false
            }
        }
    }

    func requestThumbnail(_ asset: PHAsset) async -> UIImage {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                let manager = PHImageManager.default()
                let thumbnailOption = PHImageRequestOptions()
                thumbnailOption.isSynchronous = false
                thumbnailOption.resizeMode = .exact
                thumbnailOption.deliveryMode = .highQualityFormat
                thumbnailOption.isNetworkAccessAllowed = true
                let size = UIScreen.main.bounds.width / 3
                var didResume = false

                manager.requestImage(for: asset, targetSize: CGSize(width: size, height: size), contentMode: .aspectFill, options: thumbnailOption) { result, info in
                    if let result = result, !didResume {
                        didResume = true
                        continuation.resume(returning: result)
                    }

                    if result == nil, !didResume {
                        didResume = true
                        continuation.resume(returning: UIImage(ciImage: CIImage(color: .gray)))
                    }
                }
            }
        }
    }

    func requestFileName(_ asset: PHAsset) -> String {
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first else { return "" }
        return resource.originalFilename
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let assetsFetchResult = assetFetchResult, let changes = changeInstance.changeDetails(for: assetsFetchResult) else { return }

        Task {
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
                        let thumbnail = await self.requestThumbnail(asset)
                        let video = Video(asset: asset, thumbnail: thumbnail)
                        self.videos.insert(video, at: idx)
                    }
                }

                if let changed = changes.changedIndexes {
                    for idx in changed {
                        let asset = changes.fetchResultAfterChanges.object(at: idx)
                        let thumbnail = await self.requestThumbnail(asset)
                        let video = Video(asset: asset, thumbnail: thumbnail)
                        self.videos[idx] = video
                    }
                }
            } else {
                await self.updateVideos(changes.fetchResultAfterChanges)
            }
        }
    }
}
