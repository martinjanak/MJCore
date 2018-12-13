//
//  MJGroupTableView.swift
//  MJCore
//
//  Created by Martin Janák on 13/12/2018.
//

import UIKit
import RxSwift
import RxCocoa

open class MJGroupTableView<TableModel: MJGroupElementType>
    : UITableView
    , UITableViewDataSource
    , UITableViewDelegate {
    
    private typealias CellConstructor = (TableModel) -> (
        ((UITableView, IndexPath) -> UITableViewCell)?
    )
    
    private let disposeBag = DisposeBag()
    
    public let data = MJGroup<TableModel>()
    private var elementsTemp: [TableModel]?
    private var cellConstructors = [CellConstructor]()
    
    public var willSelectItem: (IndexPath) -> IndexPath? = { $0 }
    public var willDeselectItem: (IndexPath) -> IndexPath? = { $0 }
    
    private let didSelectItemRelay = PublishRelay<IndexPath>()
    public lazy var didSelectItem = didSelectItemRelay.asObservable()
    
    private let didDeselectItemRelay = PublishRelay<IndexPath>()
    public lazy var didDeselectItem = didDeselectItemRelay.asObservable()
    
    private let didSelectModelRelay = PublishRelay<TableModel?>()
    public lazy var didDeselectModel = didSelectModelRelay
        .asDriver(onErrorJustReturn: nil)
        .unwrap()
    
    public func didSelectModel<Model>(_ modelType: Model.Type) -> Driver<Model> {
        return didSelectModelRelay
            .asDriver(onErrorJustReturn: nil)
            .cast(Model.self)
    }
    
    public init() {
        super.init(frame: .zero, style: .plain)
        initSetup()
    }
    
    public init(style: UITableView.Style) {
        super.init(frame: .zero, style: style)
        initSetup()
    }
    
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        initSetup()
    }
    
    private func initSetup() {
        backgroundColor = .clear
        delegate = self
        dataSource = self
        initView()
        initBindings()
    }
    
    open func initView() {
        // optional override
    }
    
    private func initBindings() {
        data
            .asObservable()
            .observeOn(MainScheduler.instance)
            .bind { [weak self] change in
                guard let strongSelf = self else { return }
                switch change {
                case .initialization(let elements):
                    strongSelf.elementsTemp = elements
                    strongSelf.reloadData {
                        strongSelf.elementsTemp = nil
                    }
                case .model(let operations):
                    strongSelf.apply(operations: operations)
                case .cyclicPermutation(let index, let count):
                    strongSelf.applyCyclicPermutation(index: index, count: count)
                }
            }
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
                    cell.model.accept(MJTableViewCellModel(
                        tableView: tableView,
                        indexPath: indexPath,
                        cell: cellModel
                    ))
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
                        cell.model.accept(MJTableViewCellModel(
                            tableView: tableView,
                            indexPath: indexPath,
                            cell: cellModel
                        ))
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
        return elementsTemp?.count ?? 0
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let model = elementsTemp?[indexPath.item] else {
            return UITableViewCell()
        }
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
        didSelectItemRelay.accept(indexPath)
        if let model = data.getElement(at: indexPath.item) {
            didSelectModelRelay.accept(model)
        }
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
        didDeselectItemRelay.accept(indexPath)
    }
    
    // MARK: animations
    
    private var reloadAnimation: UITableView.RowAnimation = .fade
    private var insertAnimation: UITableView.RowAnimation = .fade
    private var deleteAnimation: UITableView.RowAnimation = .fade
    
    public func setAnimations(
        reload: UITableView.RowAnimation,
        insert: UITableView.RowAnimation,
        delete: UITableView.RowAnimation
    ) {
        reloadAnimation = reload
        insertAnimation = insert
        deleteAnimation = delete
    }
    
    private func apply(operations: MJGroupModelOperations<TableModel>) {
        beginUpdates()
        deleteRows(at: operations.deletes.map { IndexPath(item: $0.index, section: 0) }, with: deleteAnimation)
        insertRows(at: operations.inserts.map { IndexPath(item: $0.index, section: 0) }, with: insertAnimation)
        reloadRows(at: operations.updates.map { IndexPath(item: $0.index, section: 0) }, with: reloadAnimation)
        endUpdates()
    }
    
    private func applyCyclicPermutation(index: Int, count: Int) {
        beginUpdates()
        for i in index..<count {
            moveRow(
                at: IndexPath(row: i, section: 0),
                to: IndexPath(row: i-index, section: 0)
            )
        }
        endUpdates()
    }
    
    // MARK: Helpers
    
    public func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0,
            animations: {
                self.reloadData()
            }
        ) { _ in
            completion()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
