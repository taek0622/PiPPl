//
//  NoticeView.swift
//  PiPPl
//
//  Created by 김민택 on 5/29/24.
//

import SwiftUI

struct NoticeView: View {

    @StateObject var noticeViewModel = NoticeViewModel()

    var body: some View {
        List(noticeViewModel.notices.reversed(), children: \.content) { item in
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
            await noticeViewModel.requestNoticeData()
        }
        .listStyle(.grouped)
        .navigationTitle(AppText.notice)
    }
}

#Preview {
    NoticeView()
}
