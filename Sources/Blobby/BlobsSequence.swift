@_exported import TupleSequences

import Varint

extension Collection<UInt8> {
    public func blobs() throws -> BlobsSequence<Self> {
        try BlobsSequence(base: self)
    }
}

public struct BlobsSequence<Base: Collection<UInt8>> {
    public enum Error: Swift.Error, CustomStringConvertible {
        case invalidDeduplicatedBlobCount
        case invalidBlobByteCount
        case unexpectedEnd
        case varintTooLarge
        
        public var description: String {
            switch self {
            case .invalidDeduplicatedBlobCount:
                return "Invalid deduplicated blob count"
            case .invalidBlobByteCount:
                return "Invalid blob byte count"
            case .unexpectedEnd:
                return "Unexpected end of base collection"
            case .varintTooLarge:
                return "Varint larger than \(Int.bitWidth) bits"
            }
        }
    }
    
    private var deduplicatedBlobs: [Base.SubSequence]
    
    private let base: Base.SubSequence
    
    fileprivate init(base: Base) throws {
        var base = base[...]
        
        guard let count = base.popFirstVarint() else {
            throw Error.unexpectedEnd
        }
        guard let count = Int(exactly: count) else {
            throw Error.varintTooLarge
        }
        
        deduplicatedBlobs = try (0..<count).compactMap { _ in
            guard let count = base.popFirstVarint() else {
                throw Error.unexpectedEnd
            }
            guard let count = Int(exactly: count) else {
                throw Error.varintTooLarge
            }
            
            guard let blob = base.popFirst(count) else {
                throw Error.invalidBlobByteCount
            }
            return blob
        }
        
        guard deduplicatedBlobs.count == count else {
            throw Error.invalidDeduplicatedBlobCount
        }
        
        self.base = base
    }
}

extension BlobsSequence: Sequence {
    public struct Iterator: IteratorProtocol {
        let deduplicatedBlobs: [Base.SubSequence]
        
        var base: Base.SubSequence
        
        public mutating func next() -> Base.SubSequence? {
            guard !base.isEmpty else {
                return nil
            }
            
            guard let distanceOrCount = base.popFirstVarint() else {
                fatalError(String(describing: Error.unexpectedEnd))
            }
            guard let distanceOrCount = Int(exactly: distanceOrCount) else {
                fatalError(String(describing: Error.varintTooLarge))
            }
            
            if distanceOrCount & 0b1 == 1 {
                guard let index = deduplicatedBlobs.startIndex(
                    offsetBy: distanceOrCount >> 1
                ) else {
                    fatalError("Invalid deduplicated blob index")
                }
                return deduplicatedBlobs[index]
            } else {
                guard let blob = base.popFirst(distanceOrCount >> 1) else {
                    fatalError(String(describing: Error.invalidBlobByteCount))
                }
                return blob
            }
        }
    }
    
    public func makeIterator() -> Iterator {
        Iterator(deduplicatedBlobs: deduplicatedBlobs, base: base)
    }
}

extension Collection {
    fileprivate func startIndex(offsetBy distance: Int) -> Index? {
        self.index(startIndex, offsetBy: distance, limitedBy: endIndex)
    }
}

extension Collection where Self == SubSequence {
    fileprivate mutating func popFirst(_ count: Int) -> SubSequence? {
        let prefix = self.prefix(count)
        guard prefix.count == count else {
            return nil
        }
        self = self.dropFirst(count)
        return prefix
    }
}
