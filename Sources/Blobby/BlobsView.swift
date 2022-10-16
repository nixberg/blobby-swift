public struct Blobs<Bytes: Collection<UInt8>>: Sequence {
    private let remainingBytes: Bytes.SubSequence
    
    private var deduplicatedBlobs: [Bytes.SubSequence]
    
    public init?(_ bytes: Bytes) {
        var remainingBytes = bytes[...]
        
        guard let deduplicatedBlobCount = remainingBytes.popGFVLQInt() else {
            return nil
        }
        
        deduplicatedBlobs = (0..<deduplicatedBlobCount).compactMap { _ in
            guard let blobByteCount = remainingBytes.popGFVLQInt() else {
                return nil
            }
            return remainingBytes.popFirst(blobByteCount)
        }
        guard deduplicatedBlobs.count == deduplicatedBlobCount else {
            return nil
        }
        
        self.remainingBytes = remainingBytes
    }
    
    public func makeIterator() -> BlobsIterator<Bytes> {
        .init(remainingBytes: remainingBytes, deduplicatedBlobs: deduplicatedBlobs)
    }
}

public struct BlobsIterator<Bytes: Collection<UInt8>>: IteratorProtocol {
    public typealias Element = Bytes.SubSequence
    
    private var remainingBytes: Bytes.SubSequence
    
    private let deduplicatedBlobs: [Element]
    
    init(remainingBytes: Bytes.SubSequence, deduplicatedBlobs: [Element]) {
        self.remainingBytes = remainingBytes
        self.deduplicatedBlobs = deduplicatedBlobs
    }
    
    public mutating func next() -> Element? {
        guard !remainingBytes.isEmpty else {
            return nil
        }
        guard let value = remainingBytes.popGFVLQInt() else {
            fatalError("TODO")
        }
        if value & 0b1 == 1 {
            return deduplicatedBlobs[value >> 1]
        } else {
            return remainingBytes.popFirst(value >> 1)
        }
    }
}

fileprivate extension Collection<UInt8> where SubSequence == Self {
    mutating func popGFVLQInt() -> Int? {
        var count: Int? = nil
        guard let value = Int(gfvlq: self, readBytesCount: &count),
              let count else {
            return nil
        }
        self = self.dropFirst(count)
        return value
    }
    
    mutating func popFirst(_ count: Int) -> SubSequence {
        defer { self = self.dropFirst(count) }
        return self.prefix(count)
    }
}
