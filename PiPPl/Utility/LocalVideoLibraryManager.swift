//
//  LocalVideoLibraryManager.swift
//  PiPPl
//
//  Created by 김민택 on 1/18/24.
//

import Foundation
import Photos
import UIKit

struct Video: Identifiable {
    let id = UUID()
    var asset: PHAsset
    var thumbnail: UIImage?
}

class LocalVideoLibraryManager: ObservableObject {

    @Published var videos = [PHAsset]()

    static let shared = LocalVideoLibraryManager()
    var status: PHAuthorizationStatus {
        get {
            PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
    }

    private init() {}

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
