//
//  SICapacity.swift
//  PiPPl
//
//  Created by 김민택 on 5/14/25.
//

enum SICapacity: Int {
    case Byte = 0
    case Kilobyte = 1
    case Megabyte = 2
    case Gigabyte = 3
    case Terabyte = 4
    case Petabyte = 5

    func capacityString() -> String {
        switch self {
            case .Byte: return "B"
            case .Kilobyte: return "KB"
            case .Megabyte: return "MB"
            case .Gigabyte: return "GB"
            case .Terabyte: return "TB"
            case .Petabyte: return "PB"
        }
    }
}
