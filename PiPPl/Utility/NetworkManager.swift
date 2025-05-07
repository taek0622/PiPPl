//
//  NetworkManager.swift
//  PiPPl
//
//  Created by 김민택 on 3/17/24.
//

import Foundation

final class NetworkManager: ObservableObject {


    private init() {}

    func requestNoticeData(completion: @escaping ([Notice]) -> Void) {
        guard let url = URL(string: "https://raw.githubusercontent.com/taek0622/Notice/main/notice.json") else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            guard let data = data else { return }
            let responseData = try! JSONDecoder().decode([Notice].self, from: data)
            completion(responseData)
        }
        .resume()
    }
}
