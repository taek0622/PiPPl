//
//  VideoModel.swift
//  PiPPl
//
//  Created by 김민택 on 5/11/25.
//

import Photos

struct Video: Identifiable, Hashable {
    var id: String { asset.localIdentifier }
    var asset: PHAsset
}
