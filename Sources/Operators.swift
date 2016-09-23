precedencegroup PromisureMonadicPrecedenceRight {
    associativity: right
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup PromisureMonadicPrecedenceLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup PromisureApplicativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: NilCoalescingPrecedence
}

infix operator >>- : PromisureMonadicPrecedenceLeft
infix operator -<< : PromisureMonadicPrecedenceRight

infix operator <^> : PromisureApplicativePrecedence
infix operator <*> : PromisureApplicativePrecedence
