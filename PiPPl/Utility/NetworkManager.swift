//
//  NetworkManager.swift
//  PiPPl
//
//  Created by 김민택 on 3/17/24.
//

import Foundation

final class NetworkManager {

    static let shared = NetworkManager()

    var notices = [Notice]()

    private init() {}

    func requestNoticeData(completion: @escaping ([Notice]) -> Void) {
        guard let url = URL(string: "https://raw.githubusercontent.com/taek0622/Notice/main/notice.json") else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error {
                print(error)
                return
            }

            guard let data = data else { return }
            let responseData = try! JSONDecoder().decode([Notice].self, from: data)
            completion(responseData)
        }
        .resume()
    }
}
