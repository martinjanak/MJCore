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
    var coreData: CoreDataService { get }
}

public final class CoreDataService {
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    public func saveChanges() -> Observable<MJResultSimple> {
        return saveContext(privateContext)
    }
    
    private func saveContext(_ context: NSManagedObjectContext) -> Observable<MJResultSimple> {
        let subject = PublishSubject<MJResultSimple>()
        context.perform {
            do {
                if context.hasChanges {
                    try context.save()
                }
                subject.onNext(.success)
            } catch let error {
                subject.onNext(.failure(error: error))
            }
        }
        return subject
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
    
    // MARK: CRUD
    
    // MARK: Create
    
    public func create<Model: MJCoreDataModel>(_ model: Model) -> Observable<MJResultSimple> {
        let subject = PublishSubject<MJResultSimple>()
        privateContext.perform {
            let _ = model.createEntity(context: self.privateContext)
            do {
                if self.privateContext.hasChanges {
                    try self.privateContext.save()
                }
                subject.onNext(.success)
            } catch let error {
                subject.onNext(.failure(error: error))
            }
        }
        return subject
    }
    
    public func create<Model: MJCoreDataModel>(_ models: [Model]) -> Observable<MJResultSimple> {
        let subject = PublishSubject<MJResultSimple>()
        privateContext.perform {
            for model in models {
                let _ = model.createEntity(context: self.privateContext)
            }
            do {
                if self.privateContext.hasChanges {
                    try self.privateContext.save()
                }
                subject.onNext(.success)
            } catch let error {
                subject.onNext(.failure(error: error))
            }
        }
        return subject
    }
    
    // MARK: Read
    
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
            do {
                let rawData = try self.privateContext.fetch(fetchRequest)
                if let entities = rawData as? [Model.Entity] {
                    let data = entities.map({ Model(entity: $0) })
                    subject.onNext(.success(value: data))
                } else {
                    subject.onNext(
                        .failure(error: MJCoreDataError.couldNotCastToEntity)
                    )
                }
            } catch let error {
                subject.onNext(.failure(error: error))
            }
        }
        return subject
    }
    
    // MARK: Update
    
    public func update<Model: MJCoreDataModel>(_ model: Model) -> Observable<MJResultSimple> {
        let subject = PublishSubject<MJResultSimple>()
        privateContext.perform {
            let existingEntity = self.privateContext.object(with: model.id)
            if !existingEntity.isFault {
                self.privateContext.delete(existingEntity)
                let _ = model.createEntity(context: self.privateContext)
                do {
                    if self.privateContext.hasChanges {
                        try self.privateContext.save()
                    }
                    subject.onNext(.success)
                } catch let error {
                    subject.onNext(.failure(error: error))
                }
            } else {
                subject.onNext(
                    .failure(error: MJCoreDataError.entityDoesNotExist)
                )
            }
        }
        return subject
    }
    
    // MARK: Delete
    
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
            do {
                let rawData = try self.privateContext.fetch(fetchRequest)
                if let entities = rawData as? [Model.Entity] {
                    for entity in entities {
                        self.privateContext.delete(entity)
                    }
                    if self.privateContext.hasChanges {
                        try self.privateContext.save()
                    }
                    subject.onNext(.success)
                } else {
                    subject.onNext(
                        .failure(error: MJCoreDataError.couldNotCastToEntity)
                    )
                }
            } catch let error {
                subject.onNext(.failure(error: error))
            }
        }
        return subject
    }
    
    // MARK: Error
    
    public enum MJCoreDataError: Error {
        case couldNotCastToEntity
        case entityDoesNotExist
    }
    
}
