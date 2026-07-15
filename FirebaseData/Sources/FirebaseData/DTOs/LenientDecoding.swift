//
//  LenientDecoding.swift
//  FirebaseData
//
//  Realtime Database does NOT store empty strings, zeros, or nil values — it
//  simply omits those keys. A DTO with non-optional `String`/`Int` fields would
//  therefore throw `keyNotFound` (or `valueNotFound` on an explicit null) the
//  moment ANY field is empty, and the entire screenplay fails to decode.
//
//  These helpers make decoding tolerant: a missing or null value falls back to
//  a sensible empty default instead of throwing. This is the correct behaviour
//  for RTDB, where "absent" and "empty" are the same thing.
//

import Foundation

extension KeyedDecodingContainer {

    /// Decodes a `String`, treating a missing key or explicit null as `""`.
    func lenientString(_ key: Key) -> String {
        ((try? decodeIfPresent(String.self, forKey: key)) ?? nil) ?? ""
    }

    /// Decodes an `Int`, treating a missing key or explicit null as `0`.
    func lenientInt(_ key: Key) -> Int {
        ((try? decodeIfPresent(Int.self, forKey: key)) ?? nil) ?? 0
    }
}
