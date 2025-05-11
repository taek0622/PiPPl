//
//  ThumbnailMemoryCache.swift
//  PiPPl
//
//  Created by 김민택 on 5/11/25.
//

import Photos
import UIKit

class ThumbnailMemoryCache {

    static let shared = ThumbnailMemoryCache()

    private init() {}

    private var thumbnailCache = NSCache<NSString, UIImage>()

    func thumbnail(for asset: PHAsset) -> UIImage? {
        return thumbnailCache.object(forKey: asset.localIdentifier as NSString)
    }

    func setThumbnail(_ image: UIImage, for asset: PHAsset) {
        thumbnailCache.setObject(image, forKey: asset.localIdentifier as NSString)
    }

    func removeThumbnail(for asset: PHAsset) {
        thumbnailCache.removeObject(forKey: asset.localIdentifier as NSString)
    }

    func removeAllThumbnails() {
        thumbnailCache.removeAllObjects()
    }

}
