// ============================================================
// MODULE 4: Swift Programming Fundamentals
// LAB — PNC Banking Domain Model
// Enterprise Mobile Application Development Bootcamp
// ============================================================
//
// OVERVIEW
// You are building the Swift data model layer for the PNC Mobile
// Banking application. This layer will be carried forward into
// Modules 6, 7, and 8 as the foundation of the real application.
//
// Every type you define here uses the Swift features from all
// three days of this module. Take time to read the full spec
// before writing any code.
//
// ESTIMATED TIME: 90–120 minutes
//
// ============================================================
// LAB SPEC
// ============================================================
//
// You will build five interconnected Swift types:
//
//   1. TransactionType enum
//   2. TransactionStatus enum
//   3. Transaction struct
//   4. Account class
//   5. AccountAnalytics struct
//
// And three protocols:
//
//   A. Summarizable       — any type that can produce a summary string
//   B. AccountOperations  — deposit, withdraw, transfer
//   C. AnalyticsProvider  — compute basic financial metrics
//
// The lab ends with an error handling system and a generic
// result reporting function that ties everything together.
//
// Read each section completely before implementing it.
// ============================================================

import Foundation


// ============================================================
// SECTION 1: Enumerations
// ============================================================

// TODO 1A: TransactionType
// Conform to: String, CaseIterable, Codable
// Cases:     credit, debit, transfer, fee
// Add computed property: isExpense: Bool
//   → true for .debit and .fee, false otherwise

enum TransactionType: String, CaseIterable, Codable {
    case credit = "credit"
    case debit = "debit"
    case transfer = "transfer"
    case fee = "fee"

    var isExpense: Bool {
        switch self {
            case .debit:
                return true
            case .fee:
                return true
            default:
                return false
        }
    }
}

// TODO 1B: TransactionStatus
// Conform to: String, Codable
// Cases:     pending, completed, failed, cancelled
// Add computed property: isTerminal: Bool
//   → true for .completed, .failed, .cancelled
//   → false for .pending (can still change)

enum TransactionStatus: String, Codable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"

    var isTerminal: Bool {
        switch self {
            case .completed:
                return true
            case .failed:
                return true
            case .cancelled:
                return true
            case .pending:
                return false
        }

    }
}

// ============================================================
// SECTION 2: Transaction Struct
// ============================================================

// TODO 2: Define struct Transaction conforming to:
//   Identifiable, Codable, Equatable, Hashable, Summarizable (see Section 4A)
//
// Stored properties:
//   id: String                (unique identifier, default to UUID().uuidString)
//   date: Date
//   amount: Double            (always positive — type determines direction)
//   description: String
//   type: TransactionType
//   status: TransactionStatus (default: .completed)
//   category: String?
//   merchantName: String?
//
// Computed properties:
//   formattedAmount: String
//     → "-$X.XX" for expenses (type.isExpense == true)
//     → "+$X.XX" for income/credit
//
//   formattedDate: String
//     → Use DateFormatter with dateStyle: .medium, timeStyle: .short
//
//   resolvedCategory: String
//     → Returns category if non-nil, "Uncategorized" otherwise
//
// Custom initializer (all params except id, status, category, merchantName
// should be required; the rest should have defaults):
//   init(date:amount:description:type:status:category:merchantName:)

struct Transaction: Identifiable, Codable, Equatable, Hashable, Summarizable {
    let id: String = UUID().uuidString
    let date: Date
    let amount: Double
    var description: String
    let type: TransactionType
    var status: TransactionStatus
    var category: String?
    var merchantName: String?
     
    init(date: Date, amount: Double, description: String, type: TransactionType, status: TransactionStatus = TransactionStatus.completed, category: String? = nil, merchantName: String? = nil){
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = category
        self.merchantName = merchantName
    }

    var summary: String { "[Transaction Summary] - Date: \(formattedDate) | Amount: \(formattedAmount) | Description: \(description) | Type: \(type) | Status: \(status) | Category: \(resolvedCategory) | Merchant Name: \(merchantName)" }

    var formattedAmount: String {
        let prefix: String = type.isExpense ? "-" : "+"
        return "\(prefix)$\(String(format: "%.2f", amount))"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var resolvedCategory: String {
        if let retCategory = category {
            return retCategory
        }
        else {
            return "Uncategorized"
        }
    }
}

// ============================================================
// SECTION 3: Account Class
// ============================================================

// TODO 3A: Define protocol AccountOperations (see Section 4B)
// before defining Account, because Account will conform to it.
// (Define the protocol in Section 4B, then add conformance to Account here)


// TODO 3B: Define class BankAccount conforming to:
//   Identifiable, AccountOperations, Summarizable
//
// Stored properties:
//   id: String
//   accountNumber: String
//   accountType: String          (e.g., "CHECKING", "SAVINGS")
//   nickname: String?
//   var balance: Double
//   var availableBalance: Double
//   let currency: String         (default "USD")
//   let isActive: Bool           (default true)
//   var transactions: [Transaction]
//
// Computed properties:
//   displayName: String          → nickname if non-nil, else accountType.capitalized
//   maskedAccountNumber: String  → "****" + last 4 digits
//   formattedBalance: String     → "$X.XX"
//   recentTransactions: [Transaction]  → last 5, sorted by date descending
//   pendingCount: Int            → count of transactions with status .pending
//
// Designated initializer:
//   init(id:accountNumber:accountType:nickname:initialBalance:currency:isActive:)
//
// Implement AccountOperations (see Section 4B for the protocol requirements).
// Use the AccountError enum from Section 4C.
//
// Also add:
//   func addTransaction(_ transaction: Transaction)
//     → appends to transactions AND updates balance:
//       if transaction.type.isExpense: balance -= transaction.amount
//       else:                          balance += transaction.amount
//       Update availableBalance to match balance.

class BankAccount: Identifiable, AccountOperations, Summarizable {
    let id: String
    let accountNumber: String
    let accountType: String
    let nickname: String?
    var balance: Double
    var availableBalance: Double
    let currency: String
    let isActive: Bool
    var transactions: [Transaction] = []

    init(id: String, accountNumber: String, accountType: String, nickname: String?, initialBalance: Double, currency: String, isActive: Bool){
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        balance = initialBalance
        availableBalance = initialBalance
        self.currency = currency
        self.isActive = isActive
    }

    var summary: String { "[Account Summary] - Id: \(id) | Account Number: \(maskedAccountNumber) | Balance: \(formattedBalance)" }

    var displayName: String {
        if let name = nickname {
            return name
        }
        return accountType.capitalized
    }

    var maskedAccountNumber: String { "****" + accountNumber.suffix(4) }

    var formattedBalance: String { "$\(String(format: "%.2f", balance))" }

    var recentTransactions: [Transaction] { transactions.suffix(5).sorted {
        ($0.date > $1.date)
    } }

    var pendingCount: Int { transactions.filter {
        ($0.status == TransactionStatus.pending)
    }.count }

    func deposit(amount: Double) throws {

        guard isActive else {
            throw AccountOperationsError.accountInactive
        }

        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }

        balance += amount
        return
    }

    func withdraw(amount: Double) throws {

        guard isActive else {
            throw AccountOperationsError.accountInactive
        }

        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }

        guard amount <= balance else {
            throw AccountOperationsError.insufficientFunds(available: balance, required: amount)
        }

        balance -= amount
        return
    }

    func transfer(amount: Double, to destination: BankAccount) throws {

        guard isActive else {
            throw AccountOperationsError.accountInactive
        }

        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }

        guard amount <= balance else {
            throw AccountOperationsError.insufficientFunds(available: balance, required: amount)
        }

        guard destination.id != id else {
            throw AccountOperationsError.transferToSameAccount
        }

        balance -= amount
        destination.balance += amount
        return

    }

    func addTransaction(_ transaction: Transaction) {
        if transaction.type.isExpense {
            balance -= transaction.amount
        }
        else {
            balance += transaction.amount
        }

        transactions.append(transaction)
    }

}

// ============================================================
// SECTION 4: Protocols
// ============================================================

// TODO 4A: Summarizable protocol
//   Required: var summary: String { get }
//   Default implementation via extension: func printSummary() — prints summary

protocol Summarizable {
    var summary: String { get }
}

extension Summarizable {
    func printSummary() {
        print(summary)
    }
}

// TODO 4B: AccountOperations protocol
//   func deposit(amount: Double) throws
//   func withdraw(amount: Double) throws
//   func transfer(amount: Double, to destination: BankAccount) throws
//
// These methods throw AccountOperationsError (define in Section 4C).

protocol AccountOperations {
    func deposit(amount: Double) throws
    func withdraw(amount: Double) throws
    func transfer(amount: Double, to destination: BankAccount) throws
}

// TODO 4C: AccountOperationsError enum conforming to LocalizedError
// Cases:
//   invalidAmount
//   insufficientFunds(available: Double, required: Double)
//   accountInactive
//   transferToSameAccount
//   dailyLimitExceeded(limit: Double)
//
// Each case should have a meaningful errorDescription.

enum AccountOperationsError: LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double, required: Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded(limit: Double)

    var errorDescription: String? {
        switch self {
            case .invalidAmount:
                return "Amount must be >= 0."
            case .insufficientFunds(let available, let required):
                return "Insufficient Funds! Available: \(available) | Required: \(required)"
            case .accountInactive:
                return "Account is inactive."
            case .transferToSameAccount:
                return "Cannot transfer to the same account."
            case .dailyLimitExceeded(let limit):
                return "Daily limit of \(limit) exceeded."

        }
    }
}

// ============================================================
// SECTION 5: Analytics
// ============================================================

// TODO 5A: AnalyticsProvider protocol
//   var totalCredits: Double { get }
//   var totalDebits: Double { get }
//   var netFlow: Double { get }         // credits - debits
//   var largestTransaction: Transaction? { get }
//   func monthlyTotal(month: Int, year: Int) -> Double
//   func transactionsByCategory() -> [String: [Transaction]]

protocol AnalyticsProvider {
    var totalCredits: Double { get }
    var totalDebits: Double { get }
    var netFlow: Double { get }
    var largestTransaction: Transaction? { get }
    
    func monthlyTotal(month: Int, year: Int) -> Double
    func transactionsByCategory() -> [String: [Transaction]]
}

// TODO 5B: AccountAnalytics struct
// Stored property: transactions: [Transaction]
// Conform to AnalyticsProvider.
// Implement each requirement.
//
// Tips:
//   totalCredits: use .filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
//   transactionsByCategory: group by resolvedCategory using a Dictionary
//     (hint: use Dictionary(grouping:by:))
//   monthlyTotal: filter by Calendar.current month/year components and sum expense amounts

struct AccountAnalytics: AnalyticsProvider {
    var totalCredits: Double { transactions.filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount } }
    var totalDebits: Double { transactions.filter { $0.type.isExpense }.reduce(0) { $0 + $1.amount } }
    var netFlow: Double { totalCredits - totalDebits }
    var largestTransaction: Transaction? { transactions.sorted { ($0.amount > $1.amount) }.first }
    var transactions: [Transaction] = []

    func monthlyTotal(month: Int, year: Int) -> Double {
        let calendar = Calendar.current
        return transactions.filter{$0.type.isExpense}
        .filter{calendar.component(.month, from: $0.date) == month}
        .filter{calendar.component(.year, from: $0.date) == year}
        .reduce(0) { $0 + $1.amount }
    }

    func transactionsByCategory() -> [String: [Transaction]] {
        return Dictionary(grouping: transactions, by: { $0.resolvedCategory })
    }
}

// ============================================================
// SECTION 6: Generic Result Reporter
// ============================================================

// TODO 6: Write a generic function:
//   func reportResults<T: Summarizable>(_ items: [T], title: String)
//
// It should:
//   1. Print a header line: "=== [title] ==="
//   2. Print the item count: "[N] items"
//   3. Call printSummary() on each item
//   4. Print a footer: "=== End of [title] ==="
//
// The function must work for any type conforming to Summarizable —
// including both Transaction and BankAccount.

func reportResults<T: Summarizable>(_ items: [T], title: String) {
    print("=== \(title) ===")
    print("\(items.count) items")

    for item in items {
        item.printSummary()
    }

    print("=== End of \(title) ===")
}

// ============================================================
// SECTION 7: INTEGRATION TEST — Tie it all together
// ============================================================

// TODO 7: Write a function named runlabDemo() that does the following:

// 7A: Create at least two BankAccount instances:
//   - A checking account with $3,500 initial balance
//   - A savings account with $12,000 initial balance

// 7B: Create at least five Transaction instances across different types
//   and add them to the checking account using addTransaction(_:)
//   Include: one credit, two debits, one fee, one transfer
//   Verify the balance updates correctly after each addition.

// 7C: Demonstrate error handling:
//   - Try to withdraw more than the available balance → catch insufficientFunds
//   - Try to deposit a negative amount → catch invalidAmount
//   - Try to transfer to the same account → catch transferToSameAccount
//   Print the localized error description for each caught error.

// 7D: Create an AccountAnalytics instance with the checking account's transactions.
//   Print:
//   - Total credits
//   - Total debits
//   - Net flow
//   - The description and amount of the largest transaction
//   - The transactions grouped by category (print each category and count)

// 7E: Call reportResults with the checking account's transactions, title: "Checking Transactions"
//   Call reportResults with [checkingAccount, savingsAccount], title: "All Accounts"

// 7F: Demonstrate value vs. reference semantics:
//   Copy one Transaction (struct) into a new variable. Modify the copy's description.
//   Show the original is unchanged.
//   Assign the checking account (class) to a new variable. Deposit $100 through the alias.
//   Show both variables reflect the updated balance.

// TODO: Call runlabDemo() at the bottom of the file.

func runlabDemo() {
    // 7A: Bank Account Instances

    let acc1 = BankAccount(id: "id1", accountNumber: "001", accountType: "CHECKING",  nickname: "Jill", initialBalance: 3_500.00, currency: "USD", isActive: true)
    let acc2 = BankAccount(id: "id2", accountNumber: "002", accountType: "SAVINGS",  nickname: "Bob", initialBalance: 12_000.00, currency: "USD", isActive: true)

    // 7B: 5 Transactions of Different Types

    print("-- Depositing into acc1 --")

    var transactions = [
        Transaction(date: Date(), amount: 100, description: "Credit", type: TransactionType.credit, category: "Food"),
        Transaction(date: Date(), amount: 200, description: "Debit 1", type: TransactionType.debit, category: "Food"),
        Transaction(date: Date(), amount: 300, description: "Debit 2", type: TransactionType.debit),
        Transaction(date: Date(), amount: 400, description: "Fee", type: TransactionType.fee),
        Transaction(date: Date(), amount: 500, description: "Transfer", type: TransactionType.transfer, category: "Family")
    ]

    for transaction in transactions {
        acc1.addTransaction(transaction)
        print("\(transaction.type): \(acc1.balance)")
    }

    // 7C: Error Handling

    print("-- Error Handling --")

    do {
        try acc1.withdraw(amount: 10000.00)
    } catch let e as AccountOperationsError {
        print(e.localizedDescription)
    } catch {
        print(error)
    }
    
    do {
        try acc1.deposit(amount: -1)
    } catch let e as AccountOperationsError {
        print(e.localizedDescription)
    } catch {
        print(error)
    }

    do {
        try acc1.transfer(amount: 100, to: acc1)
    } catch let e as AccountOperationsError {
        print(e.localizedDescription)
    } catch {
        print(error)
    }

    // 7D: Create an AccountAnalytics instance

    print("-- Account Analytics --")

    var analytics = AccountAnalytics()
    analytics.transactions = acc1.transactions
    print("Total Credits: \(analytics.totalCredits)")
    print("Total Debits: \(analytics.totalDebits)")
    print("Net Flow: \(analytics.netFlow)")

    if let trans = analytics.largestTransaction {
        print("Largest Transaction: \(trans.amount) (\(trans.description))")
    } else {
        print("No Largest Transaction Found")
    }

    for category in analytics.transactionsByCategory() {
        print("Category: \(category.key) (\(category.value.count))")
        for trans in category.value {
            print(trans.description)
        }
    }
    
    // 7E: Report Results

    print("-- Report Results --")

    reportResults(acc1.transactions, title: "Checking Transactions")
    reportResults([acc1, acc2], title: "All Accounts")

    // 7F: Value vs Reference

    print("-- Value vs. Reference --")

    var struct1 = Transaction(date: Date(), amount: 100, description: "Unchanged", type: TransactionType.credit, category: "Food")
    var struct2 = struct1
    struct2.description = "Edit"
    print(struct1.description)

    var class1 = BankAccount(id: "id1", accountNumber: "001", accountType: "CHECKING",  nickname: "Jill", initialBalance: 3_500.00, currency: "USD", isActive: true)
    var class2 = class1
    
    do {
        try class2.deposit(amount: 100)
            print("class1 Balance: \(class1.formattedBalance) | class2 Balance: \(class2.formattedBalance)")
    }   catch let e as AccountOperationsError {
            print(e.localizedDescription)
    }   catch {
            print(error)
    }

}

runlabDemo()

// ============================================================
// END OF LAB
// ============================================================
//
// SELF-ASSESSMENT CHECKLIST
// Before submitting, verify:
//   [ ] All five types compile without warnings
//   [ ] runlabDemo() runs to completion with no crashes
//   [ ] Each error case in 7C is handled and prints a clear message
//   [ ] Struct copy semantics are correctly demonstrated in 7F
//   [ ] Class reference semantics are correctly demonstrated in 7F
//   [ ] reportResults works for both Transaction and BankAccount
//   [ ] Analytics produce correct totals matching your transactions
// ============================================================
