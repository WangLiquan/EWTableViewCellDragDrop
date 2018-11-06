//
//  ViewController.swift
//  EWTableViewCellDragDrop
//
//  Created by Ethan.Wang on 2018/10/31.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    private let topButton: UIButton = {
        let button = UIButton(frame: CGRect(x: (UIScreen.main.bounds.size.width - 250) / 2, y: 200, width: 250, height: 50))
        button.setTitle("plain型tableView", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.gray
        button.addTarget(self, action: #selector(onClickPushButton(sender:)), for: .touchUpInside)
        button.tag = 0
        return button
    }()
    private let bottomButton: UIButton = {
        let button = UIButton(frame: CGRect(x: (UIScreen.main.bounds.size.width - 250) / 2, y: 300, width: 250, height: 50))
        button.tag = 1
        button.setTitle("group型tableView", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(onClickPushButton(sender:)), for: .touchUpInside)
        button.backgroundColor = UIColor.gray
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(topButton)
        self.view.addSubview(bottomButton)
    }

    @objc private func onClickPushButton(sender: UIButton) {
        if sender.tag == 0{
            self.navigationController?.pushViewController(EWPlainTableViewController(), animated: true)
        } else {
            self.navigationController?.pushViewController(EWGroupTableViewController(), animated: true)
        }
    }

}
