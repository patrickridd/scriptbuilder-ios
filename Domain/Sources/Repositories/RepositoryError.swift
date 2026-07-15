//
//  RepositoryError.swift
//  Domain
//
//  Provider-agnostic errors surfaced by a `ScreenplayRepository`. Concrete
//  implementations (e.g. Firebase) should map their backend errors onto these
//  cases so the UI never has to know which backend is in use.
//

import Foundation

public enum RepositoryError: LocalizedError, Equatable {
    /// No authenticated user, so user-scoped data can't be reached.
    case notAuthenticated
    /// The requested screenplay does not exist.
    case notFound
    /// A backend / network failure, with a human-readable description.
    case backend(String)
    /// An identifier was empty or contained characters illegal for use as a
    /// storage key (e.g. RTDB keys may not be empty or contain `/ . # $ [ ]`).
    case invalidIdentifier

    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You need to be signed in to access your screenplays."
        case .notFound:
            return "That screenplay could not be found."
        case .backend(let message):
            return message
        case .invalidIdentifier:
            return "This item has an invalid identifier and can't be saved."
        }
    }
}
