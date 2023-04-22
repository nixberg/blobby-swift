public struct Varint {
    let bytes: [UInt8]
    
    public init(_ source: some (BinaryInteger & UnsignedInteger)) {
        var value = source
        var bytes: [UInt8] = []
        
        bytes.append(UInt8(truncatingIfNeeded: value) & 0b0111_1111)
        value >>= 7
        
        while value > 0 {
            value -= 1
            bytes.append(0b1000_0000 | UInt8(truncatingIfNeeded: value))
            value >>= 7
        }
        
        bytes.reverse()
        self.bytes = bytes
    }
    
    public init(_ source: some (FixedWidthInteger & SignedInteger)) {
        precondition(source >= .zero)
        self.init(source.magnitude)
    }
    
    public init(_ source: some Collection<UInt8>) {
        bytes = Array(source)
        guard bytes.dropLast().allSatisfy({ $0 >> 7 == 0b1 }),
              let lastByte = bytes.last,
              lastByte >> 7 == 0b0 else {
            preconditionFailure("Unexpected end of collection")
        }
    }
    
    init?(prefixOf source: some Sequence<UInt8>) {
        var iterator = source.makeIterator()
        var bytes: [UInt8] = []
        
        while let byte = iterator.next() {
            bytes.append(byte)
            if byte >> 7 == 0b0 {
                self.bytes = bytes
                return
            }
        }
        
        return nil
    }
}

extension Sequence<UInt8> {
    public func firstVarint() -> Varint? {
        Varint(prefixOf: self)
    }
}

extension Collection<UInt8> where SubSequence == Self {
    public mutating func popFirstVarint() -> Varint? {
        guard let varint = self.firstVarint() else {
            return nil
        }
        self = self.dropFirst(varint.count)
        return varint
    }
}

extension RangeReplaceableCollection<UInt8> {
    public mutating func popFirstVarint() -> Varint? {
        guard let varint = self.firstVarint() else {
            return nil
        }
        self.removeFirst(varint.count)
        return varint
    }
}

extension FixedWidthInteger {
    public init?(exactly source: Varint) {
        guard 7 * source.count <= Self.unsignedBitWidth else {
            return nil
        }
        self = source.dropFirst().reduce(Self(truncatingIfNeeded: source.first & 0b0111_1111)) {
            (($0 + 1) << 7) | Self(truncatingIfNeeded: $1 & 0b0111_1111)
        }
    }
    
    private static var unsignedBitWidth: Int {
        bitWidth - (isSigned ? 1 : 0)
    }
}
