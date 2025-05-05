//
//  VersionModel.swift
//  PiPPl
//
//  Created by 김민택 on 5/6/25.
//

struct Version: Comparable {
    var major: Int
    var minor: Int
    var patch: Int
    var versionString: String {
        "\(major).\(minor).\(patch)"
    }

    init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.init(major: major, minor: minor, patch: patch)
    }

    init?(_ string: String) {
        let versions = string.split(separator: ".").map { Int($0)! }
        guard versions.count >= 3 else { return nil }
        self.init(major: versions[0], minor: versions[1], patch: versions[2])
    }

    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
}
