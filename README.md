# EWTableViewCellDragDrop
以两种方法实现tableViewCell的拖拽功能.
---
# 实现方式:
* iOS11.0以上版本: 
实现UITableViewDragDelegate,UITableViewDropDelegate代理方法,使用原生方式实现拖拽功能.
* iOS11.0以下版本:
为cell添加长按拖拽手势方法.为cell生成快照imageView.实际上拖拽的不是cell,而是cell快照.并且同时将cell隐藏,当拖拽手势结束时,通过moveRow方法调换cell位置,进行数据修改.并且将imageView删除.再将cell展示出来,就实现了拖拽功能与动画

   

![效果图预览](https://github.com/WangLiquan/EWTableViewCellDragDrop/raw/master/images/demonstration.gif)
