//
//  MJStackViewCellModel.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit

public struct MJStackViewCellModel<Model> {
    let stackView: UIStackView
    let index: Int
    let model: Model
}
