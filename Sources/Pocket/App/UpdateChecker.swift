import Foundation

struct AppUpdate: Equatable {
    let version: String
    let releaseURL: URL
}

/// Checks GitHub Releases for a newer version. No auto-download/install (that needs
/// a paid Developer ID + Sparkle-style signing infrastructure this project doesn't
/// have) — this just tells you a new version exists and sends you to the release
/// page to grab it yourself. Opt-in via Defaults.autoCheckForUpdates.
@MainActor
final class UpdateChecker: ObservableObject {

    static let shared = UpdateChecker()

    static let repoOwner = "Micropeptide"
    static let repoName = "Pocket"

    @Published private(set) var availableUpdate: AppUpdate?
    @Published private(set) var isChecking = false

    private var timer: Timer?

    private init() {}

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    /// Starts the periodic background check (once at launch, then once every 24h) if the user has it enabled.
    func startAutomaticChecking() {
        timer?.invalidate()
        guard Defaults.autoCheckForUpdates else { return }
        Task { await checkNow(userInitiated: false) }
        timer = Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard Defaults.autoCheckForUpdates else { return }
                await self?.checkNow(userInitiated: false)
            }
        }
    }

    func stopAutomaticChecking() {
        timer?.invalidate()
        timer = nil
    }

    @discardableResult
    func checkNow(userInitiated: Bool) async -> Bool {
        isChecking = true
        defer { isChecking = false }

        guard let url = URL(string: "https://api.github.com/repos/\(Self.repoOwner)/\(Self.repoName)/releases/latest") else {
            return false
        }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                if userInitiated {
                    NotificationHelper.post(title: "Couldn't check for updates", body: "GitHub didn't return release information. Try again later.")
                }
                return false
            }
            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            let latestVersion = Self.normalizeVersion(release.tag_name)

            Defaults.lastUpdateCheckDate = Date()

            if Self.isVersion(latestVersion, newerThan: currentVersion), let releaseURL = URL(string: release.html_url) {
                availableUpdate = AppUpdate(version: latestVersion, releaseURL: releaseURL)
                NotificationHelper.post(title: "Pocket \(latestVersion) is available", body: "You're on \(currentVersion). Open Pocket's menu to download the update.")
                return true
            } else {
                availableUpdate = nil
                if userInitiated {
                    NotificationHelper.post(title: "Pocket is up to date", body: "You're on the latest version (\(currentVersion)).")
                }
                return false
            }
        } catch {
            if userInitiated {
                NotificationHelper.post(title: "Couldn't check for updates", body: "No response from GitHub. Check your connection and try again.")
            }
            return false
        }
    }

    private struct GitHubRelease: Decodable {
        let tag_name: String
        let html_url: String
    }

    private static func normalizeVersion(_ tag: String) -> String {
        tag.hasPrefix("v") ? String(tag.dropFirst()) : tag
    }

    /// Simple dotted-integer version comparison ("1.10.0" > "1.9.0").
    private static func isVersion(_ a: String, newerThan b: String) -> Bool {
        let partsA = a.split(separator: ".").compactMap { Int($0) }
        let partsB = b.split(separator: ".").compactMap { Int($0) }
        let count = max(partsA.count, partsB.count)
        for i in 0..<count {
            let x = i < partsA.count ? partsA[i] : 0
            let y = i < partsB.count ? partsB[i] : 0
            if x != y { return x > y }
        }
        return false
    }
}
