//
//  PiPPlApp.swift
//  PiPPl
//
//  Created by 김민택 on 4/29/24.
//

import AVFoundation
import SwiftUI

@main
struct PiPPlApp: App {

    init() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("Failed to set audio session category.")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
