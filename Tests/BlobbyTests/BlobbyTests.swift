import Blobby
import XCTest

final class BlobTests: XCTestCase {
    private var expectedBlobs = {
        [
            "hello",
            " ",
            "",
            "world!",
            ":::",
            "world!",
            "hello",
            "",
        ].map(\.utf8).map(Array.init)
    }()
    
    private var expectedBytes: [UInt8] = [
        0x02,
        
        0x05, 0x68, 0x65, 0x6c, 0x6c, 0x6f,       // "hello"
        0x06, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21, // "world!"
        
        0x01,                                     // &"hello"
        0x02, 0x20,                               // " "
        0x00,                                     // ""
        0x03,                                     // &"world!"
        0x06, 0x3a, 0x3a, 0x3a,                   // ":::"
        0x03,                                     // &"hello"
        0x01,                                     // &"world!"
        0x00,                                     // ""
    ]
    
    func testDecoding() throws {
        let blobs = try XCTUnwrap(Blobs(expectedBytes))
        
        for (blob, expectedBlob) in zip(blobs, expectedBlobs) {
            XCTAssert(blob.elementsEqual(expectedBlob))
        }
    }
    
    func testEncodingExact() throws {
        XCTAssert(expectedBlobs.blobbyEncoded().elementsEqual(expectedBytes))
    }
    
    func testEncodingRoundtrip() throws {
        let blobs = try XCTUnwrap(Blobs(expectedBlobs.blobbyEncoded()))
        
        for (blob, expectedBlob) in zip(blobs, expectedBlobs) {
            XCTAssert(blob.elementsEqual(expectedBlob))
        }
    }
}

fileprivate extension Sequence {
    var first: Element? {
        self.first(where: { _ in true })
    }
}
