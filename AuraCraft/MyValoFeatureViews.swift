import SwiftUI
import HomeKit

extension Color {
    var hueSaturationBrightness: (hue: Double, saturation: Double, brightness: Double)? {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        guard uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return nil }
        return (Double(hue), Double(saturation), Double(brightness))
    }
}

struct IndividualLightControlView: View {
    @EnvironmentObject private var homeKit: HomeKitManager
    @State private var powerStates: [UUID: Bool] = [:]
    @State private var brightnessValues: [UUID: Double] = [:]
    @State private var colorValues: [UUID: Color] = [:]

    var body: some View {
        NavigationStack {
            List {
                if homeKit.controllableLights.isEmpty {
                    Text(homeKit.statusMessage ?? "No HomeKit lights found")
                        .foregroundColor(AuraColor.textSecondary)
                } else {
                    ForEach(homeKit.controllableLights) { light in
                        VStack(alignment: .leading, spacing: AuraSpacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(light.name)
                                        .font(AuraFont.title(15))
                                    Text(light.roomName)
                                        .font(AuraFont.body(12))
                                        .foregroundColor(AuraColor.textSecondary)
                                }
                                Spacer()
                                Toggle("", isOn: binding(
                                    light.id,
                                    defaultValue: true,
                                    storage: $powerStates,
                                    onChange: { homeKit.setPower($0, for: light.id) }
                                ))
                                .labelsHidden()
                            }

                            Slider(value: binding(
                                light.id,
                                defaultValue: 0.8,
                                storage: $brightnessValues,
                                onChange: { homeKit.setBrightness($0, for: light.id) }
                            ), in: 0...1)

                            if light.capability == .fullRGB {
                                ColorPicker("Color", selection: binding(
                                    light.id,
                                    defaultValue: .white,
                                    storage: $colorValues,
                                    onChange: { homeKit.setColor($0, for: light.id) }
                                ))
                            }
                        }
                        .padding(.vertical, AuraSpacing.sm)
                    }
                }
            }
            .navigationTitle("Lights")
            .toolbar {
                Button { homeKit.refreshHomes() } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task { homeKit.connectToHomeKit() }
    }

    private func binding<Value>(
        _ id: UUID,
        defaultValue: Value,
        storage: Binding<[UUID: Value]>,
        onChange: @escaping (Value) -> Void
    ) -> Binding<Value> {
        Binding(
            get: { storage.wrappedValue[id] ?? defaultValue },
            set: { newValue in
                storage.wrappedValue[id] = newValue
                onChange(newValue)
            }
        )
    }
}

struct AIMoodGeneratorView: View {
    @EnvironmentObject private var homeKit: HomeKitManager
    @EnvironmentObject private var storeManager: StoreManager
    @State private var prompt = ""
    @State private var generatedMood: Mood?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                AuraColor.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: AuraSpacing.lg) {
                    TextField("Cyberpunk neon lounge", text: $prompt)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        guard storeManager.isProUnlocked else {
                            showingPaywall = true
                            return
                        }
                        Task { await generateMood() }
                    } label: {
                        HStack {
                            if isGenerating { ProgressView().tint(.white) }
                            Image(systemName: "sparkles")
                            Text("Generate Mood")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AuraSpacing.md)
                        .background(RoundedRectangle(cornerRadius: AuraRadius.sm).fill(AuraColor.textPrimary))
                    }
                    .disabled(isGenerating || prompt.isEmpty)

                    if let generatedMood {
                        MoodCardView(mood: generatedMood)
                        if let room = homeKit.rooms.first {
                            Button("Apply to \(room.name)") {
                                homeKit.applyMood(generatedMood, to: room)
                            }
                            .font(AuraFont.caption(15))
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }

                    Spacer()
                }
                .padding(AuraSpacing.lg)
            }
            .navigationTitle("AI Mood")
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView().environmentObject(storeManager)
        }
    }

    private func generateMood() async {
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            let response = try await MockMoodAPI.generateMood(prompt: prompt)
            let settings = response.colors.map { LightSetting(brightness: response.brightness, hex: $0) }
            generatedMood = Mood(
                name: response.name,
                description: response.description,
                category: .entertainment,
                isGenerated: true,
                isPremium: true,
                requiredCapability: .fullRGB,
                lightSetting: settings.first ?? LightSetting(brightness: response.brightness),
                lightSettings: settings,
                gradientColors: response.colors.map(ColorHex.color(from:))
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct AIMoodResponse: Decodable {
    let name: String
    let description: String
    let colors: [String]
    let brightness: Double
}

enum MockMoodAPI {
    static func generateMood(prompt: String) async throws -> AIMoodResponse {
        try await Task.sleep(nanoseconds: 450_000_000)
        let json = """
        {
          "name": "\(prompt.capitalized)",
          "description": "An AI-generated multi-color lighting scene for \(prompt).",
          "colors": ["#00F5FF", "#FF2BD6", "#7C3CFF", "#FFB000"],
          "brightness": 0.72
        }
        """.data(using: .utf8)!
        return try JSONDecoder().decode(AIMoodResponse.self, from: json)
    }
}
