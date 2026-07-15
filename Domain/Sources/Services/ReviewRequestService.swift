//
//  ReviewRequestService.swift
//  Domain
//
//  A dependency-free seam for asking the OS to present its native App Store
//  review prompt. Consumers depend on this protocol; the composition root
//  injects a StoreKit-backed implementation (`StoreKitReviewRequestService`
//  in the app layer). Tests/previews can inject a capturing mock.
//
//  Only Apple's own API can submit an App Store rating, so this protocol is
//  intentionally tiny — it just says "now is a good time to ask". The system
//  decides whether to actually show the sheet and rate-limits it for us.
//

/// Requests the system's native App Store review prompt.
public protocol ReviewRequestService: Sendable {
    /// Asks the OS to present the native review prompt. The system may choose
    /// not to display it (e.g. shown too recently, already rated). Must be
    /// called on the main actor by convention, since it drives UI.
    @MainActor
    func requestReview()
}

/// A no-op implementation useful for previews and tests where we never want a
/// real prompt to appear.
public struct NoopReviewRequestService: ReviewRequestService {
    public init() {}
    @MainActor public func requestReview() {}
}
