//
//  MJCoreDataModel.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import CoreData

public protocol MJCoreDataModel {
    associatedtype Entity: NSManagedObject
    
    init(entity: Entity)
    func createEntity(context: NSManagedObjectContext) -> Entity
    
    var id: NSManagedObjectID? { get }
}
