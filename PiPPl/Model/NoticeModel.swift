//
//  NoticeModel.swift
//  PiPPl
//
//  Created by 김민택 on 3/17/24.
//

struct Notice: Codable, Hashable {
    let noticeID: Int
    let title: String
    let content: String
    let createDate: String
}

struct NoticeItem: Hashable, Identifiable {
    var id: Self { self }
    var title: String
    var date: String? = nil
    var content: [NoticeItem]? = nil
}
