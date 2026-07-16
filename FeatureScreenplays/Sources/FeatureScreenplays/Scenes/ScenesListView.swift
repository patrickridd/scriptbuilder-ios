import SwiftUI
import Domain
import DesignSystem
import UniformTypeIdentifiers

/// The Scenes tab of the screenplay editor: three fixed act sections (Act I / II
/// / III), each with a `+` in its header to add a scene scoped to that act.
/// Empty acts show a "Tap + to create a new Scene!" placeholder.
///
/// Built on a `ScrollView` + `LazyVStack` (not `List`) so SwiftUI's native
/// `.draggable` / `.dropDestination` work without fighting the List reorder
/// gesture. Long-press a scene card and drag it: drop it onto another card to
/// reorder (within an act) or relocate (across acts); drop onto an act header or
/// an empty act to append it there. Tapping a card opens the full editor.
public struct ScenesListView: View {
    @Environment(\.appPalette) private var palette
    @State private var viewModel: ScenesViewModel
    @State private var newlyAdded: SceneRoute?
    @State private var selected: SceneRoute?
    @State private var draggingID: String?
    @State private var dropTargetID: String?
    private let gate: EditorGate
    /// Observe entitlement changes so the lock chrome updates live after a
    /// purchase / restore / expiration while this tab is on screen.
    @ObservedObject private var entitlementSignal: EditorEntitlementSignal

    public init(
        screenplayID: String,
        act1: [Domain.Scene],
        act2: [Domain.Scene],
        act3: [Domain.Scene],
        repository: ScreenplayRepository,
        gate: EditorGate = .unrestricted
    ) {
        _viewModel = State(
            wrappedValue: ScenesViewModel(
                screenplayID: screenplayID,
                act1: act1,
                act2: act2,
                act3: act3,
                repository: repository
            )
        )
        self.gate = gate
        _entitlementSignal = ObservedObject(wrappedValue: gate.entitlementSignal)
    }

    /// A scene + the act it opened from, so the editor knows its starting act.
    struct SceneRoute: Identifiable, Hashable {
        let scene: Domain.Scene
        let act: Act
        var id: String { scene.uuid }
    }

    public var body: some View {
        scroll
            .navigationDestination(item: $newlyAdded) { route in
                SceneDetailView(scene: route.scene, act: route.act, viewModel: viewModel)
            }
            .navigationDestination(item: $selected) { route in
                SceneDetailView(scene: route.scene, act: route.act, viewModel: viewModel)
            }
            .alert(
                L10n.SceneUI.deleteTitle,
                isPresented: deleteDialogBinding,
                presenting: viewModel.pendingDelete
            ) { scene in
                Button(L10n.Action.delete, role: .destructive) {
                    Haptics.warning()
                    if selected?.id == scene.uuid { selected = nil }
                    if newlyAdded?.id == scene.uuid { newlyAdded = nil }
                    viewModel.confirmPendingDelete()
                }
                Button(L10n.Action.cancel, role: .cancel) { viewModel.pendingDelete = nil }
            } message: { _ in
                Text(viewModel.pendingDeleteMessage)
            }
    }

    private var deleteDialogBinding: Binding<Bool> {
        Binding(
            get: { viewModel.pendingDelete != nil },
            set: { if !$0 { viewModel.pendingDelete = nil } }
        )
    }

    // MARK: - Scroll content

    private var scroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 20, pinnedViews: []) {
                    ForEach(viewModel.sections) { section in
                        actSection(section)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.highlightedSceneID) { _, newID in
                guard let newID else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                    proxy.scrollTo(newID, anchor: .top)
                }
            }
        }
    }

    @ViewBuilder
    private func actSection(_ section: ScenesViewModel.ActSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(section)
            if section.scenes.isEmpty {
                emptyRow(for: section.act)
            } else {
                ForEach(section.scenes, id: \.uuid) { scene in
                    row(for: scene, in: section.act)
                }
            }
        }
    }

    private func sectionHeader(_ section: ScenesViewModel.ActSection) -> some View {
        HStack {
            Label(section.act.title.uppercased(), systemImage: "square.stack.3d.up.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(palette.textMuted)
            Spacer()
            Button {
                requestAddScene(to: section.act)
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(isSceneLocked ? palette.textMuted : palette.accent)
                    if isSceneLocked { headerLockBadge }
                }
                .animation(.easeInOut(duration: 0.25), value: isSceneLocked)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isSceneLocked ? "Add scene to \(section.act.title) (Pro)" : "Add scene to \(section.act.title)")
        }
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        // Drop onto the header appends the dragged scene to this act.
        .dropDestination(for: String.self) { items, _ in
            endDrag()
            guard let sceneID = items.first else { return false }
            viewModel.moveScene(sceneID, to: section.act)
            return true
        }
    }

    private func row(for scene: Domain.Scene, in act: Act) -> some View {
        SwipeToDeleteRow {
            viewModel.requestDelete(scene)
        } content: {
            rowCard(for: scene, in: act)
        }
        .id(scene.uuid)
    }

    private func rowCard(for scene: Domain.Scene, in act: Act) -> some View {
        SceneRowCard(
            scene: scene,
            isHighlighted: viewModel.isHighlighted(scene),
            isDropTarget: dropTargetID == scene.uuid,
            isDragging: draggingID == scene.uuid
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture {
            selected = SceneRoute(scene: scene, act: act)
        }
        .draggable(scene.uuid) {
            SceneRowCard(scene: scene, isHighlighted: false, isDropTarget: false, isDragging: false)
                .frame(width: 260)
                .onAppear { draggingID = scene.uuid }
        }
        .dropDestination(for: String.self) { items, _ in
            endDrag()
            guard let draggedID = items.first, draggedID != scene.uuid else { return false }
            viewModel.moveScene(draggedID, before: scene.uuid, in: act)
            return true
        } isTargeted: { targeted in
            dropTargetID = targeted ? scene.uuid : (dropTargetID == scene.uuid ? nil : dropTargetID)
        }
        .contextMenu {
            Button(role: .destructive) {
                viewModel.requestDelete(scene)
            } label: {
                Label(L10n.SceneUI.deleteButton, systemImage: "trash")
            }
        }
    }

    private func emptyRow(for act: Act) -> some View {
        Button {
            requestAddScene(to: act)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isSceneLocked ? "lock.fill" : "plus.circle.fill")
                    .font(.title3)
                Text(isSceneLocked ? L10n.SceneUI.unlockMore : L10n.SceneUI.addScene)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(isSceneLocked ? palette.textMuted : palette.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill((isSceneLocked ? palette.textMuted : palette.accent).opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder((isSceneLocked ? palette.textMuted : palette.accent).opacity(0.35), lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.25), value: isSceneLocked)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSceneLocked ? "Unlock ScriptBuilder Pro to add more scenes" : "Create a new scene in \(act.title)")
        .dropDestination(for: String.self) { items, _ in
            endDrag()
            guard let sceneID = items.first else { return false }
            viewModel.moveScene(sceneID, to: act)
            return true
        }
    }

    private func endDrag() {
        draggingID = nil
        dropTargetID = nil
    }

    /// Total scenes across all three acts — the count the scene gate checks
    /// against the free-tier limit.
    private var totalSceneCount: Int {
        viewModel.sections.reduce(0) { $0 + $1.scenes.count }
    }

    /// Whether adding another scene is blocked by the free-tier gate. When
    /// `true`, the add controls show a lock hint so the limit is visible before
    /// the user taps into the paywall.
    private var isSceneLocked: Bool {
        !gate.canAddScene(totalSceneCount)
    }

    /// Small lock overlay for the compact header "+" control.
    private var headerLockBadge: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: 8, weight: .black))
            .foregroundStyle(palette.accent)
            .padding(2.5)
            .background(.white, in: Circle())
            .overlay(Circle().stroke(palette.cardStroke, lineWidth: 0.5))
            .offset(x: 3, y: 3)
    }

    /// Gate-checked scene creation. If the free limit is reached, surface the
    /// paywall via the gate instead of creating; otherwise add and route into
    /// the new scene's editor.
    private func requestAddScene(to act: Act) {
        guard gate.canAddScene(totalSceneCount) else {
            gate.onBlocked()
            return
        }
        Task {
            let created = await viewModel.addScene(to: act)
            newlyAdded = SceneRoute(scene: created, act: act)
        }
    }
}

/// A single scene-list card: the scene number badge, title, heading preview, and
/// a trailing drag-handle glyph that signals the card can be long-pressed to
/// reorder. Highlights when it's the current drop target.
private struct SceneRowCard: View {
    @Environment(\.appPalette) private var palette
    let scene: Domain.Scene
    var isHighlighted: Bool = false
    var isDropTarget: Bool = false
    var isDragging: Bool = false

    private var title: String {
        let trimmed = scene.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled Scene" : trimmed
    }

    private var preview: String {
        let heading = scene.header.trimmingCharacters(in: .whitespacesAndNewlines)
        if !heading.isEmpty { return heading }
        let desc = scene.sceneDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return desc.isEmpty ? "No heading set yet" : desc
    }

    private var strokeColor: Color {
        if isDropTarget { return palette.accent }
        if isHighlighted { return palette.accent.opacity(0.9) }
        return palette.cardStroke
    }

    private var strokeWidth: CGFloat {
        (isDropTarget || isHighlighted) ? 1.5 : 1
    }

    var body: some View {
        HStack(spacing: 14) {
            Text("\(scene.sceneNumber)")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(palette.heroGradient, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)
                Text(preview)
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.textMuted)
        }
        .padding(14)
        .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(strokeColor, lineWidth: strokeWidth)
        )
        .opacity(isDragging ? 0.4 : 1)
        .animation(.easeInOut(duration: 0.2), value: isDropTarget)
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }
}
