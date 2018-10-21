//
//  MJTableViewLCS.swift
//  MJCore
//
//  Created by Martin Janák on 19/10/2018.
//

import UIKit
import RxSwift
import RxCocoa

open class MJTableViewLCS<TableModel: MJTableCellModelType>
    : UITableView
    , UITableViewDataSource
    , UITableViewDelegate {
    
    private typealias CellConstructor = (TableModel) -> (
        ((UITableView, IndexPath) -> UITableViewCell)?
    )
    
    private let disposeBag = DisposeBag()
    
    public let data = Variable([TableModel]())
    private var cellConstructors = [CellConstructor]()
    
    public var willSelectItem: (IndexPath) -> IndexPath? = { $0 }
    public var willDeselectItem: (IndexPath) -> IndexPath? = { $0 }
    
    private let didSelectItemSubject = PublishSubject<IndexPath>()
    public lazy var didSelectItem = didSelectItemSubject.asObservable()
    
    private let didDeselectItemSubject = PublishSubject<IndexPath>()
    public lazy var didDeselectItem = didDeselectItemSubject.asObservable()
    
    private let didSelectModelSubject = PublishSubject<TableModel?>()
    public lazy var didDeselectModel = didSelectModelSubject
        .asDriver(onErrorJustReturn: nil)
        .unwrap()
    
    public func didSelectModel<Model>(_ modelType: Model.Type) -> Driver<Model> {
        return didSelectModelSubject
            .asDriver(onErrorJustReturn: nil)
            .cast(Model.self)
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
        data.asObservable()
            .scanPrevious()
            .bind(onNext: { [weak self] scanner in
                guard let strongSelf = self else { return }
                if let previousData = scanner.previous,
                    let currentData = scanner.current,
                    previousData.count > 0,
                    currentData.count > 0 {
                    let tableChange = previousData.tableChange(with: currentData)
                    if tableChange.hasAny {
                        DispatchQueue.main.async {
                            strongSelf.apply(changes: tableChange)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        strongSelf.reloadData()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Homogenous table
    
    public func register<Cell: MJTableViewCell<TableModel>>(
        _ cellClass: Cell.Type,
        additionalSetup: ((UITableView, IndexPath, TableModel, inout Cell) -> Void)? = nil
        ) {
        let cellId = "\(cellClass)Id"
        register(cellClass, forCellReuseIdentifier: cellId)
        cellConstructors.append({ cellModel in
            return { tableView, indexPath in
                if var cell = tableView.dequeueReusableCell(
                    withIdentifier: cellId,
                    for: indexPath
                    ) as? Cell {
                    cell.setup(tableView: tableView, indexPath: indexPath, model: cellModel)
                    additionalSetup?(tableView, indexPath, cellModel, &cell)
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
        additionalSetup: ((UITableView, IndexPath, CellModel, inout Cell) -> Void)? = nil
        ) {
        let cellId = "\(cellClass)Id"
        register(cellClass, forCellReuseIdentifier: cellId)
        cellConstructors.append({ tableModel in
            if let cellModel = tableModel as? CellModel {
                return { tableView, indexPath in
                    if var cell = tableView.dequeueReusableCell(
                        withIdentifier: cellId,
                        for: indexPath
                        ) as? Cell {
                        cell.setup(tableView: tableView, indexPath: indexPath, model: cellModel)
                        additionalSetup?(tableView, indexPath, cellModel, &cell)
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
                return cellSetup(tableView, indexPath)
            }
        }
        return UITableViewCell()
    }
    
    // MARK: Delegate
    
    public func tableView(
        _ tableView: UITableView,
        willSelectRowAt indexPath: IndexPath
        ) -> IndexPath? {
        return willSelectItem(indexPath)
    }
    
    public func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        didSelectItemSubject.onNext(indexPath)
        let model = data.value[indexPath.item]
        didSelectModelSubject.onNext(model)
    }
    
    public func tableView(
        _ tableView: UITableView,
        willDeselectRowAt indexPath: IndexPath
        ) -> IndexPath? {
        return willDeselectItem(indexPath)
    }
    
    public func tableView(
        _ tableView: UITableView,
        didDeselectRowAt indexPath: IndexPath
        ) {
        didDeselectItemSubject.onNext(indexPath)
    }
    
    // MARK: animations
    
    private var reloadAnimation: UITableViewRowAnimation = .fade
    private var insertAnimation: UITableViewRowAnimation = .fade
    private var deleteAnimation: UITableViewRowAnimation = .fade
    
    public func setAnimations(
        reload: UITableViewRowAnimation,
        insert: UITableViewRowAnimation,
        delete: UITableViewRowAnimation
    ) {
        reloadAnimation = reload
        insertAnimation = insert
        deleteAnimation = delete
    }
    
    private func apply(changes: MJTableChange<TableModel>) {
        beginUpdates()
        deleteRows(at: changes.deletes.map { IndexPath(item: $0.index, section: 0) }, with: deleteAnimation)
        insertRows(at: changes.inserts.map { IndexPath(item: $0.index, section: 0) }, with: insertAnimation)
        reloadRows(at: changes.updates.map { IndexPath(item: $0.index, section: 0) }, with: reloadAnimation)
        endUpdates()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
