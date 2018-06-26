//
//  ViewController.swift
//  SwiftProject
//
//  Created by 牛新怀 on 2017/12/6.
//  Copyright © 2017年 牛新怀. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
//https://api-dev.beichoo.com/bc/0.1/special/light_reading?nonce=511720&sig=6b5eb6b67dcd9b9c7b41153dd8c9aab7d80404ec
    class ViewController: BaseViewController {
        var dataSource = [items]()

        override func viewDidLoad() {
            super.viewDidLoad()
            self.loadData()
            
            print("当前返回的值是\(PersonModel.CanOpenQQ)")
            
            
        }
        
        override func configNavgationItem() {
            super.configNavgationItem()
            navigationItem.rightBarButtonItem = UIBarButtonItem.initNavBarbuttonItems(imageNamed: "img_have_search",
                                                                                      target: self,
                                                                                      action: #selector(didSelectRightBarButtonItem))
        }
        
        @objc func didSelectRightBarButtonItem() {
            
        }
        
        func DownLoadData() -> Void {//https://api.beichoo.com/bc/0.1/special/light_reading?nonce=511720&sig=6b5eb6b67dcd9b9c7b41153dd8c9aab7d80404ec
            Alamofire.request("https://api.beichoo.com/bc/0.1/special/light_reading?nonce=511720&sig=6b5eb6b67dcd9b9c7b41153dd8c9aab7d80404ec").responseData { (object ) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activity.stopAnimating()
                self.tableView.mj_header.endRefreshing()
                switch object.result.isSuccess{
                case true:
                    if let value = object.result.value{
                        let json = JSON(value)
                        if json["data"]["item"].arrayValue.count != 0 {
                            let array = json["data"]["item"].arrayValue
                            array.forEach({ (model) in
                                let item = items.init(json: model)
                                self.dataSource.append(item)
                            })
                        }
                        
                        self.tableView.reloadData()
                    }
                case false:
                    print(object.result.error!)
                }
            }
        }
        
        @objc private func loadData() {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.activity.startAnimating()
            self.DownLoadData()

        }
        
        lazy var tableView:UITableView = {
            let table = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.view.bounds.size.height), style: UITableViewStyle.plain)
            if #available(iOS 11.0, *) {
                //table.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            } else {
                table.frame = CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.size.width,
                                          height: UIScreen.main.bounds.size.height-64-49)
                // Fallback on earlier versions
            };
            table.delegate = self;
            table.dataSource = self;
            table.estimatedRowHeight = 50;
            table.separatorStyle = .none
            table.rowHeight = UITableViewAutomaticDimension
            table.register(RecomendTableViewCell.classForCoder(),
                           forCellReuseIdentifier: "cellIdentifier")
            table.mj_header = NSRefreshHeader{self.loadData()}
            
            self.view.addSubview(table)
            return table
        }()
        lazy var activity:UIActivityIndicatorView = {
            let activityView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            activityView.color = UIColor.lightGray
            activityView.center = CGPoint.init(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
            self.view.addSubview(activityView)
            return activityView
        }()
    }

extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier",
                                                 for: indexPath) as! RecomendTableViewCell
        
        cell.model = dataSource[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        
        if model.type == "article" {
            let url = model.id
            let vc = ArticleDetialViewController.init(url: url)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

