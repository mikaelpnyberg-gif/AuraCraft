import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager

    var body: some View {
        ZStack {
            AuraColor.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AuraSpacing.xl) {
                    VStack(spacing: AuraSpacing.md) {
                        Image("AuraCraftLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 78, height: 78)
                            .clipShape(RoundedRectangle(cornerRadius: AuraRadius.md))
                            .shadow(color: AuraColor.cardShadow, radius: 10, x: 0, y: 4)

                        VStack(spacing: AuraSpacing.sm) {
                            Text(Strings.paywallTitle)
                                .font(AuraFont.display(34))
                                .foregroundColor(AuraColor.textPrimary)
                                .multilineTextAlignment(.center)

                            Text(Strings.paywallSubtitle)
                                .font(AuraFont.body(15))
                                .foregroundColor(AuraColor.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.top, AuraSpacing.xl)

                    VStack(spacing: AuraSpacing.sm) {
                        PaywallBenefitRow(icon: "square.grid.2x2.fill", title: Strings.benefitUnlimitedRooms)
                        PaywallBenefitRow(icon: "wand.and.stars", title: Strings.benefitAISuggestions)
                        PaywallBenefitRow(icon: "house.fill", title: Strings.benefitHomeKitSync)
                    }
                    .auraCard(padding: AuraSpacing.md)

                    VStack(spacing: AuraSpacing.md) {
                        Button {
                            Task { await storeManager.purchasePro() }
                        } label: {
                            HStack(spacing: AuraSpacing.sm) {
                                if storeManager.isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text(Strings.paywallPurchaseButton(storeManager.proPriceText))
                                    .font(AuraFont.caption(16))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AuraSpacing.md)
                            .background(RoundedRectangle(cornerRadius: AuraRadius.sm).fill(AuraColor.textPrimary))
                        }
                        .disabled(storeManager.isPurchasing)

                        Button(Strings.restorePurchases) {
                            Task { await storeManager.restorePurchases() }
                        }
                        .font(AuraFont.caption(14))
                        .foregroundColor(AuraColor.textSecondary)

                        if let error = storeManager.storeErrorMessage {
                            Text(error)
                                .font(AuraFont.body(12))
                                .foregroundColor(.red.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(AuraSpacing.lg)
            }
        }
        .presentationDetents([.medium, .large])
        .task {
            await storeManager.fetchProducts()
        }
        .onChange(of: storeManager.isProUnlocked) { _, isUnlocked in
            if isUnlocked { dismiss() }
        }
    }
}

private struct PaywallBenefitRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: AuraSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AuraColor.accent)
                .frame(width: 30, height: 30)
                .background(Circle().fill(AuraColor.accentLight))

            Text(title)
                .font(AuraFont.body(15))
                .foregroundColor(AuraColor.textPrimary)

            Spacer()
        }
        .padding(.vertical, AuraSpacing.xs)
    }
}

struct HardwareUpgradeBanner: View {
    @Environment(\.openURL) private var openURL

    let url = URL(string: "https://www.apple.com/home-app/accessories/")!

    var body: some View {
        Button {
            openURL(url)
        } label: {
            HStack(spacing: AuraSpacing.md) {
                ZStack {
                    Circle()
                        .fill(AuraColor.capRGB.opacity(0.12))
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AuraColor.capRGB)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(Strings.hardwareUpgradeTitle)
                        .font(AuraFont.title(15))
                        .foregroundColor(AuraColor.textPrimary)
                    Text(Strings.hardwareUpgradeSubtitle)
                        .font(AuraFont.body(12))
                        .foregroundColor(AuraColor.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AuraColor.textTertiary)
            }
            .padding(AuraSpacing.md)
            .background(RoundedRectangle(cornerRadius: AuraRadius.md).fill(AuraColor.surface))
            .overlay(
                RoundedRectangle(cornerRadius: AuraRadius.md)
                    .strokeBorder(AuraColor.divider, lineWidth: 1)
            )
            .shadow(color: AuraColor.cardShadow, radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct LockedRoomsCard: View {
    let hiddenRoomCount: Int
    let onUpgrade: () -> Void

    var body: some View {
        Button(action: onUpgrade) {
            VStack(alignment: .leading, spacing: AuraSpacing.sm) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AuraColor.accent)

                Spacer()

                Text(Strings.lockedRoomsTitle(hiddenRoomCount))
                    .font(AuraFont.title(15))
                    .foregroundColor(AuraColor.textPrimary)
                    .multilineTextAlignment(.leading)

                Text(Strings.lockedRoomsSubtitle)
                    .font(AuraFont.body(12))
                    .foregroundColor(AuraColor.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(height: 145)
            .padding(AuraSpacing.md)
            .background(RoundedRectangle(cornerRadius: AuraRadius.md).fill(AuraColor.surface))
            .overlay(
                RoundedRectangle(cornerRadius: AuraRadius.md)
                    .strokeBorder(AuraColor.divider, lineWidth: 1)
            )
            .shadow(color: AuraColor.cardShadow, radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}
