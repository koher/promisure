import Foundation

public typealias Promise<Value> = (@escaping (Value) -> ()) -> ()

func >>-<Value, T>(promise: @escaping Promise<Value>, transform: @escaping (Value) -> Promise<T>) -> Promise<T> {
    return { callback in promise { value in (transform(value)) { transformed in callback(transformed) } } }
}

func -<<<Value, T>(transform: @escaping (Value) -> Promise<T>, promise: @escaping Promise<Value>) -> Promise<T> {
    return promise >>- transform
}

func <^><Value, T>(transform: @escaping (Value) -> T, promise: @escaping Promise<Value>) -> Promise<T> {
    return { callback in promise { value in callback(transform(value)) } }
}

func <*><Value, T>(transform: @escaping Promise<(Value) -> T>, promise: @escaping Promise<Value>) -> Promise<T> {
    return transform >>- { $0 <^> promise }
}

func promise<T>(_ executor: (@escaping (Promise<T>) -> ()) -> ()) -> Promise<T> {
    let lock = NSRecursiveLock()
    var resolvedValue: T? = nil
    var callbacks: Array<(T) -> ()> = []
    executor { promise in
        promise { value in
            synchronized(by: lock) {
                if resolvedValue == nil {
                    resolvedValue = value
                    callbacks.forEach { callback in callback(value) }
                    callbacks.removeAll()
                }
            }
        }
    }
    return { callback in
        synchronized(by: lock) {
            if let value = resolvedValue {
                callback(value)
            } else {
                callbacks.append(callback)
            }
        }
    }
}

private func synchronized(by lock: NSRecursiveLock, _ operation: () -> ()) {
    lock.lock()
    operation()
    lock.unlock()
}
