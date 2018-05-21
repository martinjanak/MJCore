//
//  Observable+Decode.swift
//  MJCore
//
//  Created by Martin Janák on 05/05/2018.
//

import RxSwift

extension Observable where Element == MJResult<Data> {
    
    public func decode<D: Decodable>(_ decodableType: D.Type) -> Observable<MJResult<D>> {
        return self.successMap({ data in
            return MJResult {
                return try MJCodableUtil.decode(decodableType: decodableType, data: data)
            }
        })
    }
    
    public func decode<D: Decodable>(_ decodableType: [D].Type) -> Observable<MJResult<[D]>> {
        return self.successMap({ data in
            return MJResult {
                return try MJCodableUtil.decode(decodableType: decodableType, data: data)
            }
        })
    }
    
    public func decodeOptional<D: Decodable>(_ decodableType: D.Type) -> Observable<D?> {
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
    
    public func decodeOptional<D: Decodable>(_ decodableType: [D].Type) -> Observable<[D]?> {
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
    
    public func decode<D: Decodable>(_ decodableType: D.Type, defaultValue: D) -> Observable<D> {
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
    
    public func decode<D: Decodable>(_ decodableType: [D].Type, defaultValue: [D]) -> Observable<[D]> {
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
