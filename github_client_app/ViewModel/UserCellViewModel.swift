//
//  UserCellViewModel.swift
//  github_client_app
//
//  Created by 山崎浩毅 on 2019/04/22.
//  Copyright © 2019年 山崎浩毅. All rights reserved.
//

import Foundation
import UIKit

// 現在ダウンロード中か、ダウンロード終了か、エラーかの状態をenumで定義
enum ImageDownloadProgress {
    case loading(UIImage)
    case finish(UIImage)
    case error
}

final class UserCellViewModel {
    // ユーザーを変数として保持
    private var user: User
    // ImageDownloaderを変数として保持
    private let imageDownloader = ImageDownloader()
    // ImageDownloaderでダウンロード中かどうかのBool変数として保持
    private var isLoading = false
    // Cellに反映させるアウトプット
    var nickName: String {
        return user.name
    }
    // Cellを選択した時に必要なwebURL
    var webURL: URL {
        return URL(string: user.webURL)!
    }
    
    // userを引数にinit
    init(user: User) {
        self.user = user
    }
    
    // imageDownloaderを使ってダウンロードし、その結果をImageDownloadProgressとしてclosureで返している
    func downloadImage(progress: @escaping(ImageDownloaderProgress) -> Void) {
        // isLoadingがtrueだったら、returnしている。このメソッドはcellForRowメソッドで呼ばれることを想定しているため、何回もダウンロードしないためにisLoadingを使用している
        if isLoading == true {
            return
        }
        
        // grayのUIImageを作成
        let loadingImage = UIImage(color: .gray, size: CGSize(width: 45, height: 45))
        
        // .loadingをclosureで返している
        progress(.loading(loadingImage))
        
        // imageDownloaderを用いて、画像をダウンロードしている。引数に、user.iconUrlを使っている。ダウンロード終了したら、.finishをclosureで返す。Errorだったら、.errorをclosureで返している。
        imageDownloader.downloadImage(imageURL: user.iconUrl,
                                      success: {(image) in progress(.finish(image))
                                        self.isLoading = false
        }) { (error) in
            progress(.error)
            self.isLoading = false
        }
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
