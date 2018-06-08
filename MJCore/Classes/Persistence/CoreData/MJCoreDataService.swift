//
//  MJCoreDataService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import CoreData
import RxSwift
import RxCocoa

public protocol HasCoreData {
    var coreData: MJCoreDataService { get }
}

public enum MJCoreDataError: Error {
    case couldNotCastToEntity
    case entityDoesNotExist
    case modelHasNoId
    case serviceUnavailable
}

public final class MJCoreDataService {
    
    private let modelName: String
    
    public init(modelName: String) {
        self.modelName = modelName
    }
    
    public func saveChanges() -> Observable<MJResultSimple> {
        return transactionSimple { strongSelf in
            try strongSelf.saveChangesSync()
        }
    }
    
    public func saveChangesSync() throws -> Void {
        if privateContext.hasChanges {
            try privateContext.save()
        }
    }
    
    private(set) lazy var privateContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            let options = [
                NSInferMappingModelAutomaticallyOption: true,
                NSMigratePersistentStoresAutomaticallyOption: true
            ]
            
            try persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: persistentStoreURL,
                options: options
            )
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
    
//    public func transaction(_ block: @escaping () -> Void) {
//        privateContext.perform {
//            block()
//        }
//    }
    
    public func transaction<V>(_ block: @escaping (MJCoreDataService) throws -> V) -> Observable<MJResult<V>> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            strongSelf.privateContext.perform {
                observer.onNext(MJResult {
                    return try block(strongSelf)
                })
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    public func transactionSimple(_ block: @escaping (MJCoreDataService) throws -> Void) -> Observable<MJResultSimple> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            strongSelf.privateContext.perform {
                observer.onNext(MJResultSimple {
                    try block(strongSelf)
                })
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // MARK: CRUD
    
    // MARK: Create
    
    public func createSync<Model: MJCoreDataModel>(_ model: Model) throws -> Model {
        _ = try model.createEntity(context: self.privateContext)
        return model
    }
    
    public func createSync<Model: MJCoreDataModel>(_ models: [Model]) throws -> [Model] {
        for model in models {
            _ = try model.createEntity(context: self.privateContext)
        }
        return models
    }
    
    public func create<Model: MJCoreDataModel>(_ model: Model) -> Observable<MJResult<Model>> {
        return transaction { strongSelf in
            _ = try strongSelf.createSync(model)
            try strongSelf.saveChangesSync()
            return model
        }
    }
    
    public func create<Model: MJCoreDataModel>(_ models: [Model]) -> Observable<MJResult<[Model]>> {
        return transaction { strongSelf in
            _ = try strongSelf.createSync(models)
            try strongSelf.saveChangesSync()
            return models
        }
    }
    
    // MARK: Update
    
    public func updateSync<Model: MJCoreDataModel>(_ model: Model) throws -> Model {
        guard let id = model.id else {
            throw MJCoreDataError.modelHasNoId
        }
        let existingEntity = self.privateContext.object(with: id)
        if !existingEntity.isFault {
            self.privateContext.delete(existingEntity)
            _ = try model.createEntity(context: self.privateContext)
            return model
        } else {
            throw MJCoreDataError.entityDoesNotExist
        }
    }
    
    public func updateSync<Model: MJCoreDataModel>(_ models: [Model]) throws -> [Model] {
        let allHaveId = models.reduce(true, { result, model in
            return result && model.id != nil
        })
        guard allHaveId else {
            throw MJCoreDataError.modelHasNoId
        }
        var success = true
        for model in models {
            let existingEntity = self.privateContext.object(with: model.id!)
            if !existingEntity.isFault {
                self.privateContext.delete(existingEntity)
                _ = try model.createEntity(context: self.privateContext)
            } else {
                success = false
            }
        }
        if success {
            return models
        } else {
            throw MJCoreDataError.entityDoesNotExist
        }
    }
    
    public func update<Model: MJCoreDataModel>(_ model: Model) -> Observable<MJResult<Model>> {
        return transaction { strongSelf in
            _ = try strongSelf.updateSync(model)
            try strongSelf.saveChangesSync()
            return model
        }
    }
    
    public func update<Model: MJCoreDataModel>(_ models: [Model]) -> Observable<MJResult<[Model]>> {
        return transaction { strongSelf in
            _ = try strongSelf.updateSync(models)
            try strongSelf.saveChangesSync()
            return models
        }
    }
    
    // MARK: Read
    
    public func readSync<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        filter: MJCoreDataFilter? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil
    ) throws -> [Model] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
            entityName: String(describing: Model.Entity.self)
        )
        if let filter = filter {
            guard let predicate = filter.predicate else {
                throw MJCoreDataFilterError.valueMismatch
            }
            fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        
        let rawData = try self.privateContext.fetch(fetchRequest)
        if let entities = rawData as? [Model.Entity] {
            let data = try entities.map({ try Model(entity: $0) })
            return data
        } else {
            throw MJCoreDataError.couldNotCastToEntity
        }
    }
    
    public func readOneSync<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        filter: MJCoreDataFilter? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> Model? {
        let models = try readSync(
            modelType,
            filter: filter,
            sortDescriptors: sortDescriptors,
            limit: 1
        )
        if models.count > 0 {
            return models[0]
        } else {
            return nil
        }
    }
    
    public func read<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        filter: MJCoreDataFilter? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil
    ) -> Observable<MJResult<[Model]>> {
        return transaction { strongSelf in
            return try strongSelf.readSync(
                modelType,
                filter: filter,
                sortDescriptors: sortDescriptors,
                limit: limit
            )
        }
    }
    
    public func readOne<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        filter: MJCoreDataFilter? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> Observable<MJResult<Model?>> {
        return transaction { strongSelf in
            return try strongSelf.readOneSync(
                modelType,
                filter: filter,
                sortDescriptors: sortDescriptors
            )
        }
    }
    
    // MARK: Delete
    
    public func deleteSync<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        filter: MJCoreDataFilter? = nil
    ) throws -> Void {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
            entityName: String(describing: Model.Entity.self)
        )
        if let filter = filter {
            guard let predicate = filter.predicate else {
                throw MJCoreDataFilterError.valueMismatch
            }
            fetchRequest.predicate = predicate
        }
        
        let rawData = try self.privateContext.fetch(fetchRequest)
        if let entities = rawData as? [Model.Entity] {
            for entity in entities {
                self.privateContext.delete(entity)
            }
        } else {
            throw MJCoreDataError.couldNotCastToEntity
        }
    }
    
    public func delete<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        filter: MJCoreDataFilter? = nil
    ) -> Observable<MJResultSimple> {
        return transactionSimple { strongSelf in
            try strongSelf.deleteSync(modelType, filter: filter)
            try strongSelf.saveChangesSync()
        }
    }
    
}
