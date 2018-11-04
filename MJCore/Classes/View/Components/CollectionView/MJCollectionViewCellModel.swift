//
//  MJCollectionViewCellModel.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit

public struct MJCollectionViewCellModel<Cell> {
    let collectionView: UICollectionView
    let indexPath: IndexPath
    let cell: Cell
}
