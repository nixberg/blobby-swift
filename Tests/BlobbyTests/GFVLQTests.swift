@testable import Blobby
import XCTest

final class VLQTests: XCTestCase {
    func testDecodingValid() {
        let vectors: [(bytes: [UInt8], expected: (value: Int, readBytesCount: Int))] = [
            ([0b0000_0000], (  0, 1)),
            ([0b0000_0010], (  2, 1)),
            ([0b0111_1111], (127, 1)),
            
            ([0b1000_0000, 0b0000_0000], (  128, 2)),
            ([0b1111_1111, 0b0111_1111], (16511, 2)),
            
            ([0b1000_0000, 0b1000_0000, 0b0000_0000], (  16512, 3)),
            ([0b1111_1111, 0b1111_1111, 0b0111_1111], (2113663, 3)),
            
            ([0b1000_0000, 0b1000_0000, 0b1000_0000, 0b0000_0000], (  2113664, 4)),
            ([0b1111_1111, 0b1111_1111, 0b1111_1111, 0b0111_1111], (270549119, 4)),
            
            ([0b1111_1111, 0b1111_1111, 0b1111_1111, 0b1111_1111, 0b0111_1111], (34630287487, 5)),
        ]
        
        for vector in vectors {
            var count: Int? = 0
            
            XCTAssertEqual(
                Int(gfvlq: vector.bytes, readBytesCount: &count),
                vector.expected.value
            )
            XCTAssertEqual(count, vector.expected.readBytesCount)
            
            XCTAssertEqual(
                UInt(gfvlq: vector.bytes, readBytesCount: &count),
                UInt(vector.expected.value)
            )
            XCTAssertEqual(count, vector.expected.readBytesCount)
        }
    }
    
    func testDecodingInvalid() {
        let vectors: [[UInt8]] = [
            [],
            [0b1000_0010],
            [0b1111_1111],
            
            [0b1111_1111, 0b1000_0000],
            [0b1111_1111, 0b1111_1111],
        ]
        
        for vector in vectors {
            var count: Int? = 0
            
            XCTAssertNil(Int(gfvlq: vector, readBytesCount: &count))
            XCTAssertEqual(count, nil)
            
            XCTAssertNil(UInt(gfvlq: vector, readBytesCount: &count))
            XCTAssertEqual(count, nil)
        }
        
        var count: Int? = 0
        XCTAssertNil( Int8(gfvlq: [0xff, 0x00], readBytesCount: &count))
        XCTAssertNil(UInt8(gfvlq: [0xff, 0x00], readBytesCount: &count))
    }
    
    func testRandomEncodingRoundtrips() {
        for _ in 0 ..< 1024 {
            let value = Int.random(in: 0 ... .max)
            
            let encoded = value.gfvlqEncoded()
            
            var count: Int? = 0
            let decoded = Int(gfvlq: encoded, readBytesCount: &count)
            
            XCTAssertEqual(decoded, value)
            XCTAssertEqual(encoded.count, count)
        }
    }
}
