//
//  EWDragTableViewCell.swift
//  EWTableViewCellDragDrop
//
//  Created by Ethan.Wang on 2018/10/31.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

class EWDragTableViewCell: UITableViewCell {
    static let identifier = "EWDragTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        drawMyView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func drawMyView() {

    }
}
