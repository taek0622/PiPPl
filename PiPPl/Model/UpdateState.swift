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

    var updateAlertTitle: String {
        switch self {
            case .latest:
                AppText.latestVersionAlertTitle
            case .available, .recommended:
                AppText.updateAvailableAlertTitle
            case .required:
                AppText.oldVersionAlertTitle
        }
    }

    var updateAlertBody: String {
        switch self {
            case .latest:
                AppText.latestVersionAlertBody
            case .available, .recommended:
                AppText.updateAvailableAlertBody
            case .required:
                AppText.oldVersionAlertBody
        }
    }

    var updateAlertPrimaryAction: String {
        switch self {
            case .latest:
                AppText.confirm
            case .available, .recommended:
                AppText.updateAvailableAlertUpdateAction
            case .required:
                AppText.oldVersionAlertAction
        }
    }
}
