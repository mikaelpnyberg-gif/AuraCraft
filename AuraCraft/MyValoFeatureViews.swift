import SwiftUI
import UIKit
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
    @EnvironmentObject private var storeManager: StoreManager
    @State private var showingPaywall = false
    @State private var powerStates: [UUID: Bool] = [:]
    @State private var brightnessValues: [UUID: Double] = [:]
    @State private var colorValues: [UUID: Color] = [:]

    var body: some View {
        NavigationStack {
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
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
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

struct SoundSyncView: View {
    @EnvironmentObject private var homeKit: HomeKitManager
    @EnvironmentObject private var storeManager: StoreManager
    @State private var showingPaywall = false
    @StateObject private var soundSync = SoundSyncManager()

    private var activeMoodRows: [(roomName: String, mood: Mood)] {
        homeKit.rooms.compactMap { room in
            guard let mood = homeKit.currentMood(for: room) else { return nil }
            return (room.name, mood)
        }
    }

    var body: some View {
        NavigationStack {
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

                Section("Active Mood") {
                    if activeMoodRows.isEmpty {
                        Text("No mood is active yet")
                            .foregroundColor(AuraColor.textSecondary)
                    } else {
                        ForEach(activeMoodRows, id: \.roomName) { row in
                            HStack(spacing: AuraSpacing.md) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(colors: row.mood.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 38, height: 38)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(row.mood.name)
                                        .font(AuraFont.title(14))
                                    Text(row.roomName)
                                        .font(AuraFont.body(12))
                                        .foregroundColor(AuraColor.textSecondary)
                                }
                            }
                        }
                    }
                }

                Section("Microphone Sync") {
                    Toggle("Sound-Reactive Lights", isOn: Binding(
                        get: { soundSync.isRunning },
                        set: { enabled in
                            guard storeManager.isProUnlocked else {
                                showingPaywall = true
                                soundSync.stop()
                                return
                            }
                            if enabled {
                                Task { await soundSync.start(homeKit: homeKit) }
                            } else {
                                soundSync.stop()
                            }
                        }
                    ))

                    VStack(alignment: .leading, spacing: AuraSpacing.sm) {
                        Text("Loudness \(Int(soundSync.loudness * 100))%")
                        ProgressView(value: soundSync.loudness)
                        Text("Bass \(Int(soundSync.bassLevel * 100))%")
                        ProgressView(value: soundSync.bassLevel)
                        Text("Treble \(Int(soundSync.trebleLevel * 100))%")
                        ProgressView(value: soundSync.trebleLevel)
                    }
                    .font(AuraFont.body(13))
                    .disabled(!storeManager.isProUnlocked)
                    .opacity(storeManager.isProUnlocked ? 1 : 0.45)
                }

                if let error = soundSync.errorMessage {
                    Section("Status") {
                        Text(error).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Sound Sync")
        }
        .onDisappear { soundSync.stop() }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(storeManager)
        }
    }
}
