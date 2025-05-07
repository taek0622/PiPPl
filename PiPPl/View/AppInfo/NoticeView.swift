//
//  NoticeView.swift
//  PiPPl
//
//  Created by 김민택 on 5/29/24.
//

import SwiftUI

struct NoticeView: View {

    @State private var item = [NoticeItem]()
    @StateObject var networkManager = NetworkManager()

    var body: some View {
        List(item.reversed(), children: \.content) { item in
            VStack(alignment: .leading) {
                if item.date != nil {
                    Text(item.date!)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }

                Text(item.title)
                    .font(.system(size: 17))
            }
        }
        .task {
            await networkManager.requestNoticeData()
        }
        .listStyle(.grouped)
        .navigationTitle(AppText.notice)
    }
}

#Preview {
    NoticeView()
}
