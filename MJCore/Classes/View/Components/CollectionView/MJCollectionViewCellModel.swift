//
//  MJCollectionViewCellModel.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit

public struct MJCollectionViewCellModel<CellModel> {
    public let collectionView: UICollectionView
    public let indexPath: IndexPath
    public let cell: CellModel
}
