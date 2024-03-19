//
//  ShareViewController.swift
//  PiPPlShareExtension
//
//  Created by 김민택 on 3/19/24.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        return !self.contentText.isEmpty
    }

    override func configurationItems() -> [Any]! {
        let item = SLComposeSheetConfigurationItem()

        item?.title = "PiPPl"
        item?.value = "재생할 동영상이 있는 페이지의 url 입력"

        return [item]
    }

}

