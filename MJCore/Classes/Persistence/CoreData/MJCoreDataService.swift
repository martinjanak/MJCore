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
    case noKeyProvided
}

public final class MJCoreDataService {
    
    private let modelName: String
    internal let getKey: (() -> String?)?
    
    public init(modelName: String, getKey: (() -> String?)? = nil) {
        self.modelName = modelName
        self.getKey  = getKey
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
    
}
