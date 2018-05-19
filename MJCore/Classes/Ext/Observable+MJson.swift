//
//  Observable+MJson.swift
//  MJCore
//
//  Created by Martin Janák on 19/05/2018.
//

import RxSwift

extension Observable where Element == MJResult<Data> {
    
    public func parse<Model: MJsonParsable>(_ modelType: Model.Type) -> Observable<MJResult<Model>> {
        return self.map({ response in
            switch response {
            case .success(let data):
                return MJResult { () -> Model in
                    let json = try MJsonUtil.parse(data)
                    return try Model(json: json)
                }
            case .failure(let error):
                return .failure(error: error)
            }
        })
    }
    
    public func parse<Model: MJsonParsable>(_ decodableType: [Model].Type) -> Observable<MJResult<[Model]>> {
        return self.map({ response in
            switch response {
            case .success(let data):
                return MJResult { () -> [Model] in
                    let jsonArray = try MJsonUtil.parseArray(data)
                    var modelArray = [Model]()
                    for json in jsonArray {
                        modelArray.append(try Model(json: json))
                    }
                    return modelArray
                }
            case .failure(let error):
                return .failure(error: error)
            }
        })
    }
    
    public func parseOptional<Model: MJsonParsable>(_ decodableType: Model.Type) -> Observable<Model?> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let json = try MJsonUtil.parse(data)
                    return try Model(json: json)
                } catch {
                    return nil
                }
            default:
                return nil
            }
        })
    }
    
    public func parseOptional<Model: MJsonParsable>(_ decodableType: [Model].Type) -> Observable<[Model]?> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let jsonArray = try MJsonUtil.parseArray(data)
                    var modelArray = [Model]()
                    for json in jsonArray {
                        modelArray.append(try Model(json: json))
                    }
                    return modelArray
                } catch {
                    return nil
                }
            default:
                return nil
            }
        })
    }
    
    public func parse<Model: MJsonParsable>(_ decodableType: Model.Type, defaultValue: Model) -> Observable<Model> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let json = try MJsonUtil.parse(data)
                    return try Model(json: json)
                } catch {
                    return defaultValue
                }
            default:
                return defaultValue
            }
        })
    }
    
    public func decode<Model: MJsonParsable>(_ decodableType: [Model].Type, defaultValue: [Model]) -> Observable<[Model]> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let jsonArray = try MJsonUtil.parseArray(data)
                    var modelArray = [Model]()
                    for json in jsonArray {
                        modelArray.append(try Model(json: json))
                    }
                    return modelArray
                } catch {
                    return defaultValue
                }
            default:
                return defaultValue
            }
        })
    }
    
}
