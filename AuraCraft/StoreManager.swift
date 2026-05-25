import Foundation
import Combine
import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    static let proProductID = "com.myvalo.pro.monthly"
    private static let fallbackMonthlyPrice = "$1.99"

    @Published private(set) var proProduct: Product?
    @Published private(set) var isProUnlocked = false
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false
    @Published var storeErrorMessage: String?

    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        if AppScreenshotMode.isEnabled {
            isProUnlocked = true
            return
        }

        transactionUpdatesTask = listenForTransactions()

        Task {
            await fetchProducts()
            await updatePurchasedProducts()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    var proPriceText: String {
        proProduct?.displayPrice ?? Self.fallbackMonthlyPrice
    }

    func fetchProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let products = try await Product.products(for: [Self.proProductID])
            proProduct = products.first
            if proProduct != nil {
                storeErrorMessage = nil
            }
        } catch {
            storeErrorMessage = error.localizedDescription
        }
    }

    func purchasePro() async {
        guard let product = proProduct else {
            await fetchProducts()
            guard proProduct != nil else {
                storeErrorMessage = "Subscription is not available in this test run. Check the StoreKit configuration or App Store Connect product setup."
                return
            }
            return await purchasePro()
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                await   unlockPro(for: transaction)
                await   transaction.finish()
            case .pending:
                storeErrorMessage = Strings.purchasePending
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            storeErrorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await   updatePurchasedProducts()
        } catch {
            storeErrorMessage = error.localizedDescription
        }
    }

    func updatePurchasedProducts() async {
        var hasProEntitlement = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }

            if transaction.productID == Self.proProductID,
               transaction.revocationDate == nil {
                hasProEntitlement = true
            }
        }

        isProUnlocked = hasProEntitlement
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }

                do {
                    let transaction = try self.checkVerified(result)
                    await    self.unlockPro(for: transaction)
                    await transaction.finish()
                } catch {
                    await    MainActor.run {
                        self.storeErrorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    private func unlockPro(for transaction: Transaction) async {
        guard transaction.productID == Self.proProductID else { return }
        isProUnlocked = transaction.revocationDate == nil
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreError.failedVerification
        }
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        Strings.purchaseVerificationFailed
    }
}
