//
//  Migrate.swift
//  Linksy
//
//  Created by Pat Nakajima on 10/7/25.
//
import OSLog
import GRDB

enum AppDatabaseKind {
	case path(String), memory
}

func appDatabase(kind: AppDatabaseKind) throws -> DatabaseQueue {
	var configuration = Configuration()
	#if DEBUG
		configuration.prepareDatabase { db in
			db.trace(options: .profile) {
				print("\($0.expandedDescription)")
			}
		}
	#endif

	let path = switch kind {
	case .path(let path): AppGroup.containerURL.appending(path: path).path
	case .memory: ":memory:"
	}
	let database = try DatabaseQueue(path: path, configuration: configuration)
	logger.info("open '\(database.path)'")
	var migrator = DatabaseMigrator()
	#if DEBUG
		migrator.eraseDatabaseOnSchemaChange = true
	#endif
	migrator.registerMigration("Create tables") { db in
		try db.create(table: "savedLink", ifNotExists: true) { t in
			t.autoIncrementedPrimaryKey("id")
			t.column("name", .text)
			t.column("description", .text)
			t.column("url", .text)
			t.column("createdAt", .date)
			t.column("updatedAt", .date)
			t.column("textContent", .text)
			t.column("host", .text)
			t.column("lastSuggestedAt", .date)
		}
	}

	migrator.registerMigration("Create suggestion batches") { db in
		try db.create(table: "suggestion_batches", ifNotExists: true) { t in
			t.autoIncrementedPrimaryKey("id")
			t.column("createdAt", .date).notNull().indexed()
		}
	}

	migrator.registerMigration("Suggestion joins") { db in
		try db.create(table: "link_suggestions", ifNotExists: true) { t in
			t.autoIncrementedPrimaryKey("id")
			t.column("link_id", .integer).notNull().indexed().references("savedLink")
			t.column("suggestion_batch_id", .integer).notNull().indexed().references("suggestion_batches")
		}
	}
	
	migrator.registerMigration("Add lastTappedAt") { db in
		try db.alter(table: "savedLink") { t in
			t.add(column: "lastTappedAt")
		}
	}

	try migrator.migrate(database)
	return database
}

private let logger = Logger(subsystem: "MyApp", category: "Database")
