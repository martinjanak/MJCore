//
//  MJTableViewCellModel.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit

public struct MJTableViewCellModel<CellModel> {
    let tableView: UITableView
    let indexPath: IndexPath
    let cell: CellModel
}
