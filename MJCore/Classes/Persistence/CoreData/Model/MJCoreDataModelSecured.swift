//
//  MJCoreDataModelSecured.swift
//  MJCore
//
//  Created by Martin Janák on 11/06/2018.
//

import CoreData

public protocol MJCoreDataModelSecured {
    associatedtype Entity: NSManagedObject
    
    init(entity: Entity, key: String) throws
    func createEntity(context: NSManagedObjectContext, key: String) throws -> Entity
    
    var id: NSManagedObjectID? { get }
}
