//
//  ImageDownloader.swift
//  github_client_app
//
//  Created by 山崎浩毅 on 2019/04/21.
//  Copyright © 2019年 山崎浩毅. All rights reserved.
//

import Foundation
import UIKit

final class ImageDownloader {
    // UIImageをキャッシュする為の変数
    var casheImage: UIImage?
    
    func downloadImage(imageURL: String, success: @escaping(UIImage) -> Void, failure: @escaping(Error) -> Void) {
        // もしキャッシュされたUIImageがあれば、それをclosureで返す
        if let casheImage = casheImage {
            success(casheImage)
        }
        
        // リクエストを作成
        var request = URLRequest(url: URL(string: imageURL)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Errorがあったら、Errorをclosureで返す
            if let error = error {
                DispatchQueue.main.async {
                    failure(error)
                }
                return
            }
            
            // dataがなかったら、APIError.unknown Errorをclosureで返す
            guard let data = data else {
                DispatchQueue.main.async {
                    failure(APIError.unknown)
                }
                return
            }
            
            // 受け取ったデータからUIImageを生成できなければ、APIError.unknown Errorをclosureで返す
            guard let imageFromData = UIImage(data: data) else {
                DispatchQueue.main.async {
                    failure(APIError.unknown)
                }
                return
            }
            
            // imageFromDataをclosureで返す
            DispatchQueue.main.async {
                success(imageFromData)
            }
            
            // 画像をキャッシュする
            self.casheImage = imageFromData
        }
        task.resume()
    }
}
