import SwiftUI

@MainActor
enum PremiumMoodLibrary {
    static var moods: [Mood] {
        (specs + livingSpecs).map { spec in
            let settings = spec.colors.map { LightSetting(brightness: spec.brightness, hex: $0) }
            return Mood(
                name: spec.name,
                description: spec.description,
                category: spec.category,
                isPremium: true,
                style: spec.style,
                requiredCapability: .fullRGB,
                lightSetting: settings.first ?? LightSetting(brightness: spec.brightness),
                lightSettings: settings,
                gradientColors: spec.colors.map(ColorHex.color(from:))
            )
        }
    }

    private struct Spec {
        let name: String
        let description: String
        let category: MoodCategory
        let brightness: Double
        let colors: [String]
        var style: MoodStyle = .still
    }

    private static let specs: [Spec] = [
        Spec(name: "Aurora Cathedral", description: "Layered emerald, violet, and glacial blue beams for a dramatic northern-lights room wash.", category: .nature, brightness: 0.68, colors: ["#0DE37F", "#6F35FF", "#7DE8FF", "#17315C"]),
        Spec(name: "Cyberpunk Neon Lounge", description: "Electric cyan and hot magenta split across lamps for a high-contrast futuristic lounge.", category: .entertainment, brightness: 0.76, colors: ["#00F5FF", "#FF2BD6", "#7B2CFF", "#12122B"]),
        Spec(name: "Golden Hour Studio", description: "Warm amber, peach, and soft cream tones tuned for flattering creative work.", category: .productivity, brightness: 0.74, colors: ["#FFB347", "#FFD6A5", "#FFF1CF", "#E8873A"]),
        Spec(name: "Midnight Cinema", description: "Deep indigo bias light with low ruby accents for movie nights without glare.", category: .entertainment, brightness: 0.34, colors: ["#151A4F", "#2D145F", "#7E1E3A", "#090B18"]),
        Spec(name: "Rainforest Canopy", description: "Moss, fern, and humid blue-green shades that make separate lamps feel organic.", category: .nature, brightness: 0.58, colors: ["#1F8A4C", "#74C365", "#0F5B4C", "#A6E3A1"]),
        Spec(name: "Arctic Focus Grid", description: "Cool white and pale blue distributed evenly for crisp concentration.", category: .productivity, brightness: 0.90, colors: ["#F4FBFF", "#B7E4FF", "#D8F3FF", "#8FC7F7"]),
        Spec(name: "Velvet Speakeasy", description: "Dim burgundy, brass, and smoked amber for a private cocktail-bar atmosphere.", category: .relaxation, brightness: 0.42, colors: ["#5B1026", "#B8860B", "#D45D2A", "#2B1118"]),
        Spec(name: "Ocean Biolume", description: "Aquatic teal, sea blue, and glowing plankton green moving across fixtures.", category: .nature, brightness: 0.62, colors: ["#00C2A8", "#006DCC", "#7DFFB2", "#003049"]),
        Spec(name: "Sunset Gradient Room", description: "Coral, orange, pink, and violet mapped lamp by lamp like a fading horizon.", category: .relaxation, brightness: 0.64, colors: ["#FF6B3D", "#FFB000", "#FF5DA2", "#6C3BFF"]),
        Spec(name: "Deep Work Lab", description: "Precise cool whites with one alert amber accent for long focused sessions.", category: .productivity, brightness: 0.96, colors: ["#FFFFFF", "#D7F0FF", "#B7D8FF", "#FFCA5C"]),
        Spec(name: "Lunar Garden", description: "Moonlit blue, lavender, and soft sage for calm evening transitions.", category: .relaxation, brightness: 0.46, colors: ["#B8C8FF", "#C9A7FF", "#A8CFA3", "#EEF2FF"]),
        Spec(name: "Festival Pulse", description: "Saturated party colors split across all lamps for instant celebration energy.", category: .entertainment, brightness: 0.86, colors: ["#FF004D", "#00E5FF", "#FFE600", "#7CFF00"]),
        Spec(name: "Desert Modern", description: "Terracotta, sand, clay, and low sun tones for warm minimal interiors.", category: .relaxation, brightness: 0.55, colors: ["#C7653B", "#E8B071", "#F7D9A8", "#8F3D24"]),
        Spec(name: "Nordic Snowfield", description: "Clean white, ice blue, and faint silver tones that brighten without harshness.", category: .productivity, brightness: 0.88, colors: ["#FFFFFF", "#EAF7FF", "#CDEAFF", "#AAB9C8"]),
        Spec(name: "Volcanic Glow", description: "Charcoal shadows cut with ember red and molten orange for cinematic drama.", category: .entertainment, brightness: 0.48, colors: ["#1C1110", "#D7261E", "#FF6A00", "#FFB000"]),
        Spec(name: "Botanical Reading", description: "Balanced leaf green and warm white for a peaceful reading corner.", category: .productivity, brightness: 0.78, colors: ["#F4F1D0", "#A7C957", "#6A994E", "#FFF8E7"]),
        Spec(name: "Starlit Spa", description: "Low blue, lilac, and warm candlelight spread gently through the room.", category: .relaxation, brightness: 0.32, colors: ["#1F2A5A", "#9B8CFF", "#FFD6A5", "#3E2F5B"]),
        Spec(name: "Arcade Cabinet", description: "Retro red, cyan, violet, and gold for playful gaming energy.", category: .entertainment, brightness: 0.80, colors: ["#F72585", "#4CC9F0", "#7209B7", "#FFBE0B"]),
        Spec(name: "Coffeehouse Morning", description: "Cream, caramel, and roasted amber for a gentle productive start.", category: .productivity, brightness: 0.70, colors: ["#FFF0D6", "#D99A4E", "#8A4F2A", "#F6C27A"]),
        Spec(name: "Alpine Dawn", description: "Rose sunrise, pale blue, and snowy white for a fresh natural ambience.", category: .nature, brightness: 0.72, colors: ["#FFB3C1", "#BDE0FE", "#FFFFFF", "#A2D2FF"]),
        Spec(name: "Jungle Night", description: "Dark greens with distant warm firefly accents for immersive nature evenings.", category: .nature, brightness: 0.40, colors: ["#0B3D2E", "#1D6B4F", "#C9F227", "#102418"]),
        Spec(name: "Gallery White", description: "Subtle layered whites that make art, surfaces, and furniture read clearly.", category: .productivity, brightness: 0.92, colors: ["#FFFFFF", "#F5F3EA", "#E9EEF5", "#FFF8E1"]),
        Spec(name: "Plum Velvet", description: "Luxurious plum, mauve, and soft amber for quiet late-night lounging.", category: .relaxation, brightness: 0.44, colors: ["#4A154B", "#8E4585", "#D8A7CA", "#FFC857"]),
        Spec(name: "Cosmic Drift", description: "Nebula purple, star blue, and soft pink for a slow sci-fi ambience.", category: .entertainment, brightness: 0.58, colors: ["#3A0CA3", "#4361EE", "#F72585", "#B8C0FF"]),
        Spec(name: "Mediterranean Patio", description: "Sun-washed white, sea blue, and citrus yellow for breezy evenings.", category: .relaxation, brightness: 0.66, colors: ["#FFF8E7", "#0077B6", "#90E0EF", "#FFD166"]),
        Spec(name: "Greenhouse Focus", description: "Bright natural whites with chlorophyll greens for energetic daytime work.", category: .productivity, brightness: 0.84, colors: ["#F7FFF7", "#B7E4C7", "#52B788", "#D8F3DC"]),
        Spec(name: "Tokyo Rain", description: "Wet asphalt blue, signage pink, and reflected violet for rainy city mood.", category: .entertainment, brightness: 0.52, colors: ["#1B263B", "#E6399B", "#4CC9F0", "#5A189A"]),
        Spec(name: "Candlelit Dinner", description: "Layered flame tones with soft rose highlights for intimate dining.", category: .relaxation, brightness: 0.38, colors: ["#FFB347", "#FF7A3D", "#B23A48", "#FFF0C2"]),
        Spec(name: "Polar Night", description: "Blue-black calm with narrow aurora green accents for winter evenings.", category: .nature, brightness: 0.36, colors: ["#061A40", "#0353A4", "#00C853", "#B9FBC0"]),
        Spec(name: "Conference Clarity", description: "Even neutral whites and a low blue accent for video calls and meetings.", category: .productivity, brightness: 0.86, colors: ["#FFFFFF", "#F1F6FF", "#DDEBFF", "#9CC9FF"]),
        Spec(name: "Synthwave Drive", description: "Neon magenta, electric blue, and sunset orange for retro-future motion.", category: .entertainment, brightness: 0.78, colors: ["#FF00A8", "#00D9FF", "#FF6D00", "#2D00F7"]),
        Spec(name: "Sunday Reset", description: "Soft peach, cream, and desaturated blue for slow weekend decompression.", category: .relaxation, brightness: 0.50, colors: ["#FFD6A5", "#FDFFB6", "#CAFFBF", "#A0C4FF"]),
        Spec(name: "Lake Reflection", description: "Blue-green water tones with pale sky highlights across the room.", category: .nature, brightness: 0.60, colors: ["#2A9D8F", "#90E0EF", "#CAF0F8", "#264653"]),
        Spec(name: "Writer's Desk", description: "Warm key light with cool peripheral balance for deep writing sessions.", category: .productivity, brightness: 0.76, colors: ["#FFF1CF", "#FFD166", "#CDE7FF", "#F8F9FA"]),
        Spec(name: "Rose Quartz Calm", description: "Blush, quartz, and soft pearl tones for gentle relaxation.", category: .relaxation, brightness: 0.48, colors: ["#FFC8DD", "#FFAFCC", "#F8EDEB", "#E0BBE4"]),
        Spec(name: "Esports Arena", description: "High-energy team colors with cool blue anchor lighting for play sessions.", category: .entertainment, brightness: 0.84, colors: ["#00BBF9", "#F15BB5", "#FEE440", "#9B5DE5"]),
        Spec(name: "Forest Bathing", description: "Deep woodland greens and sunlit leaf yellow for restorative nature calm.", category: .nature, brightness: 0.52, colors: ["#31572C", "#4F772D", "#90A955", "#ECF39E"]),
        Spec(name: "Product Launch", description: "Bright, confident white and brand-like blue accents for presentation mode.", category: .productivity, brightness: 0.94, colors: ["#FFFFFF", "#E6F2FF", "#2F80ED", "#56CCF2"]),
        Spec(name: "Copper Library", description: "Antique copper, parchment, and shaded brown for a classic library mood.", category: .relaxation, brightness: 0.46, colors: ["#B87333", "#F4E1C1", "#7F5539", "#DDB892"]),
        Spec(name: "Hologram Room", description: "Pale cyan, mint, and spectral violet for clean futuristic ambience.", category: .entertainment, brightness: 0.70, colors: ["#B8F2E6", "#AED9E0", "#CDB4DB", "#FFFFFF"]),
        Spec(name: "Meadow Noon", description: "Grass green, sky blue, and clean sunlight for an open-air feeling.", category: .nature, brightness: 0.82, colors: ["#95D5B2", "#BDE0FE", "#FFF8D6", "#74C69D"]),
        Spec(name: "Exam Mode", description: "Maximum clarity with restrained cool white and blue focus accents.", category: .productivity, brightness: 0.98, colors: ["#FFFFFF", "#E3F2FD", "#BBDEFB", "#90CAF9"]),
        Spec(name: "Low Tide", description: "Muted sand, slate blue, and sea foam tones for quiet coastal evenings.", category: .relaxation, brightness: 0.43, colors: ["#D9CAB3", "#6C91A6", "#A8DADC", "#355070"]),
        Spec(name: "Karaoke Night", description: "Playful pink, violet, cyan, and gold mapped across every lamp.", category: .entertainment, brightness: 0.88, colors: ["#FF4D6D", "#C77DFF", "#48CAE4", "#FFD60A"]),
        Spec(name: "Northern Cabin", description: "Pine green, fire amber, and dim cream for cozy cabin atmosphere.", category: .nature, brightness: 0.50, colors: ["#2D6A4F", "#D95D39", "#F4D35E", "#FFF3B0"]),
        Spec(name: "Design Sprint", description: "Clear white center with energetic orange and cyan side lighting.", category: .productivity, brightness: 0.88, colors: ["#FFFFFF", "#FF9F1C", "#2EC4B6", "#EAF8FF"]),
        Spec(name: "Lavender Sleep", description: "Dim lavender, smoky blue, and warm white to prepare for rest.", category: .relaxation, brightness: 0.28, colors: ["#BDB2FF", "#6D6875", "#FFCDB2", "#2B2D42"]),
        Spec(name: "Neon Bazaar", description: "Market-like jewel tones with ruby, teal, gold, and violet accents.", category: .entertainment, brightness: 0.74, colors: ["#D00000", "#00A896", "#FFD166", "#7209B7"]),
        Spec(name: "Spring Window", description: "Fresh blossom pink, daylight white, and new-leaf green for morning optimism.", category: .nature, brightness: 0.76, colors: ["#FFCAD4", "#FDFFFC", "#B7E4C7", "#A2D2FF"]),
        Spec(name: "Quiet Museum", description: "Soft neutral layers that preserve color accuracy while lowering intensity.", category: .productivity, brightness: 0.62, colors: ["#F8F9FA", "#E9ECEF", "#DEE2E6", "#FFF3BF"])
    ]

    private static let livingSpecs: [Spec] = [
        Spec(name: "Campfire Drift", description: "A slow ember animation that moves through orange, red, and warm amber lamp by lamp.", category: .livingLights, brightness: 0.54, colors: ["#FF7A1A", "#D7261E", "#FFB000", "#7A1E0E"], style: .living),
        Spec(name: "Aurora Flow", description: "Northern-light greens, violets, and ice blues that gently rotate across the room.", category: .livingLights, brightness: 0.62, colors: ["#00E087", "#6F35FF", "#7DE8FF", "#17315C"], style: .living),
        Spec(name: "Ocean Breathing", description: "Teal, deep blue, and seafoam tones that breathe slowly like reflected water.", category: .livingLights, brightness: 0.58, colors: ["#00C2A8", "#006DCC", "#7DFFB2", "#003049"], style: .living),
        Spec(name: "Neon Pulse", description: "Electric cyan and magenta pulses designed for RGB lamps in lounges and play rooms.", category: .livingLights, brightness: 0.72, colors: ["#00F5FF", "#FF2BD6", "#7B2CFF", "#12122B"], style: .living),
        Spec(name: "Candle Circle", description: "Soft flame tones that drift subtly for dinner tables and calm evening rooms.", category: .livingLights, brightness: 0.40, colors: ["#FFB347", "#FF7A3D", "#B23A48", "#FFF0C2"], style: .living),
        Spec(name: "Forest Fireflies", description: "Deep woodland greens with small yellow flashes cycling between lamps.", category: .livingLights, brightness: 0.46, colors: ["#0B3D2E", "#1D6B4F", "#C9F227", "#102418"], style: .living)
    ]
}
