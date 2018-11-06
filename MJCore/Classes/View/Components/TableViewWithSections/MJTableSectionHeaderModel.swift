//
//  MJTableViewSectionModel.swift
//  MJCore
//
//  Created by Martin Janák on 04/11/2018.
//

import UIKit

public struct MJTableSectionHeaderModel<HeaderModel> {
    public let tableView: UITableView
    public let section: Int
    public let header: HeaderModel
}
