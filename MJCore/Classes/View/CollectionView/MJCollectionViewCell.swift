//
//  MJCollectionViewCell.swift
//  MJCore
//
//  Created by Martin Janák on 29/07/2018.
//

import UIKit

open class MJCollectionViewCell<CellModel>: UICollectionViewCell {
    
    override public init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    open func setup() {
        // optional override
    }
    
    open func setup(collectionView: UICollectionView, indexPath: IndexPath, model: CellModel) {
        fatalError("setup(row:,model:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
