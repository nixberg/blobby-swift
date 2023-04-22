import Varint
import XCTest

final class VarintTests: XCTestCase {
    func testDecodingValid() throws {
        let vectors: [(bytes: [UInt8], expected: Int)] = [
            ([0b0000_0000],   0),
            ([0b0000_0010],   2),
            ([0b0111_1111], 127),
            
            ([0b1000_0000, 0b0000_0000],   128),
            ([0b1111_1111, 0b0111_1111], 16511),
            
            ([0b1000_0000, 0b1000_0000, 0b0000_0000],   16512),
            ([0b1111_1111, 0b1111_1111, 0b0111_1111], 2113663),
            
            ([0b1000_0000, 0b1000_0000, 0b1000_0000, 0b0000_0000],   2113664),
            ([0b1111_1111, 0b1111_1111, 0b1111_1111, 0b0111_1111], 270549119),
            
            ([0b1111_1111, 0b1111_1111, 0b1111_1111, 0b1111_1111, 0b0111_1111], 34630287487),
        ]
        
        for vector in vectors {
            let varint = try XCTUnwrap(Varint(vector.bytes))
            XCTAssertEqual(varint.count, vector.bytes.count)
            XCTAssertEqual( Int(exactly: varint),  Int(vector.expected))
            XCTAssertEqual(UInt(exactly: varint), UInt(vector.expected))
        }
        
        for vector in vectors {
            let varint = try XCTUnwrap(vector.bytes.firstVarint())
            XCTAssertEqual(varint.count, vector.bytes.count)
            XCTAssertEqual(Int(exactly: varint), vector.expected)
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
            XCTAssertNil(vector.firstVarint())
        }
        
        XCTAssertNil( Int8(exactly: Varint([0xff, 0x00])))
        XCTAssertNil(UInt8(exactly: Varint([0xff, 0x00])))
    }
    
    func testRandomEncodingRoundtrips() {
        for _ in 0 ..< 1024 {
            let value = Int.random(in: 0 ... .max)
            XCTAssertEqual(Int(exactly: Varint(value)), value)
        }
    }
}
