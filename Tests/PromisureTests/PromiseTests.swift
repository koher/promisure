import XCTest
@testable import Promisure

class PromiseTests: XCTestCase {
    func testPromise() {
        do {
            let a: Promise<Int> = promise { resolve in
                resolve({ $0(42) })
            }
            
            var value: Int? = nil
            a { value = $0 }
            XCTAssertEqual(value, 42)
        }
        
        do {
            let expectation = self.expectation(description: "")
            
            let a: Promise<Int> = promise { resolve in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    resolve({ $0(42) })
                }
            }
            
            var value: Int? = nil
            a { value = $0; expectation.fulfill() }
            
            waitForExpectations(timeout: 5.0, handler: nil)
            
            XCTAssertEqual(value, 42)
        }
    }
    
    func testFlatMapLeft() {
        do {
            let expectation = self.expectation(description: "")
            
            let a: Promise<Int> = async(3)
            let r: Promise<Int> = a >>- { a in async(a * a) }
            
            var value: Int? = nil
            r { value = $0; expectation.fulfill() }
            
            waitForExpectations(timeout: 5.0, handler: nil)
            
            XCTAssertEqual(value, 9)
        }
    }
    
    func testFlatMapRight() {
        do {
            let expectation = self.expectation(description: "")
            
            let a: Promise<Int> = async(3)
            let r: Promise<Int> = { a in async(a * a) } -<< a
            
            var value: Int? = nil
            r { value = $0; expectation.fulfill() }
            
            waitForExpectations(timeout: 5.0, handler: nil)
            
            XCTAssertEqual(value, 9)
        }
    }
    
    func testMap() {
        do {
            let expectation = self.expectation(description: "")
            
            let a: Promise<Int> = async(3)
            let r: Promise<Int> = a >>- { a in async(a * a) }
            
            var value: Int? = nil
            r { value = $0; expectation.fulfill() }
            
            waitForExpectations(timeout: 5.0, handler: nil)
            
            XCTAssertEqual(value, 9)
        }
    }
    
    func testApply() {
        do {
            let expectation = self.expectation(description: "")

            let a: Promise<Int> = async(3)
            let f: Promise<(Int) -> Int> = async({ $0 * $0 })
            let r: Promise<Int> = f <*> a

            var value: Int? = nil
            r { value = $0; expectation.fulfill() }
            
            waitForExpectations(timeout: 5.0, handler: nil)
            
            XCTAssertEqual(value, 9)
        }
    }
    
    func testSample() {
        let expectation = self.expectation(description: "")
        
        /////
        
        // Wrapping
        let a: Promise<Int> = { $0(3) } // like `Promise.resolve(3)` in JS
        // Promisifying a callback
        let b: Promise<Int> = promise { resolve in
            // Gets 5 after 1.0 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                resolve({ $0(5) })
            }
        }
        
        // Operators
        let sum: Promise<Int> = a >>- { a in b >>- { b in { $0(a + b) } } } // flatMap
        let square: Promise<Int> = { $0 * $0 } <^> a // map
        let vector: Promise<Vector2> = curry(Vector2.init) <^> { $0(2.0) } <*> { $0(3.0) } // apply
        
        /////
        
        var sumValue: Int = -1
        sum { sumValue = $0 }
        
        var squareValue: Int = -1
        square { squareValue = $0 }
        
        var vectorValue: Vector2 = Vector2(x: .nan, y: .nan)
        vector { vectorValue = $0 }
        
        let wait: Promise<()> = sum >>- { _ in square >>- { _ in vector >>- { _ in { $0() } } } }
        wait { expectation.fulfill() }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
        XCTAssertEqual(sumValue, 8)
        XCTAssertEqual(squareValue, 9)
        XCTAssertEqual(vectorValue.x, 2.0)
        XCTAssertEqual(vectorValue.y, 3.0)
    }

    static var allTests : [(String, (PromiseTests) -> () throws -> Void)] {
        return [
            ("testPromise", testPromise),
            ("testFlatMapLeft", testFlatMapLeft),
            ("testFlatMapRight", testFlatMapRight),
            ("testMap", testMap),
            ("testApply", testApply),
            ("testSample", testSample),
        ]
    }
}

func async<Value>(_ value: Value) -> Promise<Value> {
    return promise { resolve in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            resolve({ $0(value) })
        }
    }
}

struct Vector2 {
    let x: Float
    let y: Float
}

func curry<A, B, Z>(_ f: @escaping (A, B) -> Z) -> (A) -> (B) -> Z {
    return { a in { b in f(a, b) } }
}
