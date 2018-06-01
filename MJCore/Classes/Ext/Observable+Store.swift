//
//  Observable+MJCoreData.swift
//  MJCore
//
//  Created by Martin Janák on 20/05/2018.
//

import RxSwift

extension Observable {

    public func store<Model: MJCoreDataModel>(
        _ coreDataService: MJCoreDataService
    ) -> Observable<MJResult<Model>> where Element == MJResult<Model> {
        return self.successFlatMap({ [weak coreDataServiceWeak = coreDataService] model in
            guard let coreDataServiceStrong = coreDataServiceWeak else {
                return .none()
            }
            return coreDataServiceStrong.create(model)
        })
    }
    
    public func storeArray<Model: MJCoreDataModel>(
        _ coreDataService: MJCoreDataService,
        replace: Bool = false
    ) -> Observable<MJResult<[Model]>> where Element == MJResult<[Model]> {
        return self.successFlatMap({ [weak coreDataServiceWeak = coreDataService] modelArray in
            guard let coreDataServiceStrong = coreDataServiceWeak else {
                return .none()
            }
            if replace {
                return coreDataServiceStrong
                    .delete(Model.self)
                    .successFlatMap({
                        return coreDataServiceStrong.create(modelArray)
                    })
            } else {
                return coreDataServiceStrong.create(modelArray)
            }
        })
    }
    
}
