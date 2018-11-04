//
//  MJTableViewCellModel.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit

public struct MJTableViewCellModel<CellModel> {
    public let tableView: UITableView
    public let indexPath: IndexPath
    public let cell: CellModel
}
