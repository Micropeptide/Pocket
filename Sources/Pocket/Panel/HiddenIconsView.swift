import SwiftUI

struct HiddenIconsView: View {
    @ObservedObject var model: HiddenIconsPanelModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if !model.isAccessibilityGranted {
                permissionPrompt
            } else if model.icons.isEmpty {
                emptyState
            } else {
                list
            }

            footer
        }
        .frame(width: 340, height: 460)
        .onAppear { model.refresh() }
    }

    private var header: some View {
        HStack {
            Text("Menu Bar Icons")
                .font(.headline)
            Spacer()
            Button {
                model.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            .help("Refresh")
            Button {
                model.onOpenSettings?()
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding()
    }

    private var footer: some View {
        Text("Tip: hold ⌘ and drag any menu bar icon left or right of Pocket's arrow to sort it into Hidden or Always Visible.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding()
    }

    private var permissionPrompt: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "lock.shield")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("Pocket needs Accessibility permission to see which apps own a menu bar icon and open them on demand.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Button("Grant Accessibility Access…") {
                model.requestAccessibility()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("No hidden icons found.")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                section(title: "Hidden", icons: model.icons.filter { $0.zone == .hidden })
                section(title: "Always Visible", icons: model.icons.filter { $0.zone == .alwaysVisible })
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    @ViewBuilder
    private func section(title: String, icons: [MenuBarIconInfo]) -> some View {
        if !icons.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(icons) { icon in
                    row(for: icon)
                }
            }
        }
    }

    private func row(for icon: MenuBarIconInfo) -> some View {
        Button {
            icon.press()
        } label: {
            HStack {
                if let appIcon = icon.appIcon {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "app")
                        .frame(width: 20, height: 20)
                }
                Text(icon.appName)
                Spacer()
                Image(systemName: "chevron.right.circle")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(Color.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help("Click to open \(icon.appName)'s menu bar item")
    }
}
