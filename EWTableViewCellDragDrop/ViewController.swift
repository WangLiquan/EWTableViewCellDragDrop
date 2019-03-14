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
        /**
         * 本质上.group和.plain类型的tableView对拖拽方法实现并没有影响,这里主要展示的是一个section和两个section的区别,主要区别就在于拖拽实现后tableView数据源的重置上,多个section要复杂一些.
         */
        if sender.tag == 0 {
            self.navigationController?.pushViewController(EWPlainTableViewController(), animated: true)
        } else {
            self.navigationController?.pushViewController(EWGroupTableViewController(), animated: true)
        }
    }

}
