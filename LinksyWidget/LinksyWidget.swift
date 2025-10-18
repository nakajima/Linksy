//
//  LinksyWidget.swift
//  LinksyWidget
//
//  Created by Pat Nakajima on 8/21/25.
//

import LinkPresentation
import GRDB
import SwiftUI
@preconcurrency import WidgetKit
import AppIntents

extension WidgetFamily {
	var linkCount: Int {
		switch self {
		case .systemSmall:
			1
		case .systemMedium:
			2
		case .systemLarge:
			4
		case .systemExtraLarge:
			6
		case .accessoryCircular:
			1
		case .accessoryRectangular:
			1
		case .accessoryInline:
			1
		@unknown default:
			1
		}
	}
	
	var size: LinkWidgetSize {
		switch self {
		case .systemSmall:
				.small
		case .systemMedium:
				.medium
		case .systemLarge:
				.large
		case .systemExtraLarge:
				.xlarge
		case .accessoryCircular:
				.small
		case .accessoryRectangular:
				.small
		case .accessoryInline:
				.small
		@unknown default:
				.small
		}
	}
}

struct Provider: AppIntentTimelineProvider {
	func placeholder(in context: Context) -> SimpleEntry {
		let db = try! appDatabase(kind: .path("links.db"))
		let links = try! db.read { db in
			try SavedLink.order(Column("lastSuggestedAt").desc).limit(context.family.linkCount).fetchAll(db)
		}
		return SimpleEntry(
			date: Date(),
			configuration: LinkIntent(),
			links: links,
			size: context.family.size,
		)
	}

	func snapshot(for configuration: LinkIntent, in context: Context) async -> SimpleEntry {
		guard let client = LinkWarden.authedClient() else {
			return SimpleEntry(
				date: Date(),
				configuration: LinkIntent(),
				links: [],
				size: context.family.size
			)
		}
		
		let db = try! appDatabase(kind: .path("links.db"))
		await SavedLink.refresh(client: client, database: db)
		let links = try! await db.read { db in
			try SavedLink.order(Column("lastSuggestedAt").desc).limit(context.family.linkCount).fetchAll(db)
		}
		
		return SimpleEntry(
			date: Date(),
			configuration: LinkIntent(),
			links: links,
			size: context.family.size
		)
	}

	func timeline(for configuration: LinkIntent, in context: Context) async -> Timeline<SimpleEntry> {
		guard let client = LinkWarden.authedClient() else {
			return Timeline(entries: [], policy: .after(Calendar.current.date(byAdding: .minute, value: 5, to: Date())!))
		}
		
		var entries: [SimpleEntry] = []
		let db = try! appDatabase(kind: .path("links.db"))
		
		await SavedLink.refresh(client: client, database: db)
		let links = try! await db.read { db in
			try SavedLink.order([Column("lastTappedAt").asc, Column("lastSuggestedAt").asc]).limit(context.family.linkCount).fetchAll(db)
		}
		
		for var link in links {
			link.lastSuggestedAt = Date()
			let link = link
			try! await db.write { db in
				try link.save(db)
			}
		}

		let entry = SimpleEntry(
			date: Date(),
			configuration: configuration,
			links: links,
			size: context.family.size
		)
		entries.append(entry)

		// Refresh in an hour to keep previews fresh.
		return Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .minute, value: 5, to: Date())!))
	}
}

struct SimpleEntry: TimelineEntry {
	let date: Date
	let configuration: LinkIntent
	let links: [SavedLink]
	let size: LinkWidgetSize
}

struct LinksyWidgetEntryView: View {
	var entry: Provider.Entry

	@Environment(\.widgetFamily) private var family

	private var cornerRadius: CGFloat {
		switch family {
		case .systemSmall: return 14
		case .systemMedium: return 16
		default: return 20
		}
	}

	private var contentPadding: CGFloat {
		switch family {
		case .systemSmall: return 6
		case .systemMedium: return 8
		default: return 10
		}
	}

	private var titleFont: Font {
		switch family {
		case .systemSmall: return .headline
		case .systemMedium: return .title3
		default: return .title2
		}
	}

	private var titleLineLimit: Int {
		switch family {
		case .systemSmall: return 4
		case .systemMedium: return 5
		default: return 6
		}
	}

	var body: some View {
		LinkWidgetView(size: entry.size, links: entry.links)
			.contentMargins(.all, 0)
			.containerBackground(.clear, for: .widget)
	}
}

struct LinksyWidget: Widget {
	let kind: String = "LinksyWidget"

	var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind, intent: LinkIntent.self, provider: Provider()) { entry in
			LinksyWidgetEntryView(entry: entry)
				
		}
	}
}

private extension LinkIntent {
	static var a: LinkIntent {
		let intent = LinkIntent()
		return intent
	}

	static var b: LinkIntent {
		let intent = LinkIntent()
		return intent
	}
}

#Preview(as: .systemSmall) {
	LinksyWidget()
} timeline: {
	SimpleEntry(date: .now, configuration: .a, links: [
		SavedLink(id: 1, url: "https://example.com", host: "example.com", name: "It's an example what do you want", description: "", createdAt: Date(), updatedAt: Date(), textContent: "", lastSuggestedAt: Date())
	], size: .small)
}

#Preview(as: .systemMedium) {
	LinksyWidget()
} timeline: {
	SimpleEntry(date: .now, configuration: .a, links: [
		SavedLink(id: 1, url: "https://example.com", host: "example.com", name: "It's a longer example for you, what do you want? Oh who even knows these days lol", description: "", createdAt: Date(), updatedAt: Date(), textContent: "", lastSuggestedAt: Date()),
		SavedLink(id: 2, url: "https://example.com", host: "example.com", name: "It's another example with kind of a longer name so just so you know you know. I guess not.", description: "", createdAt: Date(), updatedAt: Date(), textContent: "", lastSuggestedAt: Date())
	], size: .small)

}
