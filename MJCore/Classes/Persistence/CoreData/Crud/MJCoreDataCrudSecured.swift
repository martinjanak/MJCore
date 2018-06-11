//
//  MJCoreDataCrudSecured.swift
//  MJCore
//
//  Created by Martin Janák on 11/06/2018.
//

import Foundation
import CoreData
import RxSwift

extension MJCoreDataService {
    
    // MARK: Create
    
    public func createSync<Model: MJCoreDataModelSecured>(_ model: Model) throws -> Model {
        guard let getKey = getKey, let key = getKey() else {
            throw MJCoreDataError.noKeyProvided
        }
        _ = try model.createEntity(context: self.privateContext, key: key)
        return model
    }
    
    public func createSync<Model: MJCoreDataModelSecured>(_ models: [Model]) throws -> [Model] {
        guard let getKey = getKey, let key = getKey() else {
            throw MJCoreDataError.noKeyProvided
        }
        for model in models {
            _ = try model.createEntity(context: self.privateContext, key: key)
        }
        return models
    }
    
    public func create<Model: MJCoreDataModelSecured>(_ model: Model) -> Observable<MJResult<Model>> {
        return transaction { strongSelf in
            _ = try strongSelf.createSync(model)
            try strongSelf.saveChangesSync()
            return model
        }
    }
    
    public func create<Model: MJCoreDataModelSecured>(_ models: [Model]) -> Observable<MJResult<[Model]>> {
        return transaction { strongSelf in
            _ = try strongSelf.createSync(models)
            try strongSelf.saveChangesSync()
            return models
        }
    }
    
    // MARK: Update
    
    public func updateSync<Model: MJCoreDataModelSecured>(_ model: Model) throws -> Model {
        guard let getKey = getKey, let key = getKey() else {
            throw MJCoreDataError.noKeyProvided
        }
        guard let id = model.id else {
            throw MJCoreDataError.modelHasNoId
        }
        let existingEntity = self.privateContext.object(with: id)
        if !existingEntity.isFault {
            self.privateContext.delete(existingEntity)
            _ = try model.createEntity(context: self.privateContext, key: key)
            return model
        } else {
            throw MJCoreDataError.entityDoesNotExist
        }
    }
    
    public func updateSync<Model: MJCoreDataModelSecured>(_ models: [Model]) throws -> [Model] {
        guard let getKey = getKey, let key = getKey() else {
            throw MJCoreDataError.noKeyProvided
        }
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
                _ = try model.createEntity(context: self.privateContext, key: key)
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
    
    public func update<Model: MJCoreDataModelSecured>(_ model: Model) -> Observable<MJResult<Model>> {
        return transaction { strongSelf in
            _ = try strongSelf.updateSync(model)
            try strongSelf.saveChangesSync()
            return model
        }
    }
    
    public func update<Model: MJCoreDataModelSecured>(_ models: [Model]) -> Observable<MJResult<[Model]>> {
        return transaction { strongSelf in
            _ = try strongSelf.updateSync(models)
            try strongSelf.saveChangesSync()
            return models
        }
    }
    
    // MARK: Read
    
    public func readSync<Model: MJCoreDataModelSecured>(
        _ modelType: Model.Type,
        filter: MJCoreDataFilter? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil
    ) throws -> [Model] {
        guard let getKey = getKey, let key = getKey() else {
            throw MJCoreDataError.noKeyProvided
        }
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
            let data = try entities.map({ try Model(entity: $0, key: key) })
            return data
        } else {
            throw MJCoreDataError.couldNotCastToEntity
        }
    }
    
    public func readOneSync<Model: MJCoreDataModelSecured>(
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
    
    public func read<Model: MJCoreDataModelSecured>(
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
    
    public func readOne<Model: MJCoreDataModelSecured>(
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
    
    public func deleteSync<Model: MJCoreDataModelSecured>(
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
    
    public func delete<Model: MJCoreDataModelSecured>(
        _ modelType: Model.Type,
        filter: MJCoreDataFilter? = nil
    ) -> Observable<MJResultSimple> {
        return transactionSimple { strongSelf in
            try strongSelf.deleteSync(modelType, filter: filter)
            try strongSelf.saveChangesSync()
        }
    }
    
}
