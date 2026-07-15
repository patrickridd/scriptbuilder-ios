//
//  Persistence.swift
//  FirebaseData
//
//  Small façade so the composition root can enable Realtime Database disk
//  persistence without importing FirebaseDatabase directly — keeping the
//  "app never touches Firebase types" boundary intact.
//

import FirebaseDatabase

public enum FirebaseDataPersistence {

    /// Enables Realtime Database on-disk persistence (offline cache).
    ///
    /// Important: call this **once**, after `FirebaseApp.configure()` and
    /// **before** any `DatabaseReference` is created (including the default
    /// reference used by `FirebaseScreenplayRepository`). Setting it after a
    /// reference exists has no effect and Firebase logs a warning.
    ///
    /// - Parameter enabled: Whether disk persistence should be on. Defaults to `true`.
    public static func enableDiskPersistence(_ enabled: Bool = true) {
        Database.database().isPersistenceEnabled = enabled
    }
}
