import SwiftUI
import AppKit

enum SettingsTab: Hashable {
    case general, about
}

struct SettingsView: View {
    @State private var tab: SettingsTab = .general

    var body: some View {
        TabView(selection: $tab) {
            GeneralSettingsTab().tabItem { Label("General", systemImage: "gearshape") }.tag(SettingsTab.general)
            AboutSettingsTab().tabItem { Label("About", systemImage: "info.circle") }.tag(SettingsTab.about)
        }
        .padding(20)
        .frame(minWidth: 440, idealWidth: 460, maxWidth: .infinity, minHeight: 380, idealHeight: 420, maxHeight: .infinity)
    }
}

private struct GeneralSettingsTab: View {
    @ObservedObject private var state = AppState.shared

    var body: some View {
        Form {
            Toggle("Launch Pocket at login", isOn: $state.launchAtLogin)

            Divider().padding(.vertical, 4)

            Text("Hiding icons").font(.headline)
            Toggle("Hide icons again after clicking elsewhere", isOn: $state.autoHideOnOutsideClick)
            Toggle("Hide icons when the frontmost app goes fullscreen (best effort)", isOn: $state.autoHideOnFullscreen)

            HStack {
                Text("Auto-hide after idle:")
                Stepper(
                    value: $state.autoHideIdleSeconds,
                    in: 0...120,
                    step: 5
                ) {
                    Text(state.autoHideIdleSeconds == 0 ? "Off" : "\(Int(state.autoHideIdleSeconds))s")
                }
            }

            Divider().padding(.vertical, 4)

            Text("Updates").font(.headline)
            Toggle("Automatically check for updates", isOn: $state.autoCheckForUpdates)
                .help("Only checks GitHub for a newer version and notifies you — never downloads or installs anything automatically.")

            Divider().padding(.vertical, 4)

            Text("Keyboard shortcut: \(HotkeyFormatter.describe(keyCode: state.hotkeyKeyCode, modifiers: state.hotkeyModifiers))")
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.top, 8)
    }
}

private struct AboutSettingsTab: View {
    @ObservedObject private var updateChecker = UpdateChecker.shared
    @State private var checkResultMessage: String?

    private var appIcon: NSImage { NSApp.applicationIconImage ?? NSImage() }
    private var version: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0" }
    private var githubURL: URL { URL(string: "https://github.com/\(UpdateChecker.repoOwner)/\(UpdateChecker.repoName)")! }

    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: appIcon)
                .resizable()
                .frame(width: 96, height: 96)
            Text("Pocket").font(.title).bold()
            Text("Version \(version)").font(.caption).foregroundStyle(.secondary)
            Text("Your menu bar, in your pocket.")
                .font(.callout).foregroundStyle(.secondary)
            Text("Organizes a crowded menu bar: sort icons into always-visible and hidden groups with a Cmd-drag, then reach everything — hidden or not — from one click.")
                .font(.footnote).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)

            Link(destination: githubURL) {
                Label(githubURL.absoluteString.replacingOccurrences(of: "https://", with: ""), systemImage: "link")
            }
            .font(.callout)

            HStack(spacing: 8) {
                Button(updateChecker.isChecking ? "Checking…" : "Check for Updates") {
                    Task {
                        let found = await updateChecker.checkNow(userInitiated: true)
                        checkResultMessage = found ? "Update \(updateChecker.availableUpdate?.version ?? "") available!" : "You're up to date."
                    }
                }
                .disabled(updateChecker.isChecking)
                if let message = checkResultMessage {
                    Text(message).font(.caption).foregroundStyle(.secondary)
                }
            }
            if let lastChecked = Defaults.lastUpdateCheckDate {
                Text("Last checked \(Self.relativeFormat(lastChecked))").font(.caption2).foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
    }

    private static func relativeFormat(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
