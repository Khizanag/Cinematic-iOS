import Foundation

/// A purchase price with its currency, kept as `Decimal` — never `Double` —
/// so money stays exact.
public struct Price: Hashable, Sendable {
    public let amount: Decimal
    public let currencyCode: String

    public init(amount: Decimal, currencyCode: String) {
        self.amount = amount
        self.currencyCode = currencyCode
    }
}
