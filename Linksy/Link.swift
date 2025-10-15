//
//  Link.swift
//  Linksy
//
//  Created by Pat Nakajima on 10/7/25.
//

import Foundation
import HTMLString
import LinkPresentation
import GRDB
import GRDBQuery

nonisolated struct SavedLink: Codable, Identifiable, FetchableRecord, PersistableRecord {
	enum Columns {
		static let id = Column(CodingKeys.id)
		static let url = Column(CodingKeys.url)
		static let host = Column(CodingKeys.host)
		static let name = Column(CodingKeys.name)
		static let description = Column(CodingKeys.description)
		static let createdAt = Column(CodingKeys.createdAt)
		static let updatedAt = Column(CodingKeys.updatedAt)
		static let textContent = Column(CodingKeys.textContent)
		static let lastTappedAt = Column(CodingKeys.lastTappedAt)
		static let lastSuggestedAt = Column(CodingKeys.lastSuggestedAt)
	}
	
	let id: Int
	let url: String
	let host: String
	let name: String
	let description: String?
	let createdAt: Date
	let updatedAt: Date
	let textContent: String?
	var lastTappedAt: Date?
	var lastSuggestedAt: Date?
	
	@MainActor static func refresh(client: LinkWarden, database: any DatabaseWriter) async {
		do {
			let cursor = try await database.write { db in
				try SavedLink.select(Column("id")).order(Column("id").desc).asRequest(of: Int.self).fetchOne(db) ?? nil
			}

			let links = try await fetchLinks(client: client, cursor: cursor)
			for link in links {
				if link.url.presence == nil {
					continue
				}

				let link = await SavedLink.from(api: link)

				try await database.write { db in
					try link.save(db)
				}
			}
		} catch {
			print("err fetching links: \(error)")
		}
	}
	
	static func fetchLinks(client: LinkWarden, cursor: Int?) async throws -> [LWLink] {
		var (links, cursor) = try await client.links(cursor: cursor)
		while cursor != nil {
			let (newLinks, newCursor) = try await client.links(cursor: cursor)
			links.append(contentsOf: newLinks)
			cursor = newCursor
		}
		return links
	}

	var displayName: String {
		// If the name is multiline, take the longest one
		let name_parts = name.split(separator: /\n+/).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
		let part = name_parts.sorted(by: { $0.count > $1.count }).first ?? url

		return part.removingHTMLEntities()
	}

	nonisolated static func from(api link: LWLink) async -> SavedLink {
		var link = link

		let metadata = await LPLinkView(url: URL(string: link.url!)!).metadata
		link.name = metadata.title ?? link.name

		return SavedLink(
			id: link.id,
			url: link.url ?? "",
			host: URL(string: link.url ?? "")?.host ?? "",
			name: link.name,
			description: link.description,
			createdAt: link.createdAt,
			updatedAt: link.updatedAt,
			textContent: link.textContent,
			lastSuggestedAt: nil
		)
	}
}
