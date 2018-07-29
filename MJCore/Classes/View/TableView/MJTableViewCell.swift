//
//  MJTableViewCell.swift
//  MJCore
//
//  Created by Martin Janák on 29/07/2018.
//

import UIKit

open class MJTableViewCell<CellModel>: UITableViewCell {
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    open func setup() {
        fatalError("setup() has not been implemented")
    }
    
    open func setup(row: Int, model: CellModel) {
        fatalError("setup(row:,model:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
