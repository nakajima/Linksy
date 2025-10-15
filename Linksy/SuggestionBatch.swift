//
//  SuggestionBatch.swift
//  Linksy
//
//  Created by Pat Nakajima on 10/7/25.
//

import Foundation
import GRDB

struct LinkSuggestion: Codable, Identifiable {
	let id: Int
	let link_id: Int
	let suggestion_batch_id: Int
}

struct SuggestionBatch: Codable, Identifiable {
	let id: Int
	let createdAt: Date
}
