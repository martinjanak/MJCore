//
//  Observable+MJCoreData.swift
//  MJCore
//
//  Created by Martin Janák on 20/05/2018.
//

import RxSwift

extension Observable {

    public func store<M: MJCoreDataModel>(
        _ coreDataService: MJCoreDataService
    ) -> Observable<MJResultSimple> where Element == MJResult<M> {
        return self.successFlatMapSimple({ [weak coreDataServiceWeak = coreDataService] model in
            guard let coreDataServiceStrong = coreDataServiceWeak else {
                return Observable<MJResultSimple>.just(
                    .failure(error: MJCoreDataError.serviceUnavailable)
                )
            }
            return coreDataServiceStrong.create(model)
        })
    }
    
    public func storeArray<M: MJCoreDataModel>(
        _ coreDataService: MJCoreDataService
    ) -> Observable<MJResultSimple> where Element == MJResult<[M]> {
        return self.successFlatMapSimple({ [weak coreDataServiceWeak = coreDataService] modelArray in
            guard let coreDataServiceStrong = coreDataServiceWeak else {
                return Observable<MJResultSimple>.just(
                    .failure(error: MJCoreDataError.serviceUnavailable)
                )
            }
            return coreDataServiceStrong.create(modelArray)
        })
    }
    
}
