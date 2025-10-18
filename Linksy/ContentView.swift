//
//  ContentView.swift
//  Linksy
//
//  Created by Pat Nakajima on 8/21/25.
//
import GRDB
import GRDBQuery
import SwiftUI
import KeychainAccess
import WidgetKit

nonisolated struct LinksQuery: ValueObservationQueryable {
	static var defaultValue: [SavedLink] { [] }

	func fetch(_ db: Database) throws -> [SavedLink] {
		try SavedLink.order(Column("lastSuggestedAt").desc).fetchAll(db)
	}
}

struct LinksListView: View {
	@Environment(\.openURL) var openURL
	@Environment(\.databaseContext) var database
	@State var isLoggingOut = false
	
	let client: LinkWarden
	let formatter = RelativeDateTimeFormatter()
	let logout: () -> ()

	@Query(LinksQuery()) var links: [SavedLink]
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(links) { link in
					VStack(alignment: .leading) {
						LinkWidgetView(size: .small, links: [link])
							.simultaneousGesture(TapGesture().onEnded( {_ in
								var link = link
								link.lastTappedAt = Date()
								try? database.writer.write { db in
									try link.save(db)
								}
							}))
						Text("Saved \(link.createdAt.formatted(date: .abbreviated, time: .omitted))")
							.foregroundStyle(.secondary)
							.font(.caption)
						HStack(alignment: .bottom) {
							if let lastSuggested = link.lastSuggestedAt {
								Text("Suggested \(formatter.string(for: lastSuggested) ?? lastSuggested.formatted())")
									.font(.caption)
									.foregroundStyle(.secondary)
								Spacer()
							}
							
							if let lastTapped = link.lastTappedAt {
								Text("Tapped \(formatter.string(for: lastTapped) ?? lastTapped.formatted())")
									.font(.caption)
									.foregroundStyle(.secondary)
							}
						}
					}
					.opacity(link.lastTappedAt == nil ? 1.0 : 0.5)
				}
			}
			.overlay {
				if links.isEmpty {
					Text("No links yet.")
				}
			}
			.task {
				try! await SavedLink.refresh(client: self.client, database: self.database.writer)
			}
			.refreshable {
				try! await SavedLink.refresh(client: self.client, database: self.database.writer)
			}
			.onOpenURL { url in
				do {
					if var link = try database.reader.read({ db in
						try SavedLink.filter({ $0.url == url.description }).fetchOne(db)
					}) {
						link.lastTappedAt = Date()
						try database.writer.write { db in
							try link.save(db)
						}
						
						WidgetCenter.shared.reloadAllTimelines()
					}
				} catch {
					print("error updating link: \(error)")
				}
				
				openURL(url)
				print("Opened url: \(url.debugDescription)")
			}
			.navigationTitle("Linksy")
			.toolbar {
				Button(action: {
					self.isLoggingOut = true
				}) {
					Text("Logout")
				}
			}
			.alert("Logout?", isPresented: $isLoggingOut) {
				Button("Yes", role: .destructive) {
					AppGroup.keychain["url"] = nil
					AppGroup.keychain["token"] = nil
					self.logout()
				}
				Button("Cancel", role: .cancel) { }
			}
		}
		
	}
}

struct LoginView: View {
	@State var url = ""
	@State var token = ""
	@FocusState var isFocused
	@State var status = LinkWarden.Status.none
	let onLogin: (LinkWarden) -> ()
	
	var body: some View {
		Form {
			Section("Enter your LinkWarden details") {
				TextField("URL", text: $url)
				#if os(iOS)
					.textInputAutocapitalization(.never)
					.textContentType(.URL)
				#endif
					.focused($isFocused)
					.onAppear {
						self.isFocused = true
					}
					.disabled(status == .isChecking)
				TextField("Token", text: $token)
					.disabled(status == .isChecking)
				Button(action: { self.status = .isChecking }) {
					Text("Save")
				}
				.disabled(status == .isChecking || url.presence == nil || token.presence == nil)
				
				if case let .errored(message) = status {
					Text(message).foregroundStyle(.red)
				}
			}
			.onSubmit({ self.status = .isChecking })
		}
		.overlay {
			if status == .isChecking {
				ProgressView()
			}
		}
		.task(id: status) {
			guard status == .isChecking else { return }
			
			guard let url = URL(string: self.url) else {
				self.status = .errored("URL doesn't look valid")
				return
			}
			
			do {
				let status = try await LinkWarden.check(url: url, token: self.token)
				if status == .success {
					AppGroup.keychain["url"] = self.url
					AppGroup.keychain["token"] = self.token
					self.onLogin(LinkWarden(baseURL: url, token: token))
					self.status = .success
				} else {
					self.status = status
				}
			} catch {
				self.status = .errored("\(error.localizedDescription)")
			}
		}
	}
}

struct ContentView: View {
	@State var client: LinkWarden? = nil
	
	init() {
		if let client = LinkWarden.authedClient() {
			self._client = State(initialValue: client)
		}
	}
	
	var body: some View {
		if let client {
			LinksListView(client: client, logout: { self.client = nil })
		} else {
			LoginView {
				self.client = $0
			}
		}
	}
}

#Preview {
	ContentView()
		.databaseContext(.readWrite { try! appDatabase(kind: .path("preview.db")) })
}
