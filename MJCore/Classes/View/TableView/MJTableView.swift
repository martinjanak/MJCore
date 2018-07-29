//
//  MJTableView.swift
//  MJCore
//
//  Created by Martin Janák on 29/07/2018.
//

import UIKit
import RxSwift
import RxCocoa

open class MJTableView<TableModel>
    : UITableView
    , UITableViewDataSource
    , UITableViewDelegate {
    
    private typealias CellConstructor = (TableModel) -> (
        ((UITableView, IndexPath, TableModel) -> UITableViewCell)?
    )
    
    private let disposeBag = DisposeBag()
    
    public let data = Variable([TableModel]())
    private var cellConstructors = [CellConstructor]()
    
    public var willSelectRow: (IndexPath) -> IndexPath? = { $0 }
    public var willDeselectRow: (IndexPath) -> IndexPath? = { $0 }
    
    private let didSelectRowSubject = PublishSubject<IndexPath>()
    public lazy var didSelectRow = didSelectRowSubject.asObservable()
    
    private let didDeselectItemSubject = PublishSubject<IndexPath>()
    public lazy var didDeselectItem = didDeselectItemSubject.asObservable()
    
    private let didSelectModelSubject = PublishSubject<TableModel?>()
    public lazy var didDeselectModel = didSelectModelSubject.asDriver(onErrorJustReturn: nil)
        .filter { $0 != nil }
        .map { $0! }
    
    public func didSelectModel<Model>(_ modelType: Model.Type) -> Driver<Model> {
        return didSelectModelSubject.asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil && $0 is Model }
            .map { $0 as! Model }
    }
    
    public init() {
        super.init(frame: .zero, style: .plain)
        initSetup()
    }
    
    public init(style: UITableViewStyle) {
        super.init(frame: .zero, style: style)
        initSetup()
    }
    
    override public init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initSetup()
    }
    
    private func initSetup() {
        backgroundColor = .clear
        delegate = self
        dataSource = self
        setup()
        initBindings()
    }
    
    open func setup() {
        // optional override
    }
    
    private func initBindings() {
        data.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Homogenous table
    
    public func register<Cell: MJTableViewCell<TableModel>>(
        _ cellClass: Cell.Type,
        additionalSetup: ((inout Cell) -> Void)? = nil
    ) {
        let cellId = "\(cellClass)Id"
        register(cellClass, forCellReuseIdentifier: cellId)
        cellConstructors.append({ cellModel in
            return { tableView, indexPath, model in
                if var cell = tableView.dequeueReusableCell(
                    withIdentifier: cellId,
                    for: indexPath
                ) as? Cell {
                    cell.setup(row: indexPath.item, model: cellModel)
                    additionalSetup?(&cell)
                    return cell
                }
                return UITableViewCell()
            }
        })
    }
    
    // MARK: Heterogenous table
    // - CellModel has to implement CollectionModel protocol or extend CollectionModel class
    
    public func register<CellModel, Cell: MJTableViewCell<CellModel>>(
        _ cellClass: Cell.Type,
        additionalSetup: ((inout Cell) -> Void)?
    ) {
        let cellId = "\(cellClass)Id"
        register(cellClass, forCellReuseIdentifier: cellId)
        cellConstructors.append({ collectionModel in
            if let cellModel = collectionModel as? CellModel {
                return { tableView, indexPath, model in
                    if var cell = tableView.dequeueReusableCell(
                        withIdentifier: cellId,
                        for: indexPath
                    ) as? Cell {
                        cell.setup(row: indexPath.item, model: cellModel)
                        additionalSetup?(&cell)
                        return cell
                    }
                    return UITableViewCell()
                }
            } else {
                return nil
            }
        })
    }
    
    // MARK: Data source
    
    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return data.value.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let model = data.value[indexPath.item]
        for cellConstructor in cellConstructors {
            if let cellSetup = cellConstructor(model) {
                return cellSetup(tableView, indexPath, model)
            }
        }
        return UITableViewCell()
    }
    
    // MARK: Delegate
    
    public func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        return willSelectRow(indexPath)
    }
    
    public func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        didSelectRowSubject.onNext(indexPath)
        let model = data.value[indexPath.item]
        didSelectModelSubject.onNext(model)
    }
    
    public func tableView(
        _ tableView: UITableView,
        willDeselectRowAt indexPath: IndexPath
    ) -> IndexPath? {
        return willDeselectRow(indexPath)
    }
    
    public func tableView(
        _ tableView: UITableView,
        didDeselectRowAt indexPath: IndexPath
    ) {
        didDeselectItemSubject.onNext(indexPath)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
