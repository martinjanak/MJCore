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
    
    public func saveChangesSync() -> MJResultSimple {
        return saveContextSync(privateContext)
    }
    
    public func saveChanges() -> Observable<MJResultSimple> {
        return saveContext(privateContext)
    }
    
    private func saveContext(_ context: NSManagedObjectContext) -> Observable<MJResultSimple> {
        let subject = PublishSubject<MJResultSimple>()
        context.perform {
            subject.onNext(self.saveContextSync(context))
        }
        return subject
    }
    
    private func saveContextSync(_ context: NSManagedObjectContext) -> MJResultSimple {
        return MJResultSimple {
            if context.hasChanges {
                try context.save()
            }
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
    
    public func transaction(_ block: @escaping () -> Void) {
        privateContext.perform {
            block()
        }
    }
    
    // MARK: CRUD
    
    // MARK: Create
    
    public func createSync<Model: MJCoreDataModel>(_ model: Model) {
        let _ = model.createEntity(context: self.privateContext)
    }
    
    public func createSync<Model: MJCoreDataModel>(_ models: [Model]) {
        for model in models {
            let _ = model.createEntity(context: self.privateContext)
        }
    }
    
    public func create<Model: MJCoreDataModel>(_ model: Model) -> Observable<MJResultSimple> {
        let subject = PublishSubject<MJResultSimple>()
        privateContext.perform {
            let _ = model.createEntity(context: self.privateContext)
            subject.onNext(MJResultSimple {
                if self.privateContext.hasChanges {
                    try self.privateContext.save()
                }
            })
        }
        return subject
    }
    
    public func create<Model: MJCoreDataModel>(_ models: [Model]) -> Observable<MJResultSimple> {
        let subject = PublishSubject<MJResultSimple>()
        privateContext.perform {
            for model in models {
                let _ = model.createEntity(context: self.privateContext)
            }
            subject.onNext(MJResultSimple {
                if self.privateContext.hasChanges {
                    try self.privateContext.save()
                }
            })
        }
        return subject
    }
    
    // MARK: Update
    
    public func updateSync<Model: MJCoreDataModel>(_ model: Model) -> MJResultSimple {
        
        guard let id = model.id else {
            return .failure(error: MJCoreDataError.modelHasNoId)
        }
        
        let existingEntity = self.privateContext.object(with: id)
        
        if !existingEntity.isFault {
            self.privateContext.delete(existingEntity)
            let _ = model.createEntity(context: self.privateContext)
            return .success
        } else {
            return .failure(error: MJCoreDataError.entityDoesNotExist)
        }
    }
    
    public func updateSync<Model: MJCoreDataModel>(_ models: [Model]) -> MJResultSimple {
        
        let allHaveId = models.reduce(true, { result, model in
            return result && model.id != nil
        })
        
        guard allHaveId else {
            return .failure(error: MJCoreDataError.modelHasNoId)
        }
        
        var success = true
        
        for model in models {
            let existingEntity = self.privateContext.object(with: model.id!)
            if !existingEntity.isFault {
                self.privateContext.delete(existingEntity)
                let _ = model.createEntity(context: self.privateContext)
            } else {
                success = false
            }
        }
        
        if success {
            return .success
        } else {
            return .failure(error: MJCoreDataError.entityDoesNotExist)
        }
    }
    
    public func update<Model: MJCoreDataModel>(_ model: Model) -> Observable<MJResultSimple> {
        
        guard let id = model.id else {
            return Observable<MJResultSimple>.just(
                .failure(error: MJCoreDataError.modelHasNoId)
            )
        }
        
        let subject = PublishSubject<MJResultSimple>()
        privateContext.perform {
            
            let existingEntity = self.privateContext.object(with: id)
            
            if !existingEntity.isFault {
                self.privateContext.delete(existingEntity)
                let _ = model.createEntity(context: self.privateContext)
                subject.onNext(MJResultSimple {
                    if self.privateContext.hasChanges {
                        try self.privateContext.save()
                    }
                })
            } else {
                subject.onNext(
                    .failure(error: MJCoreDataError.entityDoesNotExist)
                )
            }
        }
        return subject
    }
    
    // MARK: Read
    
    public func readSync<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> MJResult<[Model]> {
        
        let fetchRequest: NSFetchRequest = Model.Entity.fetchRequest()
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        return MJResult {
            let rawData = try self.privateContext.fetch(fetchRequest)
            if let entities = rawData as? [Model.Entity] {
                let data = entities.map({ Model(entity: $0) })
                return data
            } else {
                throw MJCoreDataError.couldNotCastToEntity
            }
        }
    }
    
    public func read<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) -> Observable<MJResult<[Model]>> {
        
        let subject = PublishSubject<MJResult<[Model]>>()
        
        let fetchRequest: NSFetchRequest = Model.Entity.fetchRequest()
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        privateContext.perform {
            subject.onNext(MJResult {
                let rawData = try self.privateContext.fetch(fetchRequest)
                if let entities = rawData as? [Model.Entity] {
                    let data = entities.map({ Model(entity: $0) })
                    return data
                } else {
                    throw MJCoreDataError.couldNotCastToEntity
                }
            })
        }
        return subject
    }
    
    // MARK: Delete
    
    public func deleteSync<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        predicate: NSPredicate? = nil
    ) -> MJResultSimple {
        
        let fetchRequest: NSFetchRequest = Model.Entity.fetchRequest()
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        return MJResultSimple {
            let rawData = try self.privateContext.fetch(fetchRequest)
            if let entities = rawData as? [Model.Entity] {
                for entity in entities {
                    self.privateContext.delete(entity)
                }
            } else {
                throw MJCoreDataError.couldNotCastToEntity
            }
        }
    }
    
    public func delete<Model: MJCoreDataModel>(
        _ modelType: Model.Type,
        predicate: NSPredicate? = nil
    ) -> Observable<MJResultSimple> {
        
        let subject = PublishSubject<MJResultSimple>()
        
        let fetchRequest: NSFetchRequest = Model.Entity.fetchRequest()
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        privateContext.perform {
            subject.onNext(MJResultSimple {
                let rawData = try self.privateContext.fetch(fetchRequest)
                if let entities = rawData as? [Model.Entity] {
                    for entity in entities {
                        self.privateContext.delete(entity)
                    }
                    if self.privateContext.hasChanges {
                        try self.privateContext.save()
                    }
                } else {
                    throw MJCoreDataError.couldNotCastToEntity
                }
            })
        }
        return subject
    }
    
}
