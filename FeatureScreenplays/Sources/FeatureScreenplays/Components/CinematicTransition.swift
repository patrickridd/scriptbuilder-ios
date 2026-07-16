import SwiftUI
import Domain

/// Cinematic "cover lift" navigation transition helpers.
///
/// On iOS 18+ these wrap Apple's first-party `matchedTransitionSource` /
/// `navigationTransition(.zoom:)` so the tapped screenplay cover visually
/// expands into the editor (and interactively shrinks back on swipe-to-
/// dismiss) — the same effect Photos uses. On iOS 17 they're no-ops, so the
/// standard push slide is used and nothing breaks.
public extension View {

    /// Marks this view as the *source* of a zoom transition, keyed by the
    /// screenplay's id. Pass the shell's `Namespace.ID`; a `nil` namespace
    /// disables the effect (e.g. when the host opts out).
    @ViewBuilder
    func screenplayZoomSource(id: Screenplay.ID, in namespace: Namespace.ID?) -> some View {
        if #available(iOS 18.0, *), let namespace {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }

    /// Applies the zoom *destination* transition to the editor screen, keyed by
    /// the same screenplay id used at the source.
    @ViewBuilder
    func screenplayZoomDestination(id: Screenplay.ID, in namespace: Namespace.ID?) -> some View {
        if #available(iOS 18.0, *), let namespace {
            self.navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            self
        }
    }

    /// Suppresses the *interactive* dismissal of a zoom navigation transition
    /// (the swipe-down / pinch that pops the destination) while keeping the
    /// animated push and the toolbar back button intact.
    ///
    /// The editor hosts scrollable tabs (Characters, Scenes …). A downward drag
    /// meant to scroll the cast list would otherwise be interpreted by the zoom
    /// transition as a dismissal and pop the whole editor — jarring mid-scroll.
    /// When `isActive` is true we disable the pan/pinch recognizers that drive
    /// the interactive dismissal so only the explicit back button dismisses.
    @ViewBuilder
    func disableZoomInteractiveDismiss(_ isActive: Bool = true) -> some View {
        if #available(iOS 18.0, *) {
            self.background(ZoomDismissDisabler(isActive: isActive))
        } else {
            self
        }
    }
}

/// Disables the zoom transition's interactive-dismiss gesture recognizers so
/// the editor can't be popped by a swipe-down / pinch while the user scrolls a
/// tab. Only the explicit toolbar back button dismisses the editor.
///
/// The recognizers that drive the zoom dismissal are installed on the *parent*
/// view controller's view and are identified by their (private) class names,
/// which differ on iOS 26+. We match by class-type string and flip `isEnabled`
/// — never removing recognizers — and restore them on teardown. This is the
/// community-proven technique; it touches no private API surface directly.
@available(iOS 18.0, *)
private struct ZoomDismissDisabler: UIViewControllerRepresentable {
    let isActive: Bool

    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        apply(from: viewController, active: isActive, retriesLeft: 3)
    }

    static func dismantleUIViewController(_ viewController: UIViewController, coordinator: Coordinator) {
        // Re-enable everything when the modifier goes away so sibling screens
        // keep their normal dismissal gestures.
        viewController.parent?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        for gesture in viewController.parent?.view.gestureRecognizers ?? [] where zoomGestureClassNames.contains(String(describing: type(of: gesture))) {
            gesture.isEnabled = true
        }
    }

    // MARK: - Apply

    private func apply(from viewController: UIViewController, active: Bool, retriesLeft: Int) {
        guard
            let parent = viewController.parent,
            parent.navigationController != nil
        else {
            // The hierarchy may not be wired up on the first pass; retry shortly.
            guard retriesLeft > 0 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                apply(from: viewController, active: active, retriesLeft: retriesLeft - 1)
            }
            return
        }

        for gesture in parent.view.gestureRecognizers ?? [] where Self.zoomGestureClassNames.contains(String(describing: type(of: gesture))) {
            gesture.isEnabled = !active
        }
    }

    // MARK: - Private recognizer class names

    /// Edge-pan zoom-transition dismissal recognizer.
    private static let edgePanClass = "_UIParallaxTransitionPanGestureRecognizer"
    /// Swipe-down-to-dismiss recognizer (renamed on iOS 26).
    private static var swipeDownClass: String {
        if #available(iOS 26, *) {
            return "_UIContentSwipeDismissGestureRecognizer"
        } else {
            return "_UISwipeDownGestureRecognizer"
        }
    }
    /// Pinch-to-dismiss recognizer.
    private static let pinchClass = "_UITransformGestureRecognizer"

    private static var zoomGestureClassNames: Set<String> {
        [edgePanClass, swipeDownClass, pinchClass]
    }
}
