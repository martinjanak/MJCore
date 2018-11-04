//
//  MJTableViewSectionModel.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit

public struct MJTableSectionHeaderModel<Model> {
    let tableView: UITableView
    let section: Int
    let model: Model
}
