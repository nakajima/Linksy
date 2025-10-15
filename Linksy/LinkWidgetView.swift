//
//  LinkWidgetView.swift
//  Linksy
//
//  Created by Pat Nakajima on 10/13/25.
//

import SwiftUI
import GRDBQuery
import Foundation
import AppIntents

extension Array<SavedLink> {
	func first(_ n: Int) -> Self {
		if n > self.count - 1  {
			return self
		} else {
			return Array(self[0..<n])
		}
	}
}

enum LinkWidgetSize {
	case small, medium, large, xlarge
	
	var count: Int {
		switch self {
		case .small: 1
		case .medium: 2
		case .large: 5
		case .xlarge: 6
		}
	}
	
	var size: CGSize {
		switch self {
		case .small: CGSize(width: 170, height: 170)
		case .medium: CGSize(width: 364, height: 170)
		case .large: CGSize(width: 364, height: 382)
		case .xlarge: CGSize(width: 382, height: 382)
		}
	}
	
	var lineLimit: Int {
		switch self {
		case .small: 4
		case .medium: 2
		case .large: 3
		case .xlarge: 4
		}
	}
}

struct LinkWidgetView: View {
	var size: LinkWidgetSize
	var links: [SavedLink]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			ForEach(links) { link in
				Link(destination: URL(string: link.url)!) {
					VStack(alignment: .leading) {
						Text(link.displayName)
							.multilineTextAlignment(.leading)
							.frame(maxWidth: .infinity, alignment: .leading)
							.fixedSize(horizontal: false, vertical: true)
							.lineLimit(size.lineLimit)
							.font(.subheadline)
						Text(link.host)
							.foregroundStyle(.secondary)
							.font(.caption)
							.bold()
					}
				}
				.buttonStyle(.borderless)
			}
		}
		.foregroundStyle(.primary)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.unredacted()
	}
}

struct LinkWidgetPreviewView<Content: View>: View {
	@Query(LinksQuery()) var links: [SavedLink]
	let size: LinkWidgetSize
	let content: ([SavedLink]) -> Content

	var body: some View {
		content(links.shuffled().first(size.count))
	}
}

#Preview {
	ScrollView {
		VStack {
			HStack {
				LinkWidgetPreviewView(size: .small) { links in
					LinkWidgetView(size: .small, links: links)
						.frame(width: LinkWidgetSize.small.size.width, height: LinkWidgetSize.small.size.height)
						.border(.secondary)
						.cornerRadius(24)
						.padding()
				}
				LinkWidgetPreviewView(size: .small) { links in
					LinkWidgetView(size: .small, links: links)
						.frame(width: LinkWidgetSize.small.size.width, height: LinkWidgetSize.small.size.height)
						.border(.secondary)
						.cornerRadius(24)
						.padding()
				}
			}
			LinkWidgetPreviewView(size: .small){ links in
				LinkWidgetView(size: .medium, links: links)
					.padding()
			}
			LinkWidgetPreviewView(size: .small) { links in
				LinkWidgetView(size: .small, links: links)
					.padding()
			}
		}
		.padding(.top, 64)
	}
	.task {
		if let client = LinkWarden.authedClient() {
			await SavedLink.refresh(client: client, database: try! appDatabase(kind: .path("preview.db")))
		}
	}
	.frame(maxWidth: .infinity)
	.edgesIgnoringSafeArea(.all)
	.background(.black)
	.databaseContext(.readWrite { try! appDatabase(kind: .path("preview.db")) })
}
