//
//  UpdateState.swift
//  PiPPl
//
//  Created by 김민택 on 5/3/25.
//

import SwiftUI

enum UpdateState {
    case latest
    case available
    case recommended
    case required

    var updateNotificationColor: Color {
        switch self {
            case .latest:
                .clear
            case .available:
                .accentColor
            case .recommended:
                .yellow
            case .required:
                .red
        }
    }
}
