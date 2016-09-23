# Promisure 

_Promisure_ provides `Promise` as a typealias of a closure.

```swift
typealias Promise<Value> = (@escaping (Value) -> ()) -> ()
```

_Promisure_ also provides `promise` function to promisify asyncronous operations and some functional operators to make it easy to handle `Promise`.

```swift
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
```

## License

[The MIT License](LICENSE)
