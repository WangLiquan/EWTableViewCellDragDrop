//
//  ViewController.swift
//  EWTableViewCellDragDrop
//
//  Created by Ethan.Wang on 2018/10/31.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

var colorArr = [UIColor.gray,UIColor.green,UIColor.yellow,UIColor.blue,UIColor.brown]

class ViewController: UIViewController {

    var modelArray: [EWColorModel] = {
        var array = [EWColorModel]()
        for i in 0..<5{
            var model = EWColorModel()
            model.title = "1 - \(i)"
            model.color = colorArr[i]
            array.append(model)
        }
        return array
    }()

    var secondModelArray: [EWColorModel] = {
        var array = [EWColorModel]()
        for i in 0..<5{
            var model = EWColorModel()
            model.title = "2 - \(i)"
            model.color = colorArr[i]
            array.append(model)
        }
        return array
    }()


    private var tableView:UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        /// 添加三行,阻止tableView.reload方法后的闪动效果
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0

        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EWDragTableViewCell.self, forCellReuseIdentifier: EWDragTableViewCell.identifier)
        self.view.addSubview(tableView)

        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
            tableView.dragInteractionEnabled = true
            tableView.contentInsetAdjustmentBehavior = .never
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? modelArray.count : secondModelArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EWDragTableViewCell.identifier) as? EWDragTableViewCell else {
            return EWDragTableViewCell()
        }
        var model: EWColorModel
        if indexPath.section == 0 {
            model = modelArray[indexPath.row]
        }else{
            model = secondModelArray[indexPath.row]
        }
        cell.textLabel?.text = model.title
        cell.backgroundColor = model.color
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.row < tableView.numberOfRows(inSection: destinationIndexPath.section) else { return }
        objc_sync_enter(self)
        let model: EWColorModel = sourceIndexPath.section == 0 ? modelArray[sourceIndexPath.row] : secondModelArray[sourceIndexPath.row]
        if sourceIndexPath.section == 0 {
            modelArray.remove(at: sourceIndexPath.row)
        }else {
            secondModelArray.remove(at: sourceIndexPath.row)
        }
        if destinationIndexPath.section == 0{
            if destinationIndexPath.row == modelArray.count{
                modelArray.append(model)
            }else{
                modelArray.insert(model, at: destinationIndexPath.row)
            }
        }else {
            if destinationIndexPath.row == modelArray.count{
                secondModelArray.append(model)
            }else {
                secondModelArray.insert(model, at: destinationIndexPath.row)
            }
        }
        objc_sync_exit(self)
        tableView.reloadData()
    }
}

func swap<T>(_ chars: inout [T], _ p: Int, _ q: Int){
    let char = chars[p]
    chars.remove(at: p)
    chars.insert(char, at: q)
}

//MARK: - UITableView ios11以上拖拽dragDelegate
extension ViewController:UITableViewDragDelegate,UITableViewDropDelegate{
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = UIDragItem(itemProvider: NSItemProvider(object: UIImage()))
        return [item]
    }
    // MARK: UITableViewDropDelegate
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {

    }
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        // Only receive image data
        return session.canLoadObjects(ofClass: UIImage.self)
    }
}

struct EWColorModel {
    var title: String?
    var color: UIColor?
}
