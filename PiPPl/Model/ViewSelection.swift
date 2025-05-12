//
//  ViewSelection.swift
//  PiPPl
//
//  Created by 김민택 on 5/13/25.
//

enum ViewSelection {
    case localVideo
    case networkVideo
    case appInfo
}

enum LocalViewSelection: Hashable {
    case playView(Video)
}

enum AppInfoViewSelection: Hashable {
    case noticeView
    case licenseView
}
