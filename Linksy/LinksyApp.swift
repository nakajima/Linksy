//
//  LinksyApp.swift
//  Linksy
//
//  Created by Pat Nakajima on 8/21/25.
//

import SwiftData
import SwiftUI
import GRDBQuery

@main
struct LinksyApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.databaseContext(.readWrite { try! appDatabase(kind: .path("links.db")) })
	}
}
