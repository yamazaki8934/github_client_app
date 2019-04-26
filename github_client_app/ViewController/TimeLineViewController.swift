//
//  TimeLineViewController.swift
//  github_client_app
//
//  Created by 山崎浩毅 on 2019/04/22.
//  Copyright © 2019年 山崎浩毅. All rights reserved.
//

import UIKit
import Foundation
import SafariServices

class TimeLineViewController: UIViewController {
    
    fileprivate var viewModel: UserListViewModel!
    fileprivate var tableView: UITableView!
    fileprivate var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // tableViewを生成
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TimeLineCell.self, forCellReuseIdentifier: "TimeLineCell")
        view.addSubview(tableView)
        
        // UIRefreshControlを生成し、リフレッシュしたときに呼ばれるメソッドを定義し、tableView.refreshControlにセットしている
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlValueDidChange(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // UserListViewModelを生成し、通知を受け取った時の処理を定義している
        viewModel = UserListViewModel()
        viewModel.stateDidUpdate = {[weak self] state in
            switch state {
            case .loading:
                // 通信中だったら、tableViewを操作不能にしている
                self?.tableView.isUserInteractionEnabled = false
                break
            case .finish:
                // 通信完了したら、tableViewを操作可能にし、tableViewを更新。また、refreshControl.endRefreshingを呼んでいる
                self?.tableView.isUserInteractionEnabled = true
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                break
            case .error(let error):
                // Errorだったら、tableViewを操作可能にし、またrefreshControl.endRefreshingを呼んでいる。その後、ErrorメッセージAlertを表示している。
                self?.tableView.isUserInteractionEnabled = true
                self?.refreshControl.endRefreshing()
                
                let alertController = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(alertAction)
                self!.present(alertController, animated: true, completion: nil)
                break
            }
        }
        
        // ユーザー一覧取得している
        viewModel.getUsers()
    }
    
    @objc func refreshControlValueDidChange(sender: UIRefreshControl) {
        // リフレッシュした時、ユーザー一覧取得している
        viewModel.getUsers()
    }
}

extension TimeLineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // viewModel.usersCount()をtableViewのCellの数として設定している
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.usersCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let timeLineCell = tableView.dequeueReusableCell(withIdentifier: "TimeLineCell") as? TimeLineCell {
            // そのCellのUserCellViewModelを取得し、timeLineCellに対して、nickNameとiconをセットしている
            let cellViewModel = viewModel.cellViewModels[indexPath.row]
            timeLineCell.setNickName(nickName: cellViewModel.nickName)
            
            cellViewModel.downloadImage { (progress) in
                switch progress {
                case .loading(let image):
                    timeLineCell.setIcon(icon: image)
                    break
                case .finish(let image):
                    timeLineCell.setIcon(icon: image)
                    break
                case .error:
                    break
                }
            }
            return timeLineCell
        }
        
        fatalError()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        // そのCellのUserCellViewModelを取得し、そのユーザーのGithubページへ画面遷移している
        let cellViewModel = viewModel.cellViewModels[indexPath.row]
        let webURL = cellViewModel.webURL
        let webViewController = SFSafariViewController(url: webURL)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}
