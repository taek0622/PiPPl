//
//  LocalPlayerViewController.swift
//  PiPPl
//
//  Created by 김민택 on 4/20/25.
//

import AVKit

class LocalPlayerViewController: AVPlayerViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
        self.removeFromParent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        tabBarController?.tabBar.isHidden = false
    }

}
