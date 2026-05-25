// ╔══════════════════════════════════════════════════════════════════╗
// ║  MyValo.swift                                                     ║
// ║  Intelligent Lighting Design for Apple Home                       ║
// ║  Architecture: MVVM + Service Layer (HomeKit Mocked)              ║
// ║  Target: iOS 16+  |  SwiftUI  |  Localized: EN / FI              ║
// ╚══════════════════════════════════════════════════════════════════╝

import SwiftUI
import Combine
import HomeKit

// ============================================================
// MARK: - § 1  LOCALIZATION
// ============================================================
// In production replace these computed strings with NSLocalizedString()
// and maintain Localizable.strings files for each target language.
// Key names here act as the canonical translation identifiers.

private enum Language: String {
    case english = "en"
    case finnish = "fi"
    case spanish = "es"
    case japanese = "ja"
    case german = "de"
    case swedish = "sv"
    case chinese = "zh"

    static var current: Language {
        let preferredLanguage = Locale.preferredLanguages.first ?? Locale.current.identifier
        let code = Locale(identifier: preferredLanguage).language.languageCode?.identifier ?? "en"
        return Language(rawValue: code) ?? .english
    }
}

private func L(
    _ en: String,
    fi: String,
    es: String? = nil,
    ja: String? = nil,
    de: String? = nil,
    sv: String? = nil,
    zh: String? = nil
) -> String {
    switch Language.current {
    case .english: return en
    case .finnish: return fi
    case .spanish: return es ?? en
    case .japanese: return ja ?? en
    case .german: return de ?? en
    case .swedish: return sv ?? en
    case .chinese: return zh ?? en
    }
}

enum Strings {
    // App shell
    static let appName          = "MyValo"
    static let appTagline       = L("Lighting Moods", fi: "Valaistustunnelmat", es: "Ambientes de luz", ja: "照明ムード", de: "Lichtstimmungen", sv: "Ljuslägen", zh: "灯光氛围")
    // Dashboard
    static let homeTitle        = L("My Home", fi: "Kotini", es: "Mi hogar", ja: "マイホーム", de: "Mein Zuhause", sv: "Mitt hem", zh: "我的家")
    static let rooms            = L("Rooms", fi: "Huoneet", es: "Habitaciones", ja: "部屋", de: "Räume", sv: "Rum", zh: "房间")
    static let lights           = L("lights", fi: "valoa", es: "luces", ja: "ライト", de: "Lichter", sv: "lampor", zh: "盏灯")
    // Sections
    static let suggestions      = L("Suggested for You", fi: "Suositukset sinulle", es: "Sugerencias para ti", ja: "おすすめ", de: "Für dich empfohlen", sv: "Förslag för dig", zh: "为你推荐")
    static let moodLibrary      = L("Mood Library", fi: "Tunnelmakirjasto", es: "Biblioteca de ambientes", ja: "ムードライブラリ", de: "Stimmungsbibliothek", sv: "Stämningsbibliotek", zh: "氛围库")
    // Actions
    static let apply            = L("Apply Mood", fi: "Käytä tunnelmaa", es: "Aplicar ambiente", ja: "ムードを適用", de: "Stimmung anwenden", sv: "Använd stämning", zh: "应用氛围")
    static let applied          = L("Applied!", fi: "Käytetty!", es: "Aplicado", ja: "適用済み", de: "Angewendet", sv: "Använt", zh: "已应用")
    static let connecting       = L("Connecting…", fi: "Yhdistetään…", es: "Conectando…", ja: "接続中…", de: "Verbinden…", sv: "Ansluter…", zh: "正在连接…")
    static let connectToHome    = L("Connect to Home", fi: "Yhdistä kotiin", es: "Conectar al hogar", ja: "ホームに接続", de: "Mit Zuhause verbinden", sv: "Anslut till hemmet", zh: "连接到家庭")
    static let activeScene      = L("Active Scene", fi: "Aktiivinen kohtaus", es: "Escena activa", ja: "有効なシーン", de: "Aktive Szene", sv: "Aktiv scen", zh: "当前场景")
    // Auth
    static let homeAccessTitle  = L("Home Access", fi: "Kodin käyttöoikeus", es: "Acceso al hogar", ja: "ホームへのアクセス", de: "Zugriff auf Zuhause", sv: "Hemåtkomst", zh: "家庭访问权限")
    static let homeAccessDesc   = L(
        "MyValo needs access to your Apple Home to illuminate your world.",
        fi: "MyValo tarvitsee pääsyn Apple Kotiisi voidakseen valaista maailmaasi.",
        es: "MyValo necesita acceso a tu Apple Home para iluminar tu mundo.",
        ja: "MyValoがあなたの世界を照らすにはApple Homeへのアクセスが必要です。",
        de: "MyValo benötigt Zugriff auf dein Apple Home, um deine Welt zu beleuchten.",
        sv: "MyValo behöver åtkomst till ditt Apple-hem för att lysa upp din värld.",
        zh: "MyValo 需要访问你的 Apple 家庭，才能点亮你的世界。"
    )
    // Badges
    static let suggestedMood    = L("Suggested Mood", fi: "Ehdotettu tunnelma", es: "Ambiente sugerido", ja: "おすすめムード", de: "Vorgeschlagene Stimmung", sv: "Föreslagen stämning", zh: "推荐氛围")
    // Capabilities
    static let fullColor        = L("Full Color", fi: "Täysi väri", es: "Color completo", ja: "フルカラー", de: "Vollfarbe", sv: "Full färg", zh: "全彩")
    static let colorTemp        = L("Color Temp", fi: "Värilämpötila", es: "Temperatura", ja: "色温度", de: "Farbtemperatur", sv: "Färgtemperatur", zh: "色温")
    static let dimmable         = L("Dimmable", fi: "Himmennettävä", es: "Regulable", ja: "調光対応", de: "Dimmbar", sv: "Dimbar", zh: "可调光")
    // Categories
    static let productivity     = L("Productivity", fi: "Tuottavuus", es: "Productividad", ja: "生産性", de: "Produktivität", sv: "Produktivitet", zh: "效率")
    static let relaxation       = L("Relaxation", fi: "Rentoutuminen", es: "Relajación", ja: "リラックス", de: "Entspannung", sv: "Avkoppling", zh: "放松")
    static let entertainment    = L("Entertainment", fi: "Viihde", es: "Entretenimiento", ja: "エンタメ", de: "Unterhaltung", sv: "Underhållning", zh: "娱乐")
    static let nature           = L("Nature", fi: "Luonto", es: "Naturaleza", ja: "自然", de: "Natur", sv: "Natur", zh: "自然")
    // Detail sheet
    static let settingsHeader          = L("SETTINGS", fi: "ASETUKSET", es: "AJUSTES", ja: "設定", de: "EINSTELLUNGEN", sv: "INSTÄLLNINGAR", zh: "设置")
    static let compatibleHeader        = L("COMPATIBLE IN THIS ROOM", fi: "YHTEENSOPIVAT VALOT", es: "COMPATIBLES EN ESTA HABITACIÓN", ja: "この部屋で対応", de: "KOMPATIBEL IN DIESEM RAUM", sv: "KOMPATIBLA I DETTA RUM", zh: "此房间中兼容")
    static func compatibleLights(_ c: Int, _ total: Int) -> String {
        L("\(c) of \(total) lights will respond",
          fi: "\(c)/\(total) valoa reagoi",
          es: "\(c) de \(total) luces responderán",
          ja: "\(total)個中\(c)個のライトが反応します",
          de: "\(c) von \(total) Lichtern reagieren",
          sv: "\(c) av \(total) lampor svarar",
          zh: "\(total) 盏灯中有 \(c) 盏会响应")
    }
    // StoreKit / Paywall
    static let paywallTitle            = L("MyValo Pro", fi: "MyValo Pro", es: "MyValo Pro", ja: "MyValo Pro", de: "MyValo Pro", sv: "MyValo Pro", zh: "MyValo Pro")
    static let paywallSubtitle         = L("Unlock the full lighting studio for $1.99 per month.", fi: "Avaa koko valaistusstudio hintaan 1,99 $ kuukaudessa.", es: "Desbloquea todo el estudio de iluminación por 1,99 $ al mes.", ja: "月額1.99ドルで照明スタジオ全体を解除できます。", de: "Schalte das komplette Lichtstudio fuer 1,99 $ pro Monat frei.", sv: "Lås upp hela ljusstudion för 1,99 $ per månad.", zh: "每月 1.99 美元即可解锁完整灯光工作室。")
    static let benefitUnlimitedRooms   = L("Unlimited rooms", fi: "Rajattomasti huoneita", es: "Habitaciones ilimitadas", ja: "無制限の部屋", de: "Unbegrenzte Räume", sv: "Obegränsat antal rum", zh: "无限房间")
    static let benefitLightingSuggestions = L("Premium lighting suggestions", fi: "Premium-valaistusehdotukset", es: "Sugerencias de iluminación premium", ja: "プレミアム照明提案", de: "Premium-Lichtvorschläge", sv: "Premium-ljusförslag", zh: "高级灯光建议")
    static let benefitHomeKitSync      = L("HomeKit mood sync", fi: "HomeKit-tunnelmien synkronointi", es: "Sincronización de ambientes con HomeKit", ja: "HomeKitムード同期", de: "HomeKit-Stimmungssync", sv: "HomeKit-synk av stämningar", zh: "HomeKit 氛围同步")
    static let restorePurchases        = L("Restore Purchases", fi: "Palauta ostot", es: "Restaurar compras", ja: "購入を復元", de: "Käufe wiederherstellen", sv: "Återställ köp", zh: "恢复购买")
    static let paywallPriceUnavailable = L("Price unavailable", fi: "Hinta ei saatavilla", es: "Precio no disponible", ja: "価格を取得できません", de: "Preis nicht verfügbar", sv: "Pris ej tillgängligt", zh: "价格不可用")
    static let purchasePending         = L("Purchase is pending approval.", fi: "Osto odottaa hyväksyntää.", es: "La compra está pendiente de aprobación.", ja: "購入は承認待ちです。", de: "Der Kauf wartet auf Genehmigung.", sv: "Köpet väntar på godkännande.", zh: "购买正在等待批准。")
    static let purchaseVerificationFailed = L("We could not verify this purchase.", fi: "Ostoa ei voitu vahvistaa.", es: "No pudimos verificar esta compra.", ja: "この購入を確認できませんでした。", de: "Wir konnten diesen Kauf nicht verifizieren.", sv: "Vi kunde inte verifiera köpet.", zh: "无法验证此购买。")
    static let lockedProSuggestion     = L("Pro suggestion", fi: "Pro-ehdotus", es: "Sugerencia Pro", ja: "Pro提案", de: "Pro-Vorschlag", sv: "Pro-förslag", zh: "Pro 建议")
    static let lockedProSuggestionDesc = L("Unlock MyValo Pro to reveal this lighting mood.", fi: "Avaa MyValo Pro nähdäksesi tämän valaistustunnelman.", es: "Desbloquea MyValo Pro para revelar este ambiente de luz.", ja: "MyValo Proを解除してこの照明ムードを表示します。", de: "Schalte MyValo Pro frei, um diese Lichtstimmung zu sehen.", sv: "Lås upp MyValo Pro för att visa denna ljusstämning.", zh: "解锁 MyValo Pro 以显示此灯光氛围。")
    static let lockedRoomsSubtitle     = L("Upgrade for unlimited rooms", fi: "Päivitä rajattomiin huoneisiin", es: "Actualiza para habitaciones ilimitadas", ja: "アップグレードで部屋数無制限", de: "Upgrade für unbegrenzte Räume", sv: "Uppgradera för obegränsade rum", zh: "升级以解锁无限房间")
    static let hardwareUpgradeTitle    = L("Want full color?", fi: "Haluatko täyden värivalon?", es: "¿Quieres color completo?", ja: "フルカラーにしますか？", de: "Volle Farbe gewünscht?", sv: "Vill du ha full färg?", zh: "想要全彩灯光？")
    static let hardwareUpgradeSubtitle = L("Upgrade your lights", fi: "Päivitä valaisimesi", es: "Mejora tus luces", ja: "ライトをアップグレード", de: "Rüste deine Lichter auf", sv: "Uppgradera dina lampor", zh: "升级你的灯具")
    static func paywallPurchaseButton(_ price: String) -> String {
        L("Subscribe - \(price)/month", fi: "Tilaa - \(price)/kk", es: "Suscribirse - \(price)/mes", ja: "登録 - \(price)/月", de: "Abonnieren - \(price)/Monat", sv: "Prenumerera - \(price)/månad", zh: "订阅 - \(price)/月")
    }
    static func lockedRoomsTitle(_ count: Int) -> String {
        L("\(count) more rooms locked", fi: "\(count) huonetta lukittu", es: "\(count) habitaciones más bloqueadas", ja: "さらに\(count)部屋がロック中", de: "\(count) weitere Räume gesperrt", sv: "\(count) rum till är låsta", zh: "还有 \(count) 个房间已锁定")
    }
}

// ============================================================
// MARK: - § 2  DESIGN SYSTEM
// ============================================================

enum AuraColor {
    // Backgrounds — warm off-white Scandinavian palette
    static let background       = Color(red: 0.965, green: 0.957, blue: 0.941)
    static let surface          = Color.white
    // Typography
    static let textPrimary      = Color(red: 0.12,  green: 0.12,  blue: 0.14)
    static let textSecondary    = Color(red: 0.45,  green: 0.45,  blue: 0.50)
    static let textTertiary     = Color(red: 0.70,  green: 0.70,  blue: 0.74)
    // Brand accent — warm amber
    static let accent           = Color(red: 0.91,  green: 0.67,  blue: 0.38)
    static let accentLight      = Color(red: 0.98,  green: 0.93,  blue: 0.85)
    // Capability tints
    static let capRGB           = Color(red: 0.55,  green: 0.42,  blue: 0.85)
    static let capCT            = Color(red: 0.91,  green: 0.67,  blue: 0.38)
    static let capDim           = Color(red: 0.50,  green: 0.55,  blue: 0.62)
    // Utility
    static let cardShadow       = Color.black.opacity(0.06)
    static let divider          = Color.gray.opacity(0.10)
}

enum AuraFont {
    static func display(_ size: CGFloat) -> Font { .system(size: size, weight: .light,    design: .rounded) }
    static func title  (_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func body   (_ size: CGFloat) -> Font { .system(size: size, weight: .regular,  design: .rounded) }
    static func caption(_ size: CGFloat) -> Font { .system(size: size, weight: .medium,   design: .rounded) }
}

enum AuraSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum AuraRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
}

// ── Card modifier ────────────────────────────────────────────

struct AuraCardModifier: ViewModifier {
    var padding: CGFloat = AuraSpacing.md
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AuraColor.surface)
            .cornerRadius(AuraRadius.md)
            .shadow(color: AuraColor.cardShadow, radius: 12, x: 0, y: 4)
    }
}

extension View {
    func auraCard(padding: CGFloat = AuraSpacing.md) -> some View {
        modifier(AuraCardModifier(padding: padding))
    }
}

// ============================================================
// MARK: - § 3  MODELS
// ============================================================

// ── 3a  Light Capability ─────────────────────────────────────

/// Represents what a physical light bulb/fixture is capable of.
enum LightCapability: String, Codable, CaseIterable, Identifiable {
    case fullRGB           = "full_rgb"
    case colorTemperature  = "color_temperature"
    case dimmableOnly      = "dimmable_only"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullRGB:          return Strings.fullColor
        case .colorTemperature: return Strings.colorTemp
        case .dimmableOnly:     return Strings.dimmable
        }
    }

    var icon: String {
        switch self {
        case .fullRGB:          return "paintpalette.fill"
        case .colorTemperature: return "thermometer.sun.fill"
        case .dimmableOnly:     return "light.max"
        }
    }

    var tint: Color {
        switch self {
        case .fullRGB:          return AuraColor.capRGB
        case .colorTemperature: return AuraColor.capCT
        case .dimmableOnly:     return AuraColor.capDim
        }
    }

    /// Higher = more capable. Used for compatibility filtering.
    var capabilityLevel: Int {
        switch self {
        case .fullRGB:          return 3
        case .colorTemperature: return 2
        case .dimmableOnly:     return 1
        }
    }
}

// ── 3b  Light ────────────────────────────────────────────────

/// Maps to HMAccessory (a HomeKit light accessory) in production.
struct Light: Identifiable, Codable {
    let id: UUID
    var name: String
    var capability: LightCapability
    // Runtime state (synced from/to HomeKit characteristics)
    var isOn: Bool     = true
    var brightness: Double = 0.80   // 0.0–1.0  → HMCharacteristicTypeBrightness
    var hue: Double        = 0       // 0–360    → HMCharacteristicTypeHue
    var saturation: Double = 0.80   // 0.0–1.0  → HMCharacteristicTypeSaturation
    var colorTemperatureKelvin: Int = 4_000  // 2700–6500 → HMCharacteristicTypeColorTemperature

    init(id: UUID = UUID(), name: String, capability: LightCapability) {
        self.id = id; self.name = name; self.capability = capability
    }
}

// ── 3c  Room ─────────────────────────────────────────────────

/// Maps to HMRoom in production.
struct Room: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String          // SF Symbol name for UI
    var lights: [Light]

    init(id: UUID = UUID(), name: String, icon: String, lights: [Light] = []) {
        self.id = id; self.name = name; self.icon = icon; self.lights = lights
    }

    // MARK: Computed hardware profile

    /// The highest capability present in the room — drives mood engine branching.
    var dominantCapability: LightCapability {
        lights.map(\.capability)
              .sorted { $0.capabilityLevel > $1.capabilityLevel }
              .first ?? .dimmableOnly
    }

    /// A count per capability type, e.g. [.fullRGB: 3, .dimmableOnly: 1]
    var capabilityBreakdown: [LightCapability: Int] {
        lights.reduce(into: [:]) { $0[$1.capability, default: 0] += 1 }
    }

    var lightCount: Int { lights.count }
    var hasRGB: Bool    { lights.contains { $0.capability == .fullRGB } }
    var hasCT:  Bool    { lights.contains { $0.capability == .colorTemperature } }
}

// ── 3d  Light Setting ────────────────────────────────────────

/// The target state for a single light when a mood is applied.
struct LightSetting: Identifiable {
    let id = UUID()
    var brightness: Double                  // 0.0–1.0
    var colorTemperatureKelvin: Int? = nil  // nil → use hue/sat
    var hue: Double?        = nil           // 0–360
    var saturation: Double? = nil           // 0.0–1.0

    init(brightness: Double, colorTemperatureKelvin: Int? = nil, hue: Double? = nil, saturation: Double? = nil) {
        self.brightness = brightness
        self.colorTemperatureKelvin = colorTemperatureKelvin
        self.hue = hue
        self.saturation = saturation
    }

    init(brightness: Double, hex: String) {
        self.brightness = brightness
        let hs = ColorHex.hueSaturation(from: hex)
        self.hue = hs.hue
        self.saturation = hs.saturation
    }

    /// A SwiftUI Color for previewing this setting in the UI.
    var previewColor: Color {
        if let h = hue, let s = saturation {
            return Color(hue: h / 360, saturation: s, brightness: brightness)
        }
        if let ct = colorTemperatureKelvin {
            let t = Double(ct - 2_700) / Double(6_500 - 2_700)
            return Color(red: 1.0 - t * 0.30, green: 0.85 - t * 0.10, blue: 0.60 + t * 0.40)
        }
        return Color(white: brightness)
    }
}

enum ColorHex {
    static func color(from hex: String) -> Color {
        let rgb = rgbComponents(from: hex)
        return Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }

    static func hueSaturation(from hex: String) -> (hue: Double, saturation: Double) {
        let rgb = rgbComponents(from: hex)
        let maxValue = max(rgb.red, rgb.green, rgb.blue)
        let minValue = min(rgb.red, rgb.green, rgb.blue)
        let delta = maxValue - minValue
        guard delta > 0 else { return (0, 0) }

        let hue: Double
        if maxValue == rgb.red {
            hue = 60 * (((rgb.green - rgb.blue) / delta).truncatingRemainder(dividingBy: 6))
        } else if maxValue == rgb.green {
            hue = 60 * (((rgb.blue - rgb.red) / delta) + 2)
        } else {
            hue = 60 * (((rgb.red - rgb.green) / delta) + 4)
        }
        return (hue < 0 ? hue + 360 : hue, delta / maxValue)
    }

    private static func rgbComponents(from hex: String) -> (red: Double, green: Double, blue: Double) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else {
            return (1, 1, 1)
        }
        return (
            Double((value >> 16) & 0xFF) / 255,
            Double((value >> 8) & 0xFF) / 255,
            Double(value & 0xFF) / 255
        )
    }
}

// ── 3e  Mood Category ────────────────────────────────────────

enum MoodStyle {
    case still
    case living
}

enum MoodCategory: String, CaseIterable, Identifiable {
    case productivity   = "productivity"
    case relaxation     = "relaxation"
    case entertainment  = "entertainment"
    case nature         = "nature"
    case livingLights   = "living_lights"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .productivity:  return Strings.productivity
        case .relaxation:    return Strings.relaxation
        case .entertainment: return Strings.entertainment
        case .nature:        return Strings.nature
        case .livingLights:  return "Living Lights"
        }
    }

    var icon: String {
        switch self {
        case .productivity:  return "brain.head.profile"
        case .relaxation:    return "moon.stars.fill"
        case .entertainment: return "sparkles"
        case .nature:        return "leaf.fill"
        case .livingLights:  return "waveform.path.ecg"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .productivity:
            return [Color(red: 0.85, green: 0.92, blue: 1.00), Color(red: 0.65, green: 0.80, blue: 0.97)]
        case .relaxation:
            return [Color(red: 0.55, green: 0.38, blue: 0.75), Color(red: 0.33, green: 0.22, blue: 0.52)]
        case .entertainment:
            return [Color(red: 0.95, green: 0.48, blue: 0.38), Color(red: 0.72, green: 0.28, blue: 0.58)]
        case .nature:
            return [Color(red: 0.38, green: 0.68, blue: 0.48), Color(red: 0.22, green: 0.52, blue: 0.36)]
        case .livingLights:
            return [Color(red: 0.98, green: 0.48, blue: 0.22), Color(red: 0.55, green: 0.18, blue: 0.78)]
        }
    }
}

// ── 3f  Mood (Scene) ─────────────────────────────────────────

/// A named lighting scene — either algorithmically generated or a static preset.
struct Mood: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var category: MoodCategory
    /// true  → produced by MoodEngine for this room's hardware profile.
    /// false → a static preset from SceneLibrary.
    var isGenerated: Bool
    var isLocked: Bool
    var isPremium: Bool
    var style: MoodStyle
    /// Minimum hardware required; lights below this level receive a brightness-only fallback.
    var requiredCapability: LightCapability
    var lightSetting: LightSetting
    var lightSettings: [LightSetting]
    var gradientColors: [Color]
    var animationInterval: TimeInterval

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        category: MoodCategory,
        isGenerated: Bool = false,
        isLocked: Bool = false,
        isPremium: Bool = false,
        style: MoodStyle = .still,
        requiredCapability: LightCapability,
        lightSetting: LightSetting,
        lightSettings: [LightSetting]? = nil,
        gradientColors: [Color]? = nil,
        animationInterval: TimeInterval = 4
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.isGenerated = isGenerated
        self.isLocked = isLocked
        self.isPremium = isPremium
        self.style = style
        self.requiredCapability = requiredCapability
        self.lightSetting = lightSetting
        self.lightSettings = lightSettings ?? [lightSetting]
        self.gradientColors = gradientColors ?? category.gradientColors
        self.animationInterval = min(max(animationInterval, 3), 8)
    }
}

// ============================================================
// MARK: - § 4  HOMEKIT MANAGER
// ============================================================

final class HomeKitManager: NSObject, ObservableObject, HMHomeManagerDelegate {
    @Published var rooms: [Room] = []
    @Published var isAuthorized = false
    @Published var isLoading = false
    @Published var statusMessage: String?
    /// Room ID → currently applied mood
    @Published var appliedMoods: [UUID: Mood] = [:]
    @Published private(set) var favoriteMoodNames: Set<String> = []

    private let favoriteMoodNamesKey = "favoriteMoodNames"
    private var hmManager: HMHomeManager?
    private var lightBindings: [UUID: HomeKitLightBinding] = [:]

    struct ControllableLight: Identifiable {
        let id: UUID
        let name: String
        let roomName: String
        let capability: LightCapability
    }

    private struct HomeKitLightBinding {
        let homeID: UUID
        let accessoryID: UUID
        let serviceID: UUID
        let roomName: String
        let capability: LightCapability
    }

    override init() {
        super.init()
        favoriteMoodNames = Set(UserDefaults.standard.stringArray(forKey: favoriteMoodNamesKey) ?? [])
    }

    var totalLightCount: Int {
        rooms.reduce(0) { $0 + $1.lightCount }
    }

    var controllableLights: [ControllableLight] {
        rooms.flatMap { room in
            room.lights.map { light in
                ControllableLight(id: light.id, name: light.name, roomName: room.name, capability: light.capability)
            }
        }
    }

    func isFavorite(_ mood: Mood) -> Bool {
        favoriteMoodNames.contains(mood.name)
    }

    func toggleFavorite(_ mood: Mood) {
        if favoriteMoodNames.contains(mood.name) {
            favoriteMoodNames.remove(mood.name)
        } else {
            favoriteMoodNames.insert(mood.name)
        }
        let sortedNames = Array(favoriteMoodNames).sorted()
        UserDefaults.standard.set(sortedNames, forKey: favoriteMoodNamesKey)
    }

    // MARK: Authorization

    func requestAuthorization() {
        connectToHomeKit()
    }

    func connectToHomeKit() {
        if AppScreenshotMode.isEnabled {
            loadScreenshotHome()
            return
        }

        startHomeKitSession()
    }

    func refreshHomes() {
        if AppScreenshotMode.isEnabled {
            loadScreenshotHome()
            return
        }

        guard let manager = hmManager else {
            startHomeKitSession()
            return
        }

        isLoading = true
        statusMessage = "Refreshing HomeKit data..."
        refreshAuthorizationState(from: manager)
        if manager.authorizationStatus.contains(.authorized) {
            loadHomeKitRooms(from: manager)
        }
    }

    private func startHomeKitSession() {
        guard hmManager == nil else {
            refreshHomes()
            return
        }

        isLoading = true
        statusMessage = "Connecting to HomeKit..."
        let manager = HMHomeManager()
        manager.delegate = self
        hmManager = manager
        refreshAuthorizationState(from: manager)
    }

    // MARK: Room Loading

    private func refreshAuthorizationState(from manager: HMHomeManager) {
        let authorized = manager.authorizationStatus.contains(.authorized)
        DispatchQueue.main.async {
            self.isAuthorized = authorized
            if authorized {
                self.statusMessage = manager.homes.isEmpty ? "Loading HomeKit rooms..." : nil
            } else {
                self.isLoading = false
                self.rooms = []
                self.lightBindings = [:]
                self.statusMessage = "Home access is not authorized. Check HomeKit permission and the app's HomeKit capability."
            }
        }
    }

    private func loadHomeKitRooms(from manager: HMHomeManager) {
        guard !manager.homes.isEmpty else {
            DispatchQueue.main.async {
                self.isAuthorized = manager.authorizationStatus.contains(.authorized)
                self.isLoading = false
                self.rooms = []
                self.lightBindings = [:]
                self.statusMessage = "No homes were returned by HomeKit. Confirm this iPhone is signed into the same Apple ID as the Home app and that MyValo has Home access."
            }
            return
        }

        var bindings: [UUID: HomeKitLightBinding] = [:]
        let mappedRooms = manager.homes.flatMap { home in
            home.rooms.compactMap { homeRoom -> Room? in
                let lights = homeRoom.accessories.flatMap { accessory in
                    accessory.services
                        .filter { $0.serviceType == HMServiceTypeLightbulb }
                        .map { service -> Light in
                            let lightID = service.uniqueIdentifier
                            let lightCapability = capability(for: service)
                            bindings[lightID] = HomeKitLightBinding(
                                homeID: home.uniqueIdentifier,
                                accessoryID: accessory.uniqueIdentifier,
                                serviceID: service.uniqueIdentifier,
                                roomName: homeRoom.name,
                                capability: lightCapability
                            )
                            return Light(
                                id: lightID,
                                name: displayName(for: service, accessory: accessory),
                                capability: lightCapability
                            )
                        }
                }

                guard !lights.isEmpty else { return nil }
                return Room(
                    id: homeRoom.uniqueIdentifier,
                    name: homeRoom.name,
                    icon: iconName(for: homeRoom.name),
                    lights: lights
                )
            }
        }

        DispatchQueue.main.async {
            self.isAuthorized = manager.authorizationStatus.contains(.authorized)
            self.isLoading = false
            self.rooms = mappedRooms
            self.lightBindings = bindings
            self.statusMessage = mappedRooms.isEmpty
                ? "HomeKit is connected, but no rooms with controllable lights were found."
                : nil
        }
    }

    // MARK: Screenshot Demo Data

    private func loadScreenshotHome() {
        let livingRoom = Room(
            name: "Living Room",
            icon: "sofa.fill",
            lights: [
                Light(name: "Ceiling Halo", capability: .fullRGB),
                Light(name: "Window Wash", capability: .fullRGB),
                Light(name: "Media Strip", capability: .fullRGB),
                Light(name: "Reading Lamp", capability: .colorTemperature),
                Light(name: "Corner Glow", capability: .fullRGB),
                Light(name: "Shelf Spot", capability: .dimmableOnly)
            ]
        )

        let kitchen = Room(
            name: "Kitchen",
            icon: "fork.knife",
            lights: [
                Light(name: "Island Pendants", capability: .colorTemperature),
                Light(name: "Counter Strip", capability: .fullRGB),
                Light(name: "Dining Globe", capability: .colorTemperature),
                Light(name: "Cabinet Accent", capability: .fullRGB)
            ]
        )

        let bedroom = Room(
            name: "Bedroom",
            icon: "bed.double.fill",
            lights: [
                Light(name: "Bedside Left", capability: .fullRGB),
                Light(name: "Bedside Right", capability: .fullRGB),
                Light(name: "Wardrobe Wash", capability: .colorTemperature),
                Light(name: "Ceiling Soft", capability: .dimmableOnly),
                Light(name: "Window Glow", capability: .fullRGB)
            ]
        )

        let demoRooms = [livingRoom, kitchen, bedroom]
        rooms = demoRooms
        isAuthorized = true
        isLoading = false
        statusMessage = "Screenshot demo mode: premium unlocked with mock HomeKit rooms."
        lightBindings = [:]
        appliedMoods = [
            livingRoom.id: Mood(
                name: "Aurora Flow",
                description: "Premium Living Lights scene for App Store screenshots.",
                category: .livingLights,
                isPremium: true,
                style: .living,
                requiredCapability: .fullRGB,
                lightSetting: LightSetting(brightness: 0.62, hex: "#00E087"),
                lightSettings: [
                    LightSetting(brightness: 0.62, hex: "#00E087"),
                    LightSetting(brightness: 0.62, hex: "#6F35FF"),
                    LightSetting(brightness: 0.62, hex: "#7DE8FF")
                ],
                gradientColors: [ColorHex.color(from: "#00E087"), ColorHex.color(from: "#6F35FF")]
            ),
            kitchen.id: Mood(
                name: "Golden Hour Studio",
                description: "Warm premium lighting for a polished kitchen scene.",
                category: .productivity,
                isPremium: true,
                requiredCapability: .fullRGB,
                lightSetting: LightSetting(brightness: 0.74, hex: "#FFB347"),
                lightSettings: [
                    LightSetting(brightness: 0.74, hex: "#FFB347"),
                    LightSetting(brightness: 0.74, hex: "#FFD6A5"),
                    LightSetting(brightness: 0.74, hex: "#FFF1CF")
                ],
                gradientColors: [ColorHex.color(from: "#FFB347"), ColorHex.color(from: "#FFD6A5")]
            )
        ]
    }

    // MARK: Scene Application

    func applyMood(_ mood: Mood, to room: Room) {
        appliedMoods[room.id] = mood

        for (index, light) in room.lights.enumerated() {
            guard
                let binding = lightBindings[light.id],
                let home = hmManager?.homes.first(where: { $0.uniqueIdentifier == binding.homeID }),
                let accessory = home.accessories.first(where: { $0.uniqueIdentifier == binding.accessoryID }),
                let service = accessory.services.first(where: { $0.uniqueIdentifier == binding.serviceID })
            else { continue }

            let setting = mood.lightSettings[index % mood.lightSettings.count]
            apply(setting, to: service, capability: light.capability)
        }
    }

    func turnOffLights(in room: Room) {
        appliedMoods[room.id] = nil

        for light in room.lights {
            setPower(false, for: light.id)
        }
    }

    func currentMood(for room: Room) -> Mood? { appliedMoods[room.id] }

    func setPower(_ isOn: Bool, for lightID: UUID) {
        guard let service = service(for: lightID) else { return }
        write(isOn, to: HMCharacteristicTypePowerState, in: service)
    }

    func setBrightness(_ brightness: Double, for lightID: UUID) {
        guard let service = service(for: lightID) else { return }
        write(Int(brightness * 100), to: HMCharacteristicTypeBrightness, in: service)
    }

    func setColor(_ color: Color, for lightID: UUID) {
        guard let service = service(for: lightID), let hs = color.hueSaturationBrightness else { return }
        write(true, to: HMCharacteristicTypePowerState, in: service)
        write(hs.hue * 360, to: HMCharacteristicTypeHue, in: service)
        write(hs.saturation * 100, to: HMCharacteristicTypeSaturation, in: service)
        write(Int(hs.brightness * 100), to: HMCharacteristicTypeBrightness, in: service)
    }

    func applyToAllLights(brightness: Double, color: Color) {
        for light in controllableLights {
            setBrightness(brightness, for: light.id)
            if light.capability == .fullRGB {
                setColor(color, for: light.id)
            }
        }
    }

    // MARK: HomeKit Delegate

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        refreshAuthorizationState(from: manager)
        if manager.authorizationStatus.contains(.authorized) {
            loadHomeKitRooms(from: manager)
        }
    }

    func homeManager(_ manager: HMHomeManager, didUpdate status: HMHomeManagerAuthorizationStatus) {
        refreshAuthorizationState(from: manager)
        if status.contains(.authorized) {
            loadHomeKitRooms(from: manager)
        }
    }

    // MARK: HomeKit Helpers

    private func service(for lightID: UUID) -> HMService? {
        guard
            let binding = lightBindings[lightID],
            let home = hmManager?.homes.first(where: { $0.uniqueIdentifier == binding.homeID }),
            let accessory = home.accessories.first(where: { $0.uniqueIdentifier == binding.accessoryID })
        else { return nil }

        return accessory.services.first(where: { $0.uniqueIdentifier == binding.serviceID })
    }

    private func apply(_ setting: LightSetting, to service: HMService, capability: LightCapability) {
        write(true, to: HMCharacteristicTypePowerState, in: service)
        write(Int(setting.brightness * 100), to: HMCharacteristicTypeBrightness, in: service)

        if capability == .fullRGB, let hue = setting.hue, let saturation = setting.saturation {
            write(hue, to: HMCharacteristicTypeHue, in: service)
            write(saturation * 100, to: HMCharacteristicTypeSaturation, in: service)
        } else if capability.capabilityLevel >= LightCapability.colorTemperature.capabilityLevel,
                  let kelvin = setting.colorTemperatureKelvin {
            write(kelvinToMired(kelvin), to: HMCharacteristicTypeColorTemperature, in: service)
        }
    }

    private func write(_ value: Any, to characteristicType: String, in service: HMService) {
        guard let characteristic = service.characteristics.first(where: { $0.characteristicType == characteristicType }) else {
            return
        }

        characteristic.writeValue(value) { error in
            if let error {
                print("HomeKit write failed for \(characteristicType): \(error.localizedDescription)")
            }
        }
    }

    private func capability(for service: HMService) -> LightCapability {
        let characteristicTypes = Set(service.characteristics.map(\.characteristicType))
        if characteristicTypes.contains(HMCharacteristicTypeHue),
           characteristicTypes.contains(HMCharacteristicTypeSaturation) {
            return .fullRGB
        }
        if characteristicTypes.contains(HMCharacteristicTypeColorTemperature) {
            return .colorTemperature
        }
        return .dimmableOnly
    }

    private func displayName(for service: HMService, accessory: HMAccessory) -> String {
        guard !service.name.isEmpty, service.name != accessory.name else { return accessory.name }
        return "\(accessory.name) \(service.name)"
    }

    private func iconName(for roomName: String) -> String {
        let name = roomName.lowercased()
        if name.contains("bed") { return "bed.double.fill" }
        if name.contains("office") || name.contains("study") { return "desktopcomputer" }
        if name.contains("kitchen") { return "fork.knife" }
        if name.contains("bath") { return "shower.fill" }
        if name.contains("living") || name.contains("lounge") { return "sofa.fill" }
        return "house.fill"
    }

    private func kelvinToMired(_ kelvin: Int) -> Int {
        let safeKelvin = min(max(kelvin, 2_000), 6_500)
        return 1_000_000 / safeKelvin
    }
}

// ============================================================
// MARK: - § 5  MOOD ENGINE  (Dynamic Suggestion Generator)
// ============================================================
// Algorithm:
//   1. Read room.dominantCapability  →  selects the generation branch.
//   2. Each branch creates moods tuned to the hardware's colour range.
//   3. interleave() shuffles the result across categories for visual variety.

enum MoodEngine {

    static func generateSuggestions(for room: Room, isProUnlocked: Bool) -> [Mood] {
        guard isProUnlocked else { return lockedSuggestionPlaceholders(for: room) }

        let moods: [Mood]
        switch room.dominantCapability {
        case .fullRGB:          moods = rgbMoods(for: room)
        case .colorTemperature: moods = colorTempMoods(for: room)
        case .dimmableOnly:     moods = dimmableMoods(for: room)
        }
        return interleaved(moods)
    }

    private static func lockedSuggestionPlaceholders(for room: Room) -> [Mood] {
        MoodCategory.allCases.prefix(3).map { category in
            Mood(
                name: Strings.lockedProSuggestion,
                description: Strings.lockedProSuggestionDesc,
                category: category,
                isGenerated: true,
                isLocked: true,
                requiredCapability: room.dominantCapability,
                lightSetting: LightSetting(brightness: 0.50),
                gradientColors: category.gradientColors
            )
        }
    }

    // MARK: Full RGB — vibrant, colourful scenes

    private static func rgbMoods(for room: Room) -> [Mood] { [
        Mood(
            name: "Nordic Aurora",
            description: "Breathtaking greens and purples inspired by the Finnish aurora borealis.",
            category: .nature,
            isGenerated: true,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.60, hue: 148, saturation: 0.85),
            gradientColors: [Color(red: 0.18, green: 0.74, blue: 0.52), Color(red: 0.44, green: 0.22, blue: 0.70)]
        ),
        Mood(
            name: "Amber Focus",
            description: "Warm amber tones to keep you alert, engaged, and energised.",
            category: .productivity,
            isGenerated: true,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.90, hue: 38, saturation: 0.65),
            gradientColors: [Color(red: 0.96, green: 0.76, blue: 0.28), Color(red: 0.86, green: 0.54, blue: 0.14)]
        ),
        Mood(
            name: "Deep Dusk",
            description: "Rich indigo and midnight blue for cinematic entertainment sessions.",
            category: .entertainment,
            isGenerated: true,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.35, hue: 232, saturation: 0.92),
            gradientColors: [Color(red: 0.14, green: 0.18, blue: 0.56), Color(red: 0.24, green: 0.09, blue: 0.40)]
        ),
        Mood(
            name: "Midsommar",
            description: "Golden Scandinavian midsummer light — warm, languid, and hopeful.",
            category: .relaxation,
            isGenerated: true,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.70, hue: 46, saturation: 0.55),
            gradientColors: [Color(red: 0.99, green: 0.86, blue: 0.48), Color(red: 0.96, green: 0.67, blue: 0.28)]
        ),
        Mood(
            name: "Arctic Morning",
            description: "Crisp pale-blue sky of a Finnish winter dawn. Energising and pure.",
            category: .nature,
            isGenerated: true,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.78, hue: 210, saturation: 0.40),
            gradientColors: [Color(red: 0.74, green: 0.88, blue: 0.98), Color(red: 0.54, green: 0.74, blue: 0.92)]
        ),
        Mood(
            name: "Ember Lounge",
            description: "Soft, flickering warmth like a crackling fireplace. Perfect for unwinding.",
            category: .relaxation,
            isGenerated: true,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.45, hue: 24, saturation: 0.82),
            gradientColors: [Color(red: 0.96, green: 0.44, blue: 0.14), Color(red: 0.74, green: 0.24, blue: 0.08)]
        ),
    ] }

    // MARK: Color Temperature — natural white tones

    private static func colorTempMoods(for room: Room) -> [Mood] { [
        Mood(
            name: "Nordic Focus",
            description: "Crisp neutral-white light (5000 K) for maximum concentration.",
            category: .productivity,
            isGenerated: true,
            requiredCapability: .colorTemperature,
            lightSetting: LightSetting(brightness: 0.95, colorTemperatureKelvin: 5_000),
            gradientColors: [Color(red: 0.90, green: 0.95, blue: 1.00), Color(red: 0.75, green: 0.87, blue: 0.98)]
        ),
        Mood(
            name: "Hygge Evening",
            description: "The warmest possible glow (2700 K) for true Finnish cosiness.",
            category: .relaxation,
            isGenerated: true,
            requiredCapability: .colorTemperature,
            lightSetting: LightSetting(brightness: 0.42, colorTemperatureKelvin: 2_700),
            gradientColors: [Color(red: 0.98, green: 0.86, blue: 0.58), Color(red: 0.92, green: 0.67, blue: 0.36)]
        ),
        Mood(
            name: "Soft Morning",
            description: "Gentle warm light (3500 K) that eases you into the day.",
            category: .nature,
            isGenerated: true,
            requiredCapability: .colorTemperature,
            lightSetting: LightSetting(brightness: 0.65, colorTemperatureKelvin: 3_500),
            gradientColors: [Color(red: 0.99, green: 0.90, blue: 0.70), Color(red: 0.95, green: 0.78, blue: 0.52)]
        ),
        Mood(
            name: "Cinema Ready",
            description: "Low, warm ambience (3000 K) that won't strain your eyes during a film.",
            category: .entertainment,
            isGenerated: true,
            requiredCapability: .colorTemperature,
            lightSetting: LightSetting(brightness: 0.25, colorTemperatureKelvin: 3_000),
            gradientColors: [Color(red: 0.42, green: 0.30, blue: 0.18), Color(red: 0.24, green: 0.17, blue: 0.10)]
        ),
    ] }

    // MARK: Dimmable Only — brightness-based scenes

    private static func dimmableMoods(for room: Room) -> [Mood] { [
        Mood(
            name: "Full Bright",
            description: "Maximum brightness for tasks that demand clear vision.",
            category: .productivity,
            isGenerated: true,
            requiredCapability: .dimmableOnly,
            lightSetting: LightSetting(brightness: 1.00),
            gradientColors: [Color(white: 0.96), Color(white: 0.86)]
        ),
        Mood(
            name: "Soft Dim",
            description: "Gentle reduced brightness for calm evening unwinding.",
            category: .relaxation,
            isGenerated: true,
            requiredCapability: .dimmableOnly,
            lightSetting: LightSetting(brightness: 0.30),
            gradientColors: [Color(white: 0.65), Color(white: 0.44)]
        ),
        Mood(
            name: "Night Mode",
            description: "Minimal brightness to navigate safely without disturbing sleep.",
            category: .relaxation,
            isGenerated: true,
            requiredCapability: .dimmableOnly,
            lightSetting: LightSetting(brightness: 0.10),
            gradientColors: [Color(white: 0.34), Color(white: 0.20)]
        ),
    ] }

    // MARK: Interleave across categories for variety

    private static func interleaved(_ moods: [Mood]) -> [Mood] {
        var byCategory: [MoodCategory: [Mood]] = [:]
        moods.forEach { byCategory[$0.category, default: []].append($0) }
        var queues = Array(byCategory.values)
        var result: [Mood] = []
        while queues.contains(where: { !$0.isEmpty }) {
            for i in queues.indices where !queues[i].isEmpty {
                result.append(queues[i].removeFirst())
            }
        }
        return result
    }
}

// ============================================================
// MARK: - § 6  SCENE LIBRARY  (Static Preset Moods)
// ============================================================

enum SceneLibrary {

    /// Returns all compatible presets grouped by category for a given room.
    static func presets(compatibleWith room: Room, style: MoodStyle? = nil) -> [MoodCategory: [Mood]] {
        let level = room.dominantCapability.capabilityLevel
        var result: [MoodCategory: [Mood]] = [:]
        for category in MoodCategory.allCases {
            let filtered = (allPresets + PremiumMoodLibrary.moods).filter {
                $0.category == category &&
                (style == nil || $0.style == style) &&
                $0.requiredCapability.capabilityLevel <= level
            }
            if !filtered.isEmpty { result[category] = filtered }
        }
        return result
    }

    // MARK: Preset definitions

    private static let allPresets: [Mood] = [

        // ── PRODUCTIVITY ──────────────────────────────────────

        Mood(
            name: "Reading Mode",
            description: "Clean 4000 K light that reduces eye strain during extended reading.",
            category: .productivity,
            requiredCapability: .dimmableOnly,
            lightSetting: LightSetting(brightness: 0.85, colorTemperatureKelvin: 4_000)
        ),
        Mood(
            name: "Deep Work",
            description: "High-intensity cool white (5500 K) to signal your brain it's focus time.",
            category: .productivity,
            requiredCapability: .colorTemperature,
            lightSetting: LightSetting(brightness: 1.00, colorTemperatureKelvin: 5_500),
            gradientColors: [Color(red: 0.85, green: 0.93, blue: 1.00), Color(red: 0.65, green: 0.80, blue: 0.98)]
        ),
        Mood(
            name: "Creative Flow",
            description: "Soft amber hues proven to encourage lateral thinking and creative insight.",
            category: .productivity,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.75, hue: 42, saturation: 0.50),
            gradientColors: [Color(red: 0.97, green: 0.80, blue: 0.44), Color(red: 0.88, green: 0.62, blue: 0.24)]
        ),

        // ── RELAXATION ────────────────────────────────────────

        Mood(
            name: "Sauna Warmth",
            description: "Extremely warm, low light (2200 K) inspired by the Finnish sauna tradition.",
            category: .relaxation,
            requiredCapability: .colorTemperature,
            lightSetting: LightSetting(brightness: 0.30, colorTemperatureKelvin: 2_200),
            gradientColors: [Color(red: 0.96, green: 0.72, blue: 0.36), Color(red: 0.80, green: 0.44, blue: 0.14)]
        ),
        Mood(
            name: "Sunset Unwind",
            description: "Mimics the slow fade of a Nordic sunset for natural decompression.",
            category: .relaxation,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.55, hue: 22, saturation: 0.76),
            gradientColors: [Color(red: 0.97, green: 0.54, blue: 0.24), Color(red: 0.85, green: 0.34, blue: 0.14)]
        ),
        Mood(
            name: "Slumber Prep",
            description: "Minimal warm light to naturally trigger melatonin production before sleep.",
            category: .relaxation,
            requiredCapability: .dimmableOnly,
            lightSetting: LightSetting(brightness: 0.15)
        ),

        // ── ENTERTAINMENT ──────────────────────────────────────

        Mood(
            name: "Movie Night",
            description: "Dim, bias-friendly lighting that complements your screen without glare.",
            category: .entertainment,
            requiredCapability: .dimmableOnly,
            lightSetting: LightSetting(brightness: 0.20)
        ),
        Mood(
            name: "Game Mode",
            description: "Dynamic blue-purple ambience for immersive gaming sessions.",
            category: .entertainment,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.50, hue: 262, saturation: 0.90),
            gradientColors: [Color(red: 0.38, green: 0.18, blue: 0.86), Color(red: 0.24, green: 0.09, blue: 0.64)]
        ),
        Mood(
            name: "Party Mode",
            description: "Vibrant, saturated colour for celebrations. Every RGB light earns its keep.",
            category: .entertainment,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.82, hue: 322, saturation: 0.96),
            gradientColors: [Color(red: 0.90, green: 0.28, blue: 0.70), Color(red: 0.58, green: 0.14, blue: 0.86)]
        ),

        // ── NATURE ────────────────────────────────────────────

        Mood(
            name: "Forest Retreat",
            description: "Gentle greens that bring the tranquillity of Nordic pine forests indoors.",
            category: .nature,
            requiredCapability: .fullRGB,
            lightSetting: LightSetting(brightness: 0.60, hue: 124, saturation: 0.62),
            gradientColors: [Color(red: 0.28, green: 0.64, blue: 0.38), Color(red: 0.16, green: 0.46, blue: 0.26)]
        ),
        Mood(
            name: "Arctic Sky",
            description: "The pale-blue clarity of a cloudless Lapland winter sky. (6200 K)",
            category: .nature,
            requiredCapability: .colorTemperature,
            lightSetting: LightSetting(brightness: 0.82, colorTemperatureKelvin: 6_200),
            gradientColors: [Color(red: 0.70, green: 0.88, blue: 0.99), Color(red: 0.50, green: 0.74, blue: 0.95)]
        ),
        Mood(
            name: "Birchwood Dawn",
            description: "Soft neutral-warm light (3800 K) filtering through birch trees at dawn.",
            category: .nature,
            requiredCapability: .colorTemperature,
            lightSetting: LightSetting(brightness: 0.55, colorTemperatureKelvin: 3_800),
            gradientColors: [Color(red: 0.97, green: 0.92, blue: 0.78), Color(red: 0.88, green: 0.80, blue: 0.60)]
        ),
    ]
}

// ============================================================
// MARK: - § 7  VIEWS
// ============================================================

// ── 8a  Content View ─────────────────────────────────────────

enum AppFlowState {
    case launchScreen
    case coreApp
}

struct ContentView: View {
    @EnvironmentObject var homeKit: HomeKitManager
    @State private var flowState: AppFlowState = AppScreenshotMode.isEnabled ? .coreApp : .launchScreen

    var body: some View {
        Group {
            switch flowState {
            case .launchScreen:
                AuthorizationView(flowState: $flowState)
            case .coreApp:
                MainTabView(flowState: $flowState)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: flowState)
        .task {
            homeKit.connectToHomeKit()
        }
    }
}

struct MainTabView: View {
    @Binding var flowState: AppFlowState

    var body: some View {
        TabView {
            DashboardView(flowState: $flowState)
                .tabItem { Label("Home", systemImage: "house.fill") }

            IndividualLightControlView()
                .tabItem { Label("Lights", systemImage: "lightbulb.2.fill") }

            SoundSyncView()
                .tabItem { Label("Sound", systemImage: "waveform") }
        }
    }
}

// ── 8b  Authorization View ───────────────────────────────────

struct AuthorizationView: View {
    @EnvironmentObject var homeKit: HomeKitManager
    @Binding var flowState: AppFlowState

    var body: some View {
        ZStack {
            AuraColor.background.ignoresSafeArea()

            VStack(spacing: AuraSpacing.xl) {
                Spacer()

                // Logotype
                VStack(spacing: AuraSpacing.md) {
                    Image("MyValoLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: AuraRadius.lg))
                        .shadow(color: AuraColor.cardShadow, radius: 12, x: 0, y: 4)

                    Text(Strings.appName)
                        .font(AuraFont.display(44))
                        .foregroundColor(AuraColor.textPrimary)
                        .kerning(-0.5)

                    Text(Strings.appTagline)
                        .font(AuraFont.body(14))
                        .foregroundColor(AuraColor.textSecondary)
                        .kerning(2.0)
                        .textCase(.uppercase)
                }

                Spacer()

                // Permission card
                VStack(spacing: AuraSpacing.lg) {
                    VStack(spacing: AuraSpacing.sm) {
                        Text(Strings.homeAccessTitle)
                            .font(AuraFont.title(20))
                            .foregroundColor(AuraColor.textPrimary)
                        Text(Strings.homeAccessDesc)
                            .font(AuraFont.body(15))
                            .foregroundColor(AuraColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    if let statusMessage = homeKit.statusMessage {
                        Text(statusMessage)
                            .font(AuraFont.body(13))
                            .foregroundColor(AuraColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        homeKit.requestAuthorization()
                        flowState = .coreApp
                    } label: {
                        HStack(spacing: AuraSpacing.sm) {
                            if homeKit.isLoading {
                                ProgressView().tint(.white).scaleEffect(0.85)
                            } else {
                                Image(systemName: "house.fill")
                            }
                            Text(homeKit.isLoading ? Strings.connecting : Strings.connectToHome)
                                .font(AuraFont.caption(16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AuraSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AuraRadius.sm)
                                .fill(AuraColor.textPrimary)
                        )
                    }
                    .disabled(false)
                }
                .auraCard(padding: AuraSpacing.lg)
                .padding(.horizontal, AuraSpacing.lg)

                Spacer().frame(height: AuraSpacing.xxl)
            }
        }
    }
}

// ── 8c  Dashboard View ───────────────────────────────────────

struct DashboardView: View {
    @EnvironmentObject var homeKit: HomeKitManager
    @EnvironmentObject var storeManager: StoreManager
    @Binding var flowState: AppFlowState
    @State private var showingPaywall = false
    @State private var showingProfile = false

    private var visibleRooms: [Room] {
        storeManager.isProUnlocked ? homeKit.rooms : Array(homeKit.rooms.prefix(2))
    }

    private var lockedRoomCount: Int {
        storeManager.isProUnlocked ? 0 : max(homeKit.rooms.count - visibleRooms.count, 0)
    }

    private let columns = [
        GridItem(.flexible(), spacing: AuraSpacing.md),
        GridItem(.flexible(), spacing: AuraSpacing.md),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AuraColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AuraSpacing.xl) {

                        // ── Header
                        DashboardHeaderView {
                            showingProfile = true
                        }
                        .padding(.horizontal, AuraSpacing.lg)
                        .padding(.top, AuraSpacing.sm)

                        if !storeManager.isProUnlocked {
                            GoPremiumBanner {
                                showingPaywall = true
                            }
                            .padding(.horizontal, AuraSpacing.lg)
                        }

                        // ── Room grid
                        VStack(alignment: .leading, spacing: AuraSpacing.md) {
                            HStack {
                                Text(Strings.rooms)
                                    .font(AuraFont.caption(12))
                                    .foregroundColor(AuraColor.textTertiary)
                                    .kerning(1.8)
                                    .textCase(.uppercase)

                                Spacer()

                                Button { homeKit.refreshHomes() } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AuraColor.textSecondary)
                                        .frame(width: 32, height: 32)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Refresh HomeKit rooms")
                            }
                            .padding(.horizontal, AuraSpacing.lg)

                            if let statusMessage = homeKit.statusMessage {
                                Text(statusMessage)
                                    .font(AuraFont.body(13))
                                    .foregroundColor(AuraColor.textSecondary)
                                    .padding(.horizontal, AuraSpacing.lg)
                            }

                            LazyVGrid(columns: columns, spacing: AuraSpacing.md) {
                                ForEach(visibleRooms) { room in
                                    NavigationLink {
                                        RoomDetailView(room: room)
                                    } label: {
                                        RoomCardView(
                                            room: room,
                                            appliedMood: homeKit.currentMood(for: room)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }

                                if lockedRoomCount > 0 {
                                    LockedRoomsCard(hiddenRoomCount: lockedRoomCount) {
                                        showingPaywall = true
                                    }
                                }
                            }
                            .padding(.horizontal, AuraSpacing.lg)
                        }

                        Spacer(minLength: AuraSpacing.xxl)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(storeManager)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileSheetView(flowState: $flowState)
                    .environmentObject(homeKit)
                    .environmentObject(storeManager)
            }
        }
    }
}

// ── 8d  Dashboard Header ─────────────────────────────────────

struct DashboardHeaderView: View {
    @EnvironmentObject var homeKit: HomeKitManager
    let onProfileTap: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AuraSpacing.xs) {
                Text(Strings.homeTitle)
                    .font(AuraFont.display(34))
                    .foregroundColor(AuraColor.textPrimary)
                    .kerning(-0.5)
                Text("\(homeKit.rooms.count) \(Strings.rooms.lowercased()) · \(homeKit.totalLightCount) \(Strings.lights)")
                    .font(AuraFont.body(14))
                    .foregroundColor(AuraColor.textSecondary)
            }
            Spacer()
            Button(action: onProfileTap) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(AuraColor.textSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile")
        }
    }
}

struct ProfileSheetView: View {
    @EnvironmentObject var homeKit: HomeKitManager
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    @Binding var flowState: AppFlowState
    @State private var showingPaywall = false

    private var favoriteMoodNames: [String] {
        homeKit.favoriteMoodNames.sorted()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AuraColor.background.ignoresSafeArea()

                List {
                    if !storeManager.isProUnlocked {
                        Section {
                            GoPremiumBanner {
                                showingPaywall = true
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                        }
                    }

                    Section("Home") {
                        Label("\(homeKit.totalLightCount) total lights", systemImage: "lightbulb.2.fill")
                        Label("\(homeKit.rooms.count) rooms", systemImage: "house.fill")
                    }

                    Section("Favorite Moods") {
                        if favoriteMoodNames.isEmpty {
                            Text("No favorite moods saved yet")
                                .foregroundColor(AuraColor.textSecondary)
                        } else {
                            ForEach(favoriteMoodNames, id: \.self) { moodName in
                                Label(moodName, systemImage: "star.fill")
                            }
                        }
                    }

                    Section {
                        Button("Return to Launch Screen") {
                            dismiss()
                            flowState = .launchScreen
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
    }
}

// ── 8e  Room Card View ───────────────────────────────────────

struct RoomCardView: View {
    let room: Room
    let appliedMood: Mood?

    private var isTinted: Bool { appliedMood != nil }

    private var cardGradient: LinearGradient {
        if let mood = appliedMood {
            return LinearGradient(colors: mood.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [AuraColor.surface, AuraColor.surface], startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AuraSpacing.sm) {
            HStack {
                Image(systemName: room.icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(isTinted ? .white.opacity(0.90) : AuraColor.textSecondary)
                Spacer()
                // Light count badge
                Text("\(room.lightCount)")
                    .font(AuraFont.caption(13))
                    .foregroundColor(isTinted ? .white.opacity(0.80) : AuraColor.textTertiary)
                    .padding(.horizontal, AuraSpacing.sm)
                    .padding(.vertical, AuraSpacing.xs)
                    .background(Capsule().fill(isTinted ? Color.white.opacity(0.20) : AuraColor.background))
            }

            Spacer()

            VStack(alignment: .leading, spacing: AuraSpacing.xs) {
                Text(room.name)
                    .font(AuraFont.title(16))
                    .foregroundColor(isTinted ? .white : AuraColor.textPrimary)
                    .lineLimit(1)

                if let mood = appliedMood {
                    Text(mood.name)
                        .font(AuraFont.body(12))
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(1)
                } else {
                    CapabilityBadgesView(room: room)
                }
            }
        }
        .frame(height: 145)
        .padding(AuraSpacing.md)
        .background(RoundedRectangle(cornerRadius: AuraRadius.md).fill(cardGradient))
        .overlay(
            RoundedRectangle(cornerRadius: AuraRadius.md)
                .strokeBorder(isTinted ? Color.clear : AuraColor.divider, lineWidth: 1)
        )
        .shadow(
            color: isTinted ? (appliedMood?.gradientColors[0].opacity(0.35) ?? AuraColor.cardShadow) : AuraColor.cardShadow,
            radius: 14, x: 0, y: 6
        )
    }
}

// ── 8f  Capability Badges ─────────────────────────────────────

struct CapabilityBadgesView: View {
    let room: Room

    var body: some View {
        HStack(spacing: AuraSpacing.xs) {
            ForEach(LightCapability.allCases) { cap in
                let count = room.capabilityBreakdown[cap] ?? 0
                if count > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: cap.icon).font(.system(size: 9, weight: .medium))
                        Text("\(count)").font(AuraFont.caption(10))
                    }
                    .foregroundColor(cap.tint)
                    .padding(.horizontal, 6).padding(.vertical, 3)
                    .background(Capsule().fill(cap.tint.opacity(0.12)))
                }
            }
        }
    }
}

// ── 8g  Room Detail View ─────────────────────────────────────

private enum MoodBrowseMode: String, CaseIterable, Identifiable {
    case still
    case moving

    var id: String { rawValue }

    var title: String {
        switch self {
        case .still: return "Still Lights"
        case .moving: return "Moving Lights"
        }
    }
}

struct RoomDetailView: View {
    @EnvironmentObject var homeKit: HomeKitManager
    @EnvironmentObject var storeManager: StoreManager
    let room: Room

    @State private var selectedMood: Mood?
    @State private var showingPaywall = false
    @State private var browseMode: MoodBrowseMode = .still

    private var suggestions: [Mood] { MoodEngine.generateSuggestions(for: room, isProUnlocked: storeManager.isProUnlocked) }
    private var stillLibrary: [MoodCategory: [Mood]] { SceneLibrary.presets(compatibleWith: room, style: .still) }
    private var livingLibrary: [MoodCategory: [Mood]] { SceneLibrary.presets(compatibleWith: room, style: .living) }

    private func selectOrUpsell(_ mood: Mood) {
        if mood.isLocked || (mood.isPremium && !storeManager.isProUnlocked) {
            showingPaywall = true
        } else {
            selectedMood = mood
        }
    }

    var body: some View {
        ZStack {
            AuraColor.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AuraSpacing.xl) {

                    // Room hardware profile
                    RoomHardwareHeaderView(room: room)
                        .padding(.horizontal, AuraSpacing.lg)
                        .padding(.top, AuraSpacing.sm)

                    if !storeManager.isProUnlocked {
                        GoPremiumBanner {
                            showingPaywall = true
                        }
                        .padding(.horizontal, AuraSpacing.lg)
                    }

                    // Active scene banner
                    if let current = homeKit.currentMood(for: room) {
                        ActiveSceneBannerView(mood: current)
                            .padding(.horizontal, AuraSpacing.lg)
                    }

                    // Generated suggestions
                    SuggestionsSection(suggestions: suggestions, isProUnlocked: storeManager.isProUnlocked) { mood in
                        selectOrUpsell(mood)
                    }

                    if !room.hasRGB {
                        HardwareUpgradeBanner()
                            .padding(.horizontal, AuraSpacing.lg)
                    }

                    MoodBrowseModePicker(selection: $browseMode)
                        .padding(.horizontal, AuraSpacing.lg)

                    SmartLightsAffiliateBanner(
                        title: "Add more smart lights",
                        subtitle: "Shop bulbs that can show richer room moods."
                    )
                    .padding(.horizontal, AuraSpacing.lg)

                    if browseMode == .still {
                        PresetLibrarySection(
                            title: "Still Lights",
                            icon: "circle.grid.2x2.fill",
                            iconColor: AuraColor.textSecondary,
                            library: stillLibrary,
                            isProUnlocked: storeManager.isProUnlocked,
                            onSelect: selectOrUpsell
                        )
                    } else {
                        PresetLibrarySection(
                            title: "Moving Lights",
                            icon: "waveform.path.ecg",
                            iconColor: AuraColor.accent,
                            library: livingLibrary,
                            isProUnlocked: storeManager.isProUnlocked,
                            onSelect: selectOrUpsell
                        )
                    }

                    Spacer(minLength: AuraSpacing.xxl)
                }
            }
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(room.name).font(AuraFont.title(17)).foregroundColor(AuraColor.textPrimary)
            }
        }
        .sheet(item: $selectedMood) { mood in
            MoodDetailSheet(mood: mood, room: room) {
                homeKit.applyMood(mood, to: room)
                selectedMood = nil
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
    }
}

// ── 8h  Mood Browser Controls ─────────────────────────────────

private struct MoodBrowseModePicker: View {
    @Binding var selection: MoodBrowseMode

    var body: some View {
        VStack(alignment: .leading, spacing: AuraSpacing.sm) {
            SectionHeaderView(title: "Browse Moods", icon: "slider.horizontal.3", iconColor: AuraColor.textSecondary)

            Picker("Browse Moods", selection: $selection) {
                ForEach(MoodBrowseMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

// ── 8i  Room Hardware Header ──────────────────────────────────

struct RoomHardwareHeaderView: View {
    let room: Room

    var body: some View {
        HStack(spacing: AuraSpacing.sm) {
            ForEach(LightCapability.allCases) { cap in
                let count = room.capabilityBreakdown[cap] ?? 0
                if count > 0 {
                    HStack(spacing: AuraSpacing.sm) {
                        Image(systemName: cap.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(cap.tint)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(count) \(Strings.lights)")
                                .font(AuraFont.caption(12))
                                .foregroundColor(AuraColor.textPrimary)
                            Text(cap.displayName)
                                .font(AuraFont.body(11))
                                .foregroundColor(AuraColor.textSecondary)
                        }
                    }
                    .padding(AuraSpacing.sm)
                    .background(RoundedRectangle(cornerRadius: AuraRadius.sm).fill(cap.tint.opacity(0.08)))
                }
            }
        }
    }
}

// ── 8i  Active Scene Banner ───────────────────────────────────

struct ActiveSceneBannerView: View {
    let mood: Mood

    var body: some View {
        HStack(spacing: AuraSpacing.md) {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: mood.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.activeScene)
                    .font(AuraFont.caption(11))
                    .foregroundColor(AuraColor.textTertiary)
                    .textCase(.uppercase)
                    .kerning(1.2)
                Text(mood.name)
                    .font(AuraFont.title(16))
                    .foregroundColor(AuraColor.textPrimary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(AuraColor.accent)
        }
        .auraCard()
    }
}

// ── 8j  Suggestions Section (horizontal scroll) ───────────────

struct SuggestionsSection: View {
    let suggestions: [Mood]
    let isProUnlocked: Bool
    let onSelect: (Mood) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AuraSpacing.md) {
            SectionHeaderView(title: Strings.suggestions, icon: "wand.and.stars", iconColor: AuraColor.accent)
                .padding(.horizontal, AuraSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AuraSpacing.md) {
                    ForEach(suggestions) { mood in
                        MoodCardView(mood: mood, isProUnlocked: isProUnlocked)
                            .onTapGesture { onSelect(mood) }
                    }
                }
                .padding(.horizontal, AuraSpacing.lg)
                .padding(.vertical, AuraSpacing.xs)
            }
        }
    }
}

// ── 8k  Section Header ────────────────────────────────────────

struct SectionHeaderView: View {
    let title: String
    let icon: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: AuraSpacing.xs) {
            Image(systemName: icon).font(.system(size: 13, weight: .semibold)).foregroundColor(iconColor)
            Text(title)
                .font(AuraFont.caption(12))
                .foregroundColor(AuraColor.textTertiary)
                .kerning(1.5)
                .textCase(.uppercase)
        }
    }
}

// ── 8l  Mood Card View (horizontal list card) ─────────────────

struct MoodCardView: View {
    let mood: Mood
    var isProUnlocked = false

    private var isLockedForUser: Bool {
        mood.isLocked || (mood.isPremium && !isProUnlocked)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AuraSpacing.sm) {

            // Colour preview swatch
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: AuraRadius.sm)
                    .fill(LinearGradient(colors: mood.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 90)
                    .blur(radius: isLockedForUser ? 8 : 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: AuraRadius.sm)
                            .fill(isLockedForUser ? Color.white.opacity(0.20) : Color.clear)
                    )

                if isLockedForUser {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                if mood.isGenerated {
                    Text(isLockedForUser ? Strings.paywallTitle : Strings.suggestedMood)
                        .font(AuraFont.caption(10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Capsule().fill(Color.black.opacity(0.24)))
                        .padding(8)
                }
            }
            .frame(height: 90)
            .clipShape(RoundedRectangle(cornerRadius: AuraRadius.sm))

            VStack(alignment: .leading, spacing: 2) {
                Text(mood.name)
                    .font(AuraFont.title(15))
                    .foregroundColor(AuraColor.textPrimary)
                    .lineLimit(1)
                Text(mood.description)
                    .font(AuraFont.body(12))
                    .foregroundColor(AuraColor.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Image(systemName: mood.category.icon).font(.system(size: 10))
                    Text(mood.category.displayName).font(AuraFont.caption(11))
                }
                .foregroundColor(mood.gradientColors[0])
                .padding(.top, 2)
            }
        }
        .frame(width: 172)
        .auraCard(padding: AuraSpacing.sm)
        .shadow(color: mood.gradientColors[0].opacity(0.15), radius: 10, x: 0, y: 4)
    }
}

// ── 8m  Preset Library Section ────────────────────────────────

struct PresetLibrarySection: View {
    let title: String
    let icon: String
    let iconColor: Color
    let library: [MoodCategory: [Mood]]
    let isProUnlocked: Bool
    let onSelect: (Mood) -> Void

    private var orderedCategories: [MoodCategory] {
        MoodCategory.allCases.filter { library[$0] != nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AuraSpacing.lg) {
            SectionHeaderView(title: title, icon: icon, iconColor: iconColor)
                .padding(.horizontal, AuraSpacing.lg)

            ForEach(orderedCategories) { category in
                CategorySection(
                    category: category,
                    moods: library[category] ?? [],
                    isProUnlocked: isProUnlocked,
                    onSelect: onSelect
                )
            }
        }
    }
}

// ── 8n  Category Section ──────────────────────────────────────

struct CategorySection: View {
    let category: MoodCategory
    let moods: [Mood]
    let isProUnlocked: Bool
    let onSelect: (Mood) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AuraSpacing.sm) {
            // Category header pill
            HStack(spacing: AuraSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(LinearGradient(colors: category.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 28, height: 28)
                    Image(systemName: category.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text(category.displayName)
                    .font(AuraFont.title(16))
                    .foregroundColor(AuraColor.textPrimary)
            }
            .padding(.horizontal, AuraSpacing.lg)

            VStack(spacing: AuraSpacing.sm) {
                ForEach(moods) { mood in
                    LibraryRowView(mood: mood, isProUnlocked: isProUnlocked)
                        .padding(.horizontal, AuraSpacing.lg)
                        .onTapGesture { onSelect(mood) }
                }
            }
        }
    }
}

// ── 8o  Library Row View ──────────────────────────────────────

struct LibraryRowView: View {
    let mood: Mood
    var isProUnlocked = false

    private var isLockedForUser: Bool {
        mood.isLocked || (mood.isPremium && !isProUnlocked)
    }

    var body: some View {
        HStack(spacing: AuraSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: mood.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                    .blur(radius: isLockedForUser ? 5 : 0)

                if isLockedForUser {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text(mood.name)
                    .font(AuraFont.title(15))
                    .foregroundColor(AuraColor.textPrimary)
                Text(mood.description)
                    .font(AuraFont.body(13))
                    .foregroundColor(AuraColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: isLockedForUser ? "lock.fill" : "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isLockedForUser ? AuraColor.accent : AuraColor.textTertiary)
        }
        .auraCard(padding: AuraSpacing.sm)
    }
}

// ── 8p  Mood Detail Sheet ─────────────────────────────────────

struct MoodDetailSheet: View {
    @EnvironmentObject var homeKit: HomeKitManager

    let mood: Mood
    let room: Room
    let onApply: () -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var livingAnimator = LivingLightAnimator()
    @State private var applied = false

    private var compatibleLightCount: Int {
        room.lights.filter {
            $0.capability.capabilityLevel >= mood.requiredCapability.capabilityLevel
        }.count
    }

    var body: some View {
        ZStack {
            AuraColor.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Gradient hero
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: mood.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(height: 230)
                        .ignoresSafeArea(edges: .top)

                    Button {
                        homeKit.toggleFavorite(mood)
                    } label: {
                        Image(systemName: homeKit.isFavorite(mood) ? "star.fill" : "star")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.black.opacity(0.22)))
                    }
                    .accessibilityLabel(homeKit.isFavorite(mood) ? "Remove favorite mood" : "Save favorite mood")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(AuraSpacing.lg)

                    VStack(alignment: .leading, spacing: AuraSpacing.sm) {
                        if mood.isGenerated {
                            Text(Strings.suggestedMood)
                                .font(AuraFont.caption(11))
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Capsule().fill(Color.white.opacity(0.22)))
                        }
                        Text(mood.name)
                            .font(AuraFont.display(32))
                            .foregroundColor(.white)
                            .kerning(-0.5)
                        HStack(spacing: 4) {
                            Image(systemName: mood.category.icon)
                            Text(mood.category.displayName)
                        }
                        .font(AuraFont.body(14))
                        .foregroundColor(.white.opacity(0.78))
                    }
                    .padding(AuraSpacing.lg)
                }

                // ── Detail scroll area
                ScrollView {
                    VStack(alignment: .leading, spacing: AuraSpacing.lg) {

                        Text(mood.description)
                            .font(AuraFont.body(16))
                            .foregroundColor(AuraColor.textSecondary)
                            .lineSpacing(6)

                        // Settings chips
                        VStack(alignment: .leading, spacing: AuraSpacing.sm) {
                            Text(Strings.settingsHeader)
                                .font(AuraFont.caption(11))
                                .foregroundColor(AuraColor.textTertiary)
                                .kerning(1.5)

                            HStack(spacing: AuraSpacing.md) {
                                SettingChip(icon: "light.max",      label: "Brightness",
                                            value: "\(Int(mood.lightSetting.brightness * 100))%")
                                if let ct = mood.lightSetting.colorTemperatureKelvin {
                                    SettingChip(icon: "thermometer.sun", label: "Temperature", value: "\(ct) K")
                                }
                                if let h = mood.lightSetting.hue {
                                    SettingChip(icon: "paintpalette", label: "Hue", value: "\(Int(h))°")
                                }
                                if mood.style == .living {
                                    SettingChip(icon: "timer", label: "Movement", value: "\(Int(mood.animationInterval))s")
                                }
                            }
                        }

                        if mood.style == .living {
                            Button {
                                if livingAnimator.isRunning {
                                    livingAnimator.stop()
                                } else {
                                    livingAnimator.start(mood: mood, room: room, homeKit: homeKit)
                                }
                            } label: {
                                Label(
                                    livingAnimator.isRunning ? "Stop Living Animation" : "Start Living Animation",
                                    systemImage: livingAnimator.isRunning ? "pause.circle.fill" : "play.circle.fill"
                                )
                                .font(AuraFont.caption(15))
                            }
                        }

                        // Compatibility info
                        VStack(alignment: .leading, spacing: AuraSpacing.sm) {
                            Text(Strings.compatibleHeader)
                                .font(AuraFont.caption(11))
                                .foregroundColor(AuraColor.textTertiary)
                                .kerning(1.5)
                            Text(Strings.compatibleLights(compatibleLightCount, room.lightCount))
                                .font(AuraFont.body(15))
                                .foregroundColor(AuraColor.textPrimary)
                        }
                    }
                    .padding(AuraSpacing.lg)
                }

                // ── Apply button
                VStack {
                    Button {
                        withAnimation(.spring(response: 0.3)) { applied = true }
                        onApply()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) { dismiss() }
                    } label: {
                        HStack(spacing: AuraSpacing.sm) {
                            Image(systemName: applied ? "checkmark" : "light.max")
                            Text(applied ? Strings.applied : Strings.apply)
                                .font(AuraFont.caption(16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AuraSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AuraRadius.sm)
                                .fill(
                                    applied
                                        ? AnyShapeStyle(Color.green)
                                        : AnyShapeStyle(LinearGradient(colors: mood.gradientColors, startPoint: .leading, endPoint: .trailing))
                                )
                        )
                    }
                    .disabled(applied)
                    .animation(.easeInOut(duration: 0.25), value: applied)
                }
                .padding(AuraSpacing.lg)
                .background(AuraColor.background)
            }
        }
    }
}

// ── 8q  Setting Chip ─────────────────────────────────────────

struct SettingChip: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: AuraSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .light))
                .foregroundColor(AuraColor.accent)
            Text(value)
                .font(AuraFont.title(14))
                .foregroundColor(AuraColor.textPrimary)
            Text(label)
                .font(AuraFont.body(11))
                .foregroundColor(AuraColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(AuraSpacing.md)
        .background(RoundedRectangle(cornerRadius: AuraRadius.sm).fill(AuraColor.surface))
        .shadow(color: AuraColor.cardShadow, radius: 8, x: 0, y: 3)
    }
}

