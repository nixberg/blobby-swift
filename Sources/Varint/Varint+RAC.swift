extension Varint: RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Array<UInt8>.Index
    
    public var startIndex: Index {
        bytes.startIndex
    }
    
    public var endIndex: Index {
        bytes.endIndex
    }
    
    public subscript(position: Index) -> Element {
        bytes[position]
    }
    
    public var first: Element {
        bytes[startIndex]
    }
    
    public var last: Element {
        bytes[bytes.index(before: bytes.endIndex)]
    }
    
    public func withContiguousStorageIfAvailable<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R? {
        try self.withUnsafeBufferPointer(body)
    }
}

extension Varint {
    public func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        try bytes.withUnsafeBufferPointer(body)
    }
    
    public func withUnsafeBytes<R>(
        _ body: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        try bytes.withUnsafeBytes(body)
    }
}
