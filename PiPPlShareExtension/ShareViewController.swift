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

}

