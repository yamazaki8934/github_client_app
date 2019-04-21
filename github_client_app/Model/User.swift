//
//  User.swift
//  github_client_app
//
//  Created by 山崎浩毅 on 2019/04/21.
//  Copyright © 2019年 山崎浩毅. All rights reserved.
//

import Foundation

final class User {
    let id: Int
    let name: String
    let iconUrl: String
    let webURL: String
    
    init(attributes: [String: Any]) {
        id = attributes["id"] as! Int
        name = attributes["login"] as! String
        iconUrl = attributes["avatar_url"] as! String
        webURL = attributes["html_url"] as! String
    }
}
