//
//  MJStackViewCellModel.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit

public struct MJStackViewCellModel<CellModel> {
    public let stackView: UIStackView
    public let index: Int
    public let cell: CellModel
}
