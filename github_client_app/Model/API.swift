//
//  API.swift
//  github_client_app
//
//  Created by 山崎浩毅 on 2019/04/21.
//  Copyright © 2019年 山崎浩毅. All rights reserved.
//

import Foundation

enum APIError: Error, CustomStringConvertible {
    case unknown
    case invalidURL
    case invalidResponse
    
    var description: String {
        switch self {
        case .unknown:
            return "不明なエラーです"
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "フォーマットが無効なレスポンスを受け取りました"
        }
    }
}

class API {
    func getUsers(success: @escaping([User]) -> Void, failure: @escaping(Error) -> Void) {
        let requestURL = URL(string: "https://api.github.com/users")
        guard let url = requestURL else {
            failure(APIError.invalidURL)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // ErrorがあったらErrorをクロージャで返す
            if let error = error {
                DispatchQueue.main.async {
                    failure(error)
                }
                return
            }
            // dataがなかったら、APIError.unknown Errorをクロージャで返す
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(APIError.unknown)
                }
                return
            }
            // レスポンスのデータ型が不正だったら、APIError.invalidResponse Errorをクロージャで返す
            guard let jsonOptional = try?JSONSerialization.jsonObject(with: data, options: []), let json = jsonOptional as? [[String: Any]] else {
                DispatchQueue.main.async {
                    failure(APIError.invalidResponse)
                }
                return
            }
            // for文でjsonからUserを作成し、[User]に追加し、[User]をクロージャで返す
            var users = [User]()
            for j in json {
                let user = User(attributes: j)
                users.append(user)
            }
            DispatchQueue.main.async {
                success(users)
            }
        }
        
        task.resume()
    }
}
