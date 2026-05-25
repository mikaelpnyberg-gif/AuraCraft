import SwiftUI
import Combine
import AVFoundation

@MainActor
final class LivingLightAnimator: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var activeMoodName: String?

    private var task: Task<Void, Never>?

    func start(mood: Mood, room: Room, homeKit: HomeKitManager) {
        stop()
        guard !mood.lightSettings.isEmpty else { return }
        isRunning = true
        activeMoodName = mood.name
        let updateInterval = UInt64(mood.animationInterval * 1_000_000_000)

        task = Task { [weak self, weak homeKit] in
            var index = 0
            while !Task.isCancelled {
                guard let self, let homeKit else { return }
                let shifted = self.shiftedMood(mood, offset: index)
                homeKit.applyMood(shifted, to: room)
                index += 1
                try? await Task.sleep(nanoseconds: updateInterval)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        isRunning = false
        activeMoodName = nil
    }

    private func shiftedMood(_ mood: Mood, offset: Int) -> Mood {
        let settings = mood.lightSettings.indices.map { mood.lightSettings[($0 + offset) % mood.lightSettings.count] }
        return Mood(
            name: mood.name,
            description: mood.description,
            category: mood.category,
            isGenerated: mood.isGenerated,
            isLocked: mood.isLocked,
            isPremium: mood.isPremium,
            style: mood.style,
            requiredCapability: mood.requiredCapability,
            lightSetting: settings.first ?? mood.lightSetting,
            lightSettings: settings,
            gradientColors: settings.map(\.previewColor),
            animationInterval: mood.animationInterval
        )
    }
}

@MainActor
final class SoundSyncManager: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var loudness: Double = 0
    @Published private(set) var bassLevel: Double = 0
    @Published private(set) var trebleLevel: Double = 0
    @Published var errorMessage: String?

    private let engine = AVAudioEngine()
    private var updateTask: Task<Void, Never>?
    private var latestSamples: [Float] = []

    func start(homeKit: HomeKitManager) async {
        guard !isRunning else { return }

        do {
            let granted = await AVAudioApplication.requestRecordPermission()
            guard granted else {
                throw NSError(domain: "SoundSync", code: 1, userInfo: [NSLocalizedDescriptionKey: "Microphone access was denied."])
            }
            try configureAudioEngine()
            try engine.start()
            isRunning = true
            errorMessage = nil
            startThrottledLightUpdates(homeKit: homeKit)
        } catch {
            stop()
            errorMessage = error.localizedDescription
        }
    }

    func stop() {
        updateTask?.cancel()
        updateTask = nil
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRunning = false
        latestSamples = []
    }

    private func configureAudioEngine() throws {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let channel = buffer.floatChannelData?[0] else { return }
            let count = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: channel, count: count))
            Task { @MainActor in
                self?.analyze(samples)
            }
        }
        engine.prepare()
    }

    private func analyze(_ samples: [Float]) {
        guard !samples.isEmpty else { return }
        latestSamples = samples
        let rms = sqrt(samples.reduce(0) { $0 + Double($1 * $1) } / Double(samples.count))
        loudness = min(max(rms * 8, 0), 1)

        let half = max(samples.count / 2, 1)
        let low = samples.prefix(half).reduce(0) { $0 + abs(Double($1)) } / Double(half)
        let high = samples.suffix(half).reduce(0) { $0 + abs(Double($1 - samples.first!)) } / Double(half)
        bassLevel = min(low * 10, 1)
        trebleLevel = min(high * 12, 1)
    }

    private func startThrottledLightUpdates(homeKit: HomeKitManager) {
        updateTask = Task { [weak self, weak homeKit] in
            while !Task.isCancelled {
                guard let self, let homeKit else { return }
                let brightness = max(0.15, self.loudness)
                let color: Color = self.bassLevel > self.trebleLevel
                    ? Color(hue: 0.83, saturation: 0.85, brightness: brightness)
                    : Color(hue: 0.55, saturation: 0.90, brightness: brightness)
                homeKit.applyToAllLights(brightness: brightness, color: color)
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }
}

