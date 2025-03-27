//
//  NoticeView.swift
//  PiPPl
//
//  Created by 김민택 on 5/29/24.
//

import SwiftUI

struct NoticeView: View {
    struct NoticeItem: Hashable, Identifiable {
        var id: Self { self }
        var title: String
        var date: String? = nil
        var content: [NoticeItem]? = nil
    }

    let networkManager = NetworkManager.shared
    @State private var item = [NoticeItem]()

    var body: some View {
        List(item, children: \.content) { item in
            VStack(alignment: .leading) {
                if item.date != nil {
                    Text(item.date!)
                }

                Text(item.title)
            }
        }
        .listStyle(.grouped)
        .navigationTitle("공지사항")
        .onAppear {
            networkManager.requestNoticeData { notices in
                for notice in notices {
                    item.append(NoticeItem(title: notice.title, date: notice.createDate, content: [NoticeItem(title: notice.content)]))
                }
            }

            item.reverse()
        }
    }
}

#Preview {
    NoticeView()
}
