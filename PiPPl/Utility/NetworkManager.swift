//
//  NetworkManager.swift
//  PiPPl
//
//  Created by 김민택 on 3/17/24.
//

import Foundation

@MainActor
final class NetworkManager: ObservableObject {

    @Published var notices = [NoticeItem]()

    func requestNoticeData() async {
        guard let url = URL(string: "https://raw.githubusercontent.com/taek0622/Notice/main/notice.json") else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let responseData = try JSONDecoder().decode([Notice].self, from: data)

            self.notices = responseData.map { NoticeItem(title: $0.title, date: $0.createDate, content: [NoticeItem(title: $0.content)]) }
        } catch {
            print("error")
        }
    }
}
