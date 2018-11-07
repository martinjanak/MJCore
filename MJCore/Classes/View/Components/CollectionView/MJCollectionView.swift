//
//  MJCollectionView.swift
//  MJCore
//
//  Created by Martin Janák on 29/07/2018.
//

import UIKit
import RxSwift
import RxCocoa

open class MJCollectionView<CollectionModel>
    : UICollectionView
    , UICollectionViewDataSource
    , UICollectionViewDelegate {
    
    private typealias CellConstructor = (CollectionModel) -> (
        ((UICollectionView, IndexPath) -> UICollectionViewCell)?
    )
    
    private let disposeBag = DisposeBag()
    
    public let data = BehaviorRelay(value: [CollectionModel]())
    private var cellConstructors = [CellConstructor]()
    
    public var shouldSelectItem: (IndexPath) -> Bool = { _ in true }
    public var shouldDeselectItem: (IndexPath) -> Bool = { _ in true }
    
    private let didSelectItemRelay = PublishRelay<IndexPath>()
    public lazy var didSelectItem = didSelectItemRelay.asObservable()
    
    private let didDeselectItemRelay = PublishRelay<IndexPath>()
    public lazy var didDeselectItem = didDeselectItemRelay.asObservable()
    
    private let didSelectModelRelay = PublishRelay<CollectionModel?>()
    public lazy var didDeselectModel = didSelectModelRelay.asDriver(onErrorJustReturn: nil)
        .filter { $0 != nil }
        .map { $0! }
    
    public func didSelectModel<Model>(_ modelType: Model.Type) -> Driver<Model> {
        return didSelectModelRelay.asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil && $0 is Model }
            .map { $0 as! Model }
    }
    
    public var resizesHeight: Bool = false
    
    public init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        initSetup()
    }
    
    public init(
        collectionViewLayout layout: UICollectionViewLayout
    ) {
        super.init(frame: .zero, collectionViewLayout: layout)
        initSetup()
    }
    
    override public init(
        frame: CGRect,
        collectionViewLayout layout: UICollectionViewLayout
    ) {
        super.init(frame: frame, collectionViewLayout: layout)
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
        data.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if resizesHeight {
            heightConstraint?.constant = collectionViewLayout.collectionViewContentSize.height
        }
    }
    
    // MARK: Homogenous collection
    
    public func register<Cell: MJCollectionViewCell<CollectionModel>>(
        _ cellClass: Cell.Type,
        additionalSetup: ((UICollectionView, IndexPath, CollectionModel, inout Cell) -> Void)?
    ) {
        let cellId = "\(cellClass)Id"
        register(cellClass, forCellWithReuseIdentifier: cellId)
        cellConstructors.append({ cellModel in
            return { collectionView, indexPath in
                if var cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: cellId,
                    for: indexPath
                ) as? Cell {
                    cell.model.accept(MJCollectionViewCellModel(
                        collectionView: collectionView,
                        indexPath: indexPath,
                        cell: cellModel
                    ))
                    additionalSetup?(collectionView, indexPath, cellModel, &cell)
                    return cell
                }
                return UICollectionViewCell()
            }
        })
    }
    
    // MARK: Heterogenous collection
    // - CellModel has to implement CollectionModel protocol or extend CollectionModel class
    
    public func register<CellModel, Cell: MJCollectionViewCell<CellModel>>(
        _ cellClass: Cell.Type,
        additionalSetup: ((UICollectionView, IndexPath, CellModel, inout Cell) -> Void)? = nil
    ) {
        let cellId = "\(cellClass)Id"
        register(cellClass, forCellWithReuseIdentifier: cellId)
        cellConstructors.append({ collectionModel in
            if let cellModel = collectionModel as? CellModel {
                return { collectionView, indexPath in
                    if var cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: cellId,
                        for: indexPath
                    ) as? Cell {
                        cell.model.accept(MJCollectionViewCellModel(
                            collectionView: collectionView,
                            indexPath: indexPath,
                            cell: cellModel
                        ))
                        additionalSetup?(collectionView, indexPath, cellModel, &cell)
                        return cell
                    }
                    return UICollectionViewCell()
                }
            } else {
                return nil
            }
        })
    }
    
    // MARK: Data source
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return data.value.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let model = data.value[indexPath.item]
        for cellConstructor in cellConstructors {
            if let cellSetup = cellConstructor(model) {
                return cellSetup(collectionView, indexPath)
            }
        }
        return UICollectionViewCell()
    }
    
    // MARK: Delegate
    
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        return shouldSelectItem(indexPath)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        didSelectItemRelay.accept(indexPath)
        let model = data.value[indexPath.item]
        didSelectModelRelay.accept(model)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldDeselectItemAt indexPath: IndexPath
    ) -> Bool {
        return shouldDeselectItem(indexPath)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        didDeselectItemRelay.accept(indexPath)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
