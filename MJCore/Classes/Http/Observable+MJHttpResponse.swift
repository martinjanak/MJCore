//
//  Observable+MJHttpResponse.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import RxSwift

public enum MJDecodedResponse<D: Decodable> {
    case success(object: D)
    case errorCouldNotDecode(error: Error)
    case error(response: MJHttpResponse)
    
    func isSuccess() -> Bool {
        switch self {
        case .success: return true
        default: return false
        }
    }
}

extension Observable where Element == MJHttpResponse {
    
    func `catch`(_ handler: @escaping (MJHttpResponse) -> Void) -> Observable<MJHttpResponse> {
        return self.map({ response in
            switch response {
            case .success:
                break
            default:
                handler(response)
            }
            return response
        })
    }
    
    func decode<D: Decodable>(_ decodableType: D.Type) -> Observable<MJDecodedResponse<D>> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let object: D = try MJCodableUtil.decode(decodableType: decodableType, data: data)
                    return .success(object: object)
                } catch let error {
                    return .errorCouldNotDecode(error: error)
                }
            default:
                return .error(response: response)
            }
        })
    }
    
    func decode<D: Decodable>(_ decodableType: [D].Type) -> Observable<MJDecodedResponse<[D]>> {
        return self.map({ response in
            switch response {
            case .success(let data):
                do {
                    let object: [D] = try MJCodableUtil.decode(decodableType: decodableType, data: data)
                    return .success(object: object)
                } catch let error {
                    return .errorCouldNotDecode(error: error)
                }
            default:
                return .error(response: response)
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
