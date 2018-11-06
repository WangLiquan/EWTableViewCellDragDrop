//
//  EWPlainTableViewController.swift
//  EWTableViewCellDragDrop
//
//  Created by Ethan.Wang on 2018/11/6.
//  Copyright © 2018 Ethan. All rights reserved.
//

import UIKit

class EWPlainTableViewController: UIViewController {

    private var tableView:UITableView!
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
    private var touchPoints: [CGPoint] = []
    private var sourceIndexPath: IndexPath?
    private var cellImageView = UIImageView()
    private var gestureRecognizer: UILongPressGestureRecognizer?
    private var currentCell:EWDragTableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        tableView = UITableView(frame: CGRect(x: 0, y: 88, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 88), style: .plain)
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
    private func dragCell(cell:UITableViewCell?){
        if #available(iOS 11.0, *)  {
            cell?.userInteractionEnabledWhileDragging = true
        }else {
            let pan = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGesture))
            cell?.addGestureRecognizer(pan)
        }
    }
}

//MARK: - UITableView ios11以下版本拖拽
extension EWPlainTableViewController{
    @objc func longPressGesture(_ recognise: UILongPressGestureRecognizer) {
        let currentPoint: CGPoint = recognise.location(in: tableView)
        let currentIndexPath = tableView.indexPathForRow(at: currentPoint)
        guard let indexPath = currentIndexPath else {
            initCellImageView()
            return
        }
        guard indexPath.row < self.modelArray.count else {
            initCellImageView()
            return
        }
        switch recognise.state {
        case .began:
            longPressGestureBegan(recognise)
            break
        case .changed:
            longPressGestureChanged(recognise)
            break
        default:
            self.touchPoints.removeAll()
            if let cell = tableView.cellForRow(at: sourceIndexPath! ){
                cell.isHidden = false
            }
            initCellImageView()
            break
        }
    }
    private func longPressGestureBegan(_ recognise: UILongPressGestureRecognizer) {
        self.gestureRecognizer = recognise
        let currentPoint: CGPoint = recognise.location(in: tableView)
        let currentIndexPath = tableView.indexPathForRow(at: currentPoint)
        if (currentIndexPath != nil) {
            sourceIndexPath = currentIndexPath
            currentCell = tableView.cellForRow(at: currentIndexPath! ) as? EWDragTableViewCell
            cellImageView = getImageView(currentCell)
            cellImageView.frame = currentCell.frame
            tableView.addSubview(cellImageView)
            self.currentCell.isHidden = true
        }
    }
    private func longPressGestureChanged(_ recognise: UILongPressGestureRecognizer) {
        let selectedPoint: CGPoint = recognise.location(in: tableView)
        var selectedIndexPath = tableView.indexPathForRow(at: selectedPoint)
        self.touchPoints.append(selectedPoint)
        if self.touchPoints.count > 2 {
            self.touchPoints.remove(at: 0)
        }
        var center = cellImageView.center
        center.y = selectedPoint.y
        // 快照随触摸点x值改变量移动
        let Ppoint = self.touchPoints.first
        let Npoint = self.touchPoints.last
        let moveX = Npoint!.x - Ppoint!.x
        center.x += moveX
        cellImageView.center = center
        if ((selectedIndexPath != nil) && selectedIndexPath != sourceIndexPath) {
            tableView.beginUpdates()
            var cellmode: EWColorModel
            cellmode = modelArray[sourceIndexPath!.row]
            self.modelArray.remove(at: sourceIndexPath!.row)
            objc_sync_enter(self)
            if selectedIndexPath!.row < self.modelArray.count {
                self.modelArray.insert(cellmode, at: selectedIndexPath!.row)
            }else {
                self.modelArray.append(cellmode)
            }
            objc_sync_exit(self)
            self.tableView.moveRow(at: sourceIndexPath!, to: selectedIndexPath!)
            tableView.endUpdates()
            sourceIndexPath = selectedIndexPath
        }
    }
    private func initCellImageView() {
        self.cellImageView.removeFromSuperview()
        tableView.reloadData()
    }
    // 截图
    private func getImageView(_ cell: UITableViewCell) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(image: image)
        return imageView
    }
}

extension EWPlainTableViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EWDragTableViewCell.identifier) as? EWDragTableViewCell else {
            return EWDragTableViewCell()
        }
        var model: EWColorModel
        model = modelArray[indexPath.row]
        dragCell(cell: cell)
        cell.textLabel?.text = model.title
        cell.backgroundColor = model.color
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        objc_sync_enter(self)
        let model: EWColorModel = modelArray[sourceIndexPath.row]
        modelArray.remove(at: sourceIndexPath.row)
        if destinationIndexPath.row > modelArray.count{
            modelArray.append(model)
        }else{
            modelArray.insert(model, at: destinationIndexPath.row)
        }
        objc_sync_exit(self)
        tableView.reloadData()
    }
}
//MARK: - UITableView ios11以上拖拽dragDelegate
extension EWPlainTableViewController:UITableViewDragDelegate,UITableViewDropDelegate{
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
