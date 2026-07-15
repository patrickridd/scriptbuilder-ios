import Testing
@testable import Domain

// MARK: - AppLogger

@Test func loggerCapturesLevelAndMessage() {
    let logger = CapturingLogger()
    logger.log(.error, "boom")

    #expect(logger.entries == [.init(level: .error, message: "boom")])
}

@Test func convenienceMethodsRouteToCorrectLevels() {
    let logger = CapturingLogger()
    logger.debug("d")
    logger.info("i")
    logger.notice("n")
    logger.error("e")
    logger.fault("f")

    #expect(logger.messages(for: .debug) == ["d"])
    #expect(logger.messages(for: .info) == ["i"])
    #expect(logger.messages(for: .notice) == ["n"])
    #expect(logger.messages(for: .error) == ["e"])
    #expect(logger.messages(for: .fault) == ["f"])
}

@Test func loggerPreservesOrder() {
    let logger = CapturingLogger()
    logger.info("first")
    logger.error("second")

    #expect(logger.entries.map(\.message) == ["first", "second"])
}
