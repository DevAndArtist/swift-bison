//
//  Element.swift
//  Bison
//

import Foundation

public struct Element {
    
    public let name: CString
    public let value: Value
    
    public init(name: CString, value: Value) {
        
        self.name = name
        self.value = value
    }
    
    public init(name: String, value: Value) {
        
        self.name = CString(string: name)
        self.value = value
    }
}

extension Element : _ByteConvertible {
    
    var _bytes: [Byte] {

        var bytes = [Byte]()
        bytes.append(self.value._kind)
        bytes.append(contentsOf: self.name._bytes)
        
        switch self.value {
            
        case .null, .minKey, .maxKey:
            break
            
        default:
            bytes.append(contentsOf: self.value._bytes)
        }
        
        return bytes
    }
}

// Element.Value
extension Element {
    
    public enum Value {
        
        case double(Double)
        case string(String)
        case document(Document)
        case documentArray(Document)
        case binary(BinarySubtype, data: [Byte])
        case objectID(ObjectID)
        case bool(Bool)
        case utcDate(UTCDate)
        case null
        case regex(CString, CString)
        case javaScript(String)
        case scopedJavaScript(String, Document)
        case int32(Int32)
        case timestamp(Timestamp)
        case int64(Int64)
        case decimal128(Decimal128)
        case minKey
        case maxKey
    }
}

extension Element.Value {
    
    var _kind: Byte {
        
        switch self {
            
        case .double:           return 0x01
        case .string:           return 0x02
        case .document:         return 0x03
        case .documentArray:    return 0x04
        case .binary:           return 0x05
        case .objectID:         return 0x07
        case .bool:             return 0x08
        case .utcDate:          return 0x09
        case .null:             return 0x0A
        case .regex:            return 0x0B
        case .javaScript:       return 0x0D
        case .scopedJavaScript: return 0x0F
        case .int32:            return 0x10
        case .timestamp:        return 0x11
        case .int64:            return 0x12
        case .decimal128:       return 0x13
        case .minKey:           return 0xFF
        case .maxKey:           return 0x7F
        }
    }
}

extension Element.Value : _ByteConvertible {
    
    var _bytes: [Byte] {
        
        var bytes = [Byte]()
        
        switch self {
            
        case .double(let value):
            bytes.append(contentsOf: value._bytes)

        case .string(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .document(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .documentArray(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .binary(let subtype, data: let data):
            bytes.append(contentsOf: Int32(data.count)._bytes)
            bytes.append(subtype.rawValue)
            bytes.append(contentsOf: data)
            
//        case .objectID(_):
            
        case .bool(let value):
            bytes.append(value._byte)
            
        case .utcDate(let value):
            bytes.append(contentsOf: value._bytes)

        case .regex(let pattern, let options):
            bytes.append(contentsOf: pattern._bytes)
            bytes.append(contentsOf: options._bytes)
            
        case .javaScript(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .scopedJavaScript(let string, let document):
            var tempBytes = [Byte]()
            tempBytes.append(contentsOf: string._bytes)
            tempBytes.append(contentsOf: document._bytes)
            bytes.append(contentsOf: Int32(tempBytes.count)._bytes)
            bytes.append(contentsOf: tempBytes)
            
        case .int32(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .timestamp(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .int64(let value):
            bytes.append(contentsOf: value._bytes)
            
        case .decimal128(let value):
            bytes.append(contentsOf: _convertToBytes(value))

        default:
            break
        }
        
        return bytes
    }
}

extension Element.Value : ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: Double) {
        
        self = .double(value)
    }
}

extension Element.Value : ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        
        self = .null
    }
}

extension Element.Value : ExpressibleByStringLiteral {
    
    public init(string: String) {
        
        self = .string(string)
    }
    
    public init(stringLiteral value: String) {
        
        self.init(string: value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        
        self.init(string: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        
        self.init(string: value)
    }
}

extension Element.Value : ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: Bool) {
        
        self = .bool(value)
    }
}

extension Element.Value : ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int64) {
        
        self = .int64(value)
    }
}
