//
//  TitleParser.swift
//  Linksy
//
//  Created by Pat Nakajima on 10/8/25.
//

import FoundationModels

@Generable
struct Title {
	@Guide(description: "Is the page title an accurate description of the text content or does it need modifications")
	var isGoodTitle: Bool

	@Guide(description: "The cleaned up title")
	var result: String
}

struct TitleParser {
	let rawTitle: String
	let textContents: String

	let session = LanguageModelSession(
		instructions: """
		Summarize the provided text contents as a one liner.
		""")

	init(_ rawTitle: String, textContents: String) {
		self.rawTitle = rawTitle
		self.textContents = textContents
	}

	func parse() async throws -> Title {
		if rawTitle.contains("The heart of the internet") ||
			rawTitle.firstMatch(of: /not found/.ignoresCase()) != nil ||
			rawTitle.firstMatch(of: /404/) != nil ||
			rawTitle.split(separator: /\s+/).count < 3
		{
			if textContents.presence != nil {
				return try await session.respond(to: "text contents: \(textContents)", generating: Title.self).content
			} else {
				return Title(isGoodTitle: false, result: rawTitle)
			}
		} else {
			return Title(isGoodTitle: true, result: rawTitle)
		}
	}
}
