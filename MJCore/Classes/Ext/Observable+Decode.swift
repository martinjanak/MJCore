//
//  Observable+Decode.swift
//  MJCore
//
//  Created by Martin Janák on 05/05/2018.
//

import RxSwift

extension Observable where Element == MJResult<Data> {
    
    func decode<D: Decodable>(_ decodableType: D.Type) -> Observable<MJResult<D>> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let object: D = try MJCodableUtil.decode(decodableType: decodableType, data: data)
                    return .success(value: object)
                } catch let error {
                    return .failure(error: error)
                }
            case .failure(let error):
                return .failure(error: error)
            }
        })
    }
    
    func decode<D: Decodable>(_ decodableType: [D].Type) -> Observable<MJResult<[D]>> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let object: [D] = try MJCodableUtil.decode(decodableType: decodableType, data: data)
                    return .success(value: object)
                } catch let error {
                    return .failure(error: error)
                }
            case .failure(let error):
                return .failure(error: error)
            }
        })
    }
    
    func decodeOptional<D: Decodable>(_ decodableType: D.Type) -> Observable<D?> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    return try MJCodableUtil.decode(decodableType: decodableType, data: data)
                } catch {
                    return nil
                }
            default:
                return nil
            }
        })
    }
    
    func decodeOptional<D: Decodable>(_ decodableType: [D].Type) -> Observable<[D]?> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    return try MJCodableUtil.decode(decodableType: decodableType, data: data)
                } catch {
                    return nil
                }
            default:
                return nil
            }
        })
    }
    
    func decode<D: Decodable>(_ decodableType: D.Type, defaultValue: D) -> Observable<D> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    return try MJCodableUtil.decode(decodableType: decodableType, data: data)
                } catch {
                    return defaultValue
                }
            default:
                return defaultValue
            }
        })
    }
    
    func decode<D: Decodable>(_ decodableType: [D].Type, defaultValue: [D]) -> Observable<[D]> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    return try MJCodableUtil.decode(decodableType: decodableType, data: data)
                } catch {
                    return defaultValue
                }
            default:
                return defaultValue
            }
        })
    }

    
}
