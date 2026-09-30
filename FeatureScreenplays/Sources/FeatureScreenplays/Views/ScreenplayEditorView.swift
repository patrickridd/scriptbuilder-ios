import SwiftUI
import Domain
import DesignSystem

/// The working editor for an opened screenplay. A top segmented control switches
/// between the three workspace tabs — Outline, Characters, Scenes — replacing the
/// legacy bottom tab bar. All three tabs are now fully live.
public struct ScreenplayEditorView: View {
    @Environment(\.appPalette) private var palette
    private let screenplay: Screenplay
    private let repository: ScreenplayRepository
    private let gate: EditorGate

    /// Invoked when the outline first becomes fully complete — the app layer
    /// uses this as a "moment of delight" to consider a review prompt.
    private let onOutlineCompleted: () -> Void

    /// Persists the last-selected tab *per screenplay*, keyed by the screenplay's
    /// UUID, so each script independently remembers where the writer left off.
    /// Defaults to Outline the first time a given screenplay is opened.
    @AppStorage private var storedTabRawValue: Int

    /// Survives tab switches so no tab ever reloads from the opening snapshot.
    @State private var workspace: EditorWorkspace
    @Environment(\.scenePhase) private var scenePhase

    private var tab: Binding<EditorTab> {
        Binding(
            get: { EditorTab(rawValue: storedTabRawValue) ?? .outline },
            set: { storedTabRawValue = $0.rawValue }
        )
    }

    public init(
        screenplay: Screenplay,
        repository: ScreenplayRepository,
        gate: EditorGate = .unrestricted,
        onOutlineCompleted: @escaping () -> Void = {}
    ) {
        self.screenplay = screenplay
        self.repository = repository
        self.gate = gate
        self.onOutlineCompleted = onOutlineCompleted
        _storedTabRawValue = AppStorage(
            wrappedValue: EditorTab.outline.rawValue,
            "lastEditorTab.\(screenplay.uuid)"
        )
        _workspace = State(
            initialValue: EditorWorkspace(screenplay: screenplay, repository: repository)
        )
    }

    public var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 0) {
                tabPicker
                content
            }
        }
        .environment(\.appPalette, editorPalette)
        .navigationTitle(screenplay.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { workspace.flushOutline() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { workspace.flushOutline() }
        }
    }

    /// The three editor tabs adopt the ScriptBuilder brand color for their
    /// accents (rings, badges, pills, glows) by overriding the shared `accent`
    /// token with `scriptBuilder`, while inheriting every other token.
    private var editorPalette: AppPalette {
        palette.with(accent: palette.scriptBuilder)
    }

    private var tabPicker: some View {
        Picker("Workspace", selection: tab) {
            ForEach(EditorTab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .tint(palette.scriptBuilder)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var content: some View {
        switch tab.wrappedValue {
        case .outline:
            OutlineView(
                viewModel: workspace.outline(onOutlineCompleted: onOutlineCompleted),
                gate: gate
            )
        case .characters:
            CharacterListView(
                viewModel: workspace.characters,
                gate: gate,
                screenplayTitle: screenplay.title
            )
        case .scenes:
            ScenesListView(viewModel: workspace.scenes, gate: gate)
        }
    }
}

/// Keeps one view model per tab alive for as long as the editor is open.
///
/// Each tab used to build its view model from the screenplay snapshot taken
/// when the script was opened. Switching tabs tore that model down, so coming
/// back showed the *opening* data: new characters/scenes vanished from the
/// list, and editing a stale row saved the old values over the newer ones.
/// Holding the models here means every tab resumes exactly where it was left.
@MainActor
final class EditorWorkspace {
    private let screenplay: Screenplay
    private let repository: ScreenplayRepository
    private var outlineModel: OutlineViewModel?

    init(screenplay: Screenplay, repository: ScreenplayRepository) {
        self.screenplay = screenplay
        self.repository = repository
    }

    func outline(onOutlineCompleted: @escaping () -> Void) -> OutlineViewModel {
        if let outlineModel { return outlineModel }
        let model = OutlineViewModel(screenplay: screenplay, repository: repository)
        model.onOutlineCompleted = onOutlineCompleted
        outlineModel = model
        return model
    }

    /// Writes any outline keystrokes still waiting out the autosave debounce.
    func flushOutline() {
        guard let outlineModel else { return }
        Task { await outlineModel.flush() }
    }

    lazy var characters = CharactersViewModel(
        screenplayID: screenplay.uuid,
        characters: screenplay.characters,
        repository: repository
    )

    lazy var scenes = ScenesViewModel(
        screenplayID: screenplay.uuid,
        act1: screenplay.act1.scenes,
        act2: screenplay.act2.scenes,
        act3: screenplay.act3.scenes,
        repository: repository
    )
}

private enum EditorTab: Int, CaseIterable, Identifiable {
    case outline, characters, scenes
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .outline: return "Outline"
        case .characters: return "Characters"
        case .scenes: return "Scenes"
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ScreenplayEditorView(
            screenplay: Screenplay(
                title: "Echoes of Tomorrow",
                logLine: "A stranded engineer must trust a fading AI to make it home.",
                characters: [
                    Character(name: "Mara Vance", role: "Protagonist",
                              intention: "Repair the beacon and signal home before the storm hits."),
                    Character(name: "ORION", role: "Mentor",
                              intention: "Guide Mara while its own power fades."),
                    Character(name: "Cutter", role: "Antagonist",
                              intention: "Seize the beacon's parts for his own ship.")
                ]
            ),
            repository: MockScreenplayRepository()
        )
        .environment(\.appPalette, .default)
    }
}
#endif
