//
//  ScenesPreviewData.swift
//  FeatureScreenplays
//
//  Sample scenes shared by the Xcode previews for `ScenesListView` and
//  `SceneDetailView`. Debug-only: never compiled into a release build.
//

#if DEBUG
import Foundation
import Domain

enum ScenesPreviewData {

    static let screenplayID = "preview-screenplay"

    static let act1: [Domain.Scene] = [
        Domain.Scene(
            uuid: "prev-1",
            title: "Cold Open",
            sceneNumber: 1,
            header: "EXT. RAIN-SLICKED ROOFTOP — NIGHT",
            sceneDescription: "Mara watches the city she is about to leave behind.",
            dialogue: "MARA\nOne last look. Then we go.",
            action: "She pockets the drive and steps off the ledge onto the fire escape.",
            characters: "MARA, DEV",
            howPushesStory: "Establishes the stakes and the ticking clock.",
            notes: "Consider opening on the reflection in a puddle."
        ),
        Domain.Scene(
            uuid: "prev-2",
            title: "The Offer",
            sceneNumber: 2,
            header: "INT. NOODLE BAR — CONTINUOUS",
            sceneDescription: "Dev pitches the job Mara swore she'd never take.",
            characters: "MARA, DEV"
        )
    ]

    static let act2: [Domain.Scene] = [
        Domain.Scene(
            uuid: "prev-3",
            title: "Crossing the Line",
            sceneNumber: 3,
            header: "INT. ARCHIVE VAULT — NIGHT",
            sceneDescription: "The heist goes sideways when the lights come back on."
        )
    ]

    static let act3: [Domain.Scene] = []

    @MainActor
    static func viewModel() -> ScenesViewModel {
        ScenesViewModel(
            screenplayID: screenplayID,
            act1: act1,
            act2: act2,
            act3: act3,
            repository: MockScreenplayRepository(seedSamples: false)
        )
    }
}
#endif
