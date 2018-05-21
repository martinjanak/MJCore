//
//  Observable+Parse.swift
//  MJCore
//
//  Created by Martin Janák on 21/05/2018.
//

import RxSwift

extension Observable where Element == MJResult<Data> {
    
    public func parse<Model: MJsonParsable>(
        _ modelType: Model.Type,
        key: String? = nil
    ) -> Observable<MJResult<Model>> {
        return self.successMap({ data in
            return MJResult(MJson.parseSync(data, key: key))
        })
    }
    
    public func parse<Model: MJsonParsable>(
        _ modelType: [Model].Type,
        key: String? = nil
    ) -> Observable<MJResult<[Model]>> {
        return self.successMap({ data in
            return MJResult(MJson.parseArraySync(data, key: key))
        })
    }
    
    public func parseOptional<Model: MJsonParsable>(
        _ modelType: Model.Type,
        key: String? = nil
    ) -> Observable<Model?> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    return try MJson.parseSync(data, key: key)()
                } catch {
                    return nil
                }
            default:
                return nil
            }
        })
    }
    
    public func parseOptional<Model: MJsonParsable>(
        _ modelType: [Model].Type,
        key: String? = nil
    ) -> Observable<[Model]?> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    return try MJson.parseArraySync(data, key: key)()
                } catch {
                    return nil
                }
            default:
                return nil
            }
        })
    }
    
    public func parse<Model: MJsonParsable>(
        _ modelType: Model.Type,
        defaultValue: Model,
        key: String? = nil
    ) -> Observable<Model> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    return try MJson.parseSync(data, key: key)()
                } catch {
                    return defaultValue
                }
            default:
                return defaultValue
            }
        })
    }
    
    public func parse<Model: MJsonParsable>(
        _ modelType: [Model].Type,
        defaultValue: [Model],
        key: String? = nil
    ) -> Observable<[Model]> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    return try MJson.parseArraySync(data, key: key)()
                } catch {
                    return defaultValue
                }
            default:
                return defaultValue
            }
        })
    }
    
}
