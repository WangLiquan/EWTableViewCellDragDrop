//
//  EWPlainTableViewController.swift
//  EWTableViewCellDragDrop
//
//  Created by Ethan.Wang on 2018/11/6.
//  Copyright © 2018 Ethan. All rights reserved.
//

import UIKit
/// plain型tableView.一个section
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
    /*
     * iOS11以下型号,通过自己写长按手势实现拖拽功能,需要如下属性
     */
    /// 手势储存point,保证有两个,为初始点和结束点
    private var touchPoints: [CGPoint] = []
    /// 手势选中cell.index
    private var sourceIndexPath: IndexPath?
    /// 将手势选中cell以image形式表现
    private var cellImageView = UIImageView()
    /// 被手势选中的cell
    private var currentCell:EWDragTableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
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
            /// 程序内拖拽功能开启,默认ipad为true,iphone为false
            tableView.dragInteractionEnabled = true
            /// 系统自动调整scrollView.contentInset保证滚动视图不被tabbar,navigationbar遮挡
            tableView.contentInsetAdjustmentBehavior = .scrollableAxes
        } else {
            /// 系统自动调整scrollView.contentInset保证滚动视图不被tabbar,navigationbar遮挡
            self.automaticallyAdjustsScrollViewInsets = true
        }
    }
    /// 为cell注册拖拽方法
    private func dragCell(cell:UITableViewCell?){
        if #available(iOS 11.0, *)  {
            cell?.userInteractionEnabledWhileDragging = true
        }else {
            let pan = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGesture))
            cell?.addGestureRecognizer(pan)
        }
    }
}
//MARK: - UITableView代理方法
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
}
//MARK: - UITableView ios11以下版本拖拽
extension EWPlainTableViewController{
    /***
     *  iOS11以下版本,实际上拖拽的不是cell,而是cell的快照imageView.并且同时将cell隐藏,当拖拽手势结束时,再调换cell位置,进行数据修改.并且将imageView删除.再将cell展示出来,就实现了拖拽动画.
     */
    /// 手势方法
    @objc func longPressGesture(_ recognise: UILongPressGestureRecognizer) {
        let currentPoint: CGPoint = recognise.location(in: tableView)
        let currentIndexPath = tableView.indexPathForRow(at: currentPoint)
        guard let indexPath = currentIndexPath else {
            /// 将生成的cellimage清除
            initCellImageView()
            return
        }
        guard indexPath.row < self.modelArray.count else {
            /// 将生成的cellimage清除
            initCellImageView()
            return
        }
        switch recognise.state {
        case .began:
            /// 手势开始状态
            longPressGestureBegan(recognise)
        case .changed:
            /// 手势拖拽状态
            longPressGestureChanged(recognise)
        default:
            /// 手势结束状态
            /// 清空保存的手势点
            self.touchPoints.removeAll()
            /// 将隐藏的cell展示
            if let cell = tableView.cellForRow(at: sourceIndexPath! ){
                cell.isHidden = false
            }
            /// 将生成的cellimage清除
            initCellImageView()
        }
    }
    /// 长按开始状态调用方法
    private func longPressGestureBegan(_ recognise: UILongPressGestureRecognizer) {
        /// 获取长按手势触发时的接触点
        let currentPoint: CGPoint = recognise.location(in: tableView)
        /// 根据手势初始点获取需要拖拽的cell.indexPath
        guard let currentIndexPath = tableView.indexPathForRow(at: currentPoint) else { return }
        /// 将拖拽cell.index储存
        sourceIndexPath = currentIndexPath
        /// 获取拖拽cell
        currentCell = tableView.cellForRow(at: currentIndexPath ) as? EWDragTableViewCell
        /// 获取拖拽cell快照
        cellImageView = getImageView(currentCell)
        /// 将快照加入到tableView.把拖拽cell覆盖
        cellImageView.frame = currentCell.frame
        tableView.addSubview(cellImageView)
        /// 将选中cell隐藏
        self.currentCell.isHidden = true
    }
    /// 拖拽手势过程中方法,核心方法,实现拖拽动画和数据的更新
    private func longPressGestureChanged(_ recognise: UILongPressGestureRecognizer) {
        let selectedPoint: CGPoint = recognise.location(in: tableView)
        var selectedIndexPath = tableView.indexPathForRow(at: selectedPoint)
        /// 将手势的点加入touchPoints并保证其内有两个点,即一个初始点,一个结束点,实现cell快照imageView从初始点到结束点的移动动画
        self.touchPoints.append(selectedPoint)
        if self.touchPoints.count > 2 {
            self.touchPoints.remove(at: 0)
        }
        var center = cellImageView.center
        center.y = selectedPoint.y
        // 快照x值随触摸点x值改变量移动,保证用户体验
        let Ppoint = self.touchPoints.first
        let Npoint = self.touchPoints.last
        let moveX = Npoint!.x - Ppoint!.x
        center.x += moveX
        cellImageView.center = center
        guard selectedIndexPath != nil else { return }
        /// 如果手势当前index不同于拖拽cell,则需要moveRow,实现tableView上非拖拽cell的动画,这里还要实现数据源的重置,保证拖拽手势后tableView能正确的展示
        if selectedIndexPath != sourceIndexPath {
            tableView.beginUpdates()
            /// 线程锁
            objc_sync_enter(self)
            /// 先更新tableView数据源
            var cellmode: EWColorModel
            cellmode = modelArray[sourceIndexPath!.row]
            self.modelArray.remove(at: sourceIndexPath!.row)
            if selectedIndexPath!.row < self.modelArray.count {
                self.modelArray.insert(cellmode, at: selectedIndexPath!.row)
            }else {
                self.modelArray.append(cellmode)
            }
            objc_sync_exit(self)
            /// 调用moveRow方法,修改被隐藏的选中cell位置,保证选中cell和快照imageView在同一个row,实现动画效果
            self.tableView.moveRow(at: sourceIndexPath!, to: selectedIndexPath!)
            tableView.endUpdates()
            sourceIndexPath = selectedIndexPath
        }
    }
    /// 将生成的cell快照删除
    private func removeCellImageView() {
        self.cellImageView.removeFromSuperview()
        self.cellImageView = UIImageView()
        tableView.reloadData()
    }
    private func initCellImageView() {
        self.cellImageView.removeFromSuperview()
        tableView.reloadData()
    }
    /// 获取cell快照imageView
    private func getImageView(_ cell: UITableViewCell) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(image: image)
        return imageView
    }
}
//MARK: - UITableView ios11以上拖拽drag,dropDelegate
extension EWPlainTableViewController:UITableViewDragDelegate,UITableViewDropDelegate{
    /***
     *  iOS11以上版本,实现UITableViewDragDelegate,UITableViewDropDelegate代理方法,使用原生方式实现拖拽功能.
     *  实际上实现这个代理是可以实现ipad上不同app之间的控件拖拽,因为我们只实现app内的拖拽,所以并不需要太多的处理
     */
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
    /// 这是UITableViewDataSourceDelegate中的方法,但是只有iOS11以上版本拖拽中才用的到,方便查看放在这里.
    /// 当拖拽完成时调用.将tableView数据源更新
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
