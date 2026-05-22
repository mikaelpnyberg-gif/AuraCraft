import Foundation
import Combine
import WatchConnectivity

final class PhoneWatchBridge: NSObject, ObservableObject {
    private enum Key {
        static let action = "action"
        static let rooms = "rooms"
        static let id = "id"
        static let name = "name"
        static let lightCount = "lightCount"
        static let hasRGB = "hasRGB"
        static let activeMoodName = "activeMoodName"
        static let moods = "moods"
        static let category = "category"
        static let roomID = "roomID"
        static let moodName = "moodName"
    }

    private enum Action {
        static let requestSnapshot = "requestSnapshot"
        static let applyMood = "applyMood"
        static let turnOffRoom = "turnOffRoom"
    }

    private weak var homeKit: HomeKitManager?
    private var cancellables: Set<AnyCancellable> = []

    init(homeKit: HomeKitManager) {
        self.homeKit = homeKit
        super.init()
        configureSession()
        observeHomeChanges()
    }

    func sendSnapshot() {
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }

        do {
            try WCSession.default.updateApplicationContext(snapshotPayload())
        } catch {
            print("Watch snapshot update failed: \(error.localizedDescription)")
        }
    }

    private func configureSession() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func observeHomeChanges() {
        homeKit?.$rooms
            .dropFirst()
            .sink { [weak self] _ in self?.sendSnapshot() }
            .store(in: &cancellables)

        homeKit?.$appliedMoods
            .dropFirst()
            .sink { [weak self] _ in self?.sendSnapshot() }
            .store(in: &cancellables)
    }

    private func snapshotPayload() -> [String: Any] {
        let rooms = homeKit?.rooms.map { room -> [String: Any] in
            [
                Key.id: room.id.uuidString,
                Key.name: room.name,
                Key.lightCount: room.lightCount,
                Key.hasRGB: room.hasRGB,
                Key.activeMoodName: homeKit?.currentMood(for: room)?.name ?? "",
                Key.moods: watchMoods(for: room)
            ]
        } ?? []

        return [Key.rooms: rooms]
    }

    private func watchMoods(for room: Room) -> [[String: String]] {
        let suggestions = MoodEngine.generateSuggestions(for: room, isProUnlocked: true)
        let presets = SceneLibrary.presets(compatibleWith: room).values.flatMap { $0 }
        let moods = suggestions + presets

        return moods.map { mood in
            [
                Key.name: mood.name,
                Key.category: mood.category.displayName
            ]
        }
    }

    private func applyMood(roomID: String, moodName: String) {
        guard
            let homeKit,
            let roomUUID = UUID(uuidString: roomID),
            let room = homeKit.rooms.first(where: { $0.id == roomUUID })
        else { return }

        let suggestions = MoodEngine.generateSuggestions(for: room, isProUnlocked: true)
        let presets = SceneLibrary.presets(compatibleWith: room).values.flatMap { $0 }
        guard let mood = (suggestions + presets).first(where: { $0.name == moodName }) else { return }

        homeKit.applyMood(mood, to: room)
    }

    private func turnOffRoom(roomID: String) {
        guard
            let homeKit,
            let roomUUID = UUID(uuidString: roomID),
            let room = homeKit.rooms.first(where: { $0.id == roomUUID })
        else { return }

        homeKit.turnOffLights(in: room)
    }
}

extension PhoneWatchBridge: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            print("Watch session activation failed: \(error.localizedDescription)")
            return
        }

        sendSnapshot()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handle(message)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        handle(message)
        replyHandler(snapshotPayload())
    }

    private func handle(_ message: [String: Any]) {
        guard let action = message[Key.action] as? String else { return }

        switch action {
        case Action.requestSnapshot:
            sendSnapshot()
        case Action.applyMood:
            guard
                let roomID = message[Key.roomID] as? String,
                let moodName = message[Key.moodName] as? String
            else { return }
            applyMood(roomID: roomID, moodName: moodName)
        case Action.turnOffRoom:
            guard let roomID = message[Key.roomID] as? String else { return }
            turnOffRoom(roomID: roomID)
        default:
            break
        }
    }
}
