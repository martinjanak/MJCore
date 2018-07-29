//
//  MJAutoresizingCollectionView.swift
//  MJCore
//
//  Created by Martin Janák on 24/07/2018.
//

import UIKit
import Stevia

open class MJResizingCollectionView<CollectionModel>: MJCollectionView<CollectionModel> {
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        heightConstraint?.constant = collectionViewLayout.collectionViewContentSize.height
    }
    
}
