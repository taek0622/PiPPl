//
//  String+.swift
//  PiPPl
//
//  Created by 김민택 on 3/29/24.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
