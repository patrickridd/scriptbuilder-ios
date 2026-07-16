import SwiftUI

/// A two-page book-style **page-curl** pager, recreating the feel of the legacy
/// `ScreenplayPageViewController` (a `UIPageViewController` with the
/// `.pageCurl` transition set in the storyboard). It hosts two SwiftUI pages
/// and lets the user turn between them like the pages of a bound script.
///
/// Binding `pageIndex` (0 = leading page, 1 = trailing page) both reflects the
/// user's swipes and lets callers turn the page programmatically (e.g. a
/// "Start writing" button that curls forward to the workspace).
struct PageCurlView<Leading: View, Trailing: View>: UIViewControllerRepresentable {
    @Binding var pageIndex: Int
    let leading: () -> Leading
    let trailing: () -> Trailing

    init(
        pageIndex: Binding<Int>,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self._pageIndex = pageIndex
        self.leading = leading
        self.trailing = trailing
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pager = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: [.spineLocation: UIPageViewController.SpineLocation.min.rawValue]
        )
        pager.dataSource = context.coordinator
        pager.delegate = context.coordinator
        context.coordinator.buildControllers()
        pager.setViewControllers(
            [context.coordinator.controller(at: pageIndex)],
            direction: .forward,
            animated: false
        )
        return pager
    }

    func updateUIViewController(_ pager: UIPageViewController, context: Context) {
        context.coordinator.parent = self

        let current = context.coordinator.index(of: pager.viewControllers?.first)
        guard current != pageIndex else { return }
        let direction: UIPageViewController.NavigationDirection =
            pageIndex > current ? .forward : .reverse
        pager.setViewControllers(
            [context.coordinator.controller(at: pageIndex)],
            direction: direction,
            animated: true
        )
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageCurlView
        private var controllers: [UIHostingController<AnyView>] = []

        init(_ parent: PageCurlView) {
            self.parent = parent
        }

        func buildControllers() {
            let leadingVC = UIHostingController(rootView: AnyView(parent.leading()))
            let trailingVC = UIHostingController(rootView: AnyView(parent.trailing()))
            leadingVC.view.backgroundColor = .clear
            trailingVC.view.backgroundColor = .clear
            controllers = [leadingVC, trailingVC]
        }

        func controller(at index: Int) -> UIViewController {
            let clamped = max(0, min(index, controllers.count - 1))
            return controllers[clamped]
        }

        func index(of controller: UIViewController?) -> Int {
            guard let controller, let idx = controllers.firstIndex(of: controller as! UIHostingController<AnyView>) else {
                return parent.pageIndex
            }
            return idx
        }

        // MARK: - Data source

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerBefore viewController: UIViewController) -> UIViewController? {
            let idx = index(of: viewController)
            return idx > 0 ? controllers[idx - 1] : nil
        }

        func pageViewController(_ pageViewController: UIPageViewController,
                                viewControllerAfter viewController: UIViewController) -> UIViewController? {
            let idx = index(of: viewController)
            return idx < controllers.count - 1 ? controllers[idx + 1] : nil
        }

        // MARK: - Delegate

        func pageViewController(_ pageViewController: UIPageViewController,
                                didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController],
                                transitionCompleted completed: Bool) {
            guard completed else { return }
            let idx = index(of: pageViewController.viewControllers?.first)
            if idx != parent.pageIndex {
                parent.pageIndex = idx
            }
        }
    }
}
