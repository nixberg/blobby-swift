import Collections

extension Collection where Element: Collection<UInt8> & Hashable {
    public func blobbyEncoded() -> [UInt8] {
        let duplicateBlobs = self.reduce(into: [:] as OrderedDictionary) {
            $0[$1, default: 0] += 1
        }.filter {
            !$0.key.isEmpty && $0.value > 1
        }.keys
        
        var result: [UInt8] = []
        
        result.append(contentsOf: duplicateBlobs.count.gfvlqEncoded())
        
        for blob in duplicateBlobs {
            result.append(contentsOf: blob.count.gfvlqEncoded())
            result.append(contentsOf: blob)
        }
        
        for blob in self {
            if let index = duplicateBlobs.firstIndex(of: blob) {
                guard let index = index.shiftedLeft else {
                    fatalError("TODO")
                }
                result.append(contentsOf: (index | 0b1).gfvlqEncoded())
            } else {
                guard let count = blob.count.shiftedLeft else {
                    fatalError("TODO")
                }
                result.append(contentsOf: count.gfvlqEncoded())
                result.append(contentsOf: blob)
            }
        }
        
        return result
    }
}

fileprivate extension Int {
    var shiftedLeft: Self? {
        let shiftedValue = self << 1
        guard shiftedValue >> 1 == self else {
            return nil
        }
        return shiftedValue
    }
}
