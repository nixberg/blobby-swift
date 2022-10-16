extension FixedWidthInteger {
    init?(
        gfvlq bytes: some Sequence<UInt8>,
        readBytesCount: inout Int?
    ) {
        var bytes = bytes.makeIterator()
        
        self = 0 &- 1
        readBytesCount = nil
        
        for byteCount in 1... {
            guard let byte = bytes.next() else {
                return nil
            }
            guard 7 * byteCount <= Self.bitWidth - (Self.isSigned ? 1 : 0) else {
                return nil
            }
            
            self &+= 1
            self <<= 7
            self |= Self(truncatingIfNeeded: byte & 0b0111_1111)
            
            guard byte & 0b1000_0000 != 0 else {
                readBytesCount = byteCount
                return
            }
        }
    }
    
    func gfvlqEncoded() -> ReversedCollection<[UInt8]> {
        precondition(self >= 0)
        
        var value = self.magnitude
        var result: [UInt8] = []
        
        result.append(UInt8(truncatingIfNeeded: value) & 0b0111_1111)
        value >>= 7
        
        while value > 0 {
            value -= 1
            result.append(UInt8(truncatingIfNeeded: value) | 0b1000_0000)
            value >>= 7
        }
        
        return result.reversed()
    }
}
