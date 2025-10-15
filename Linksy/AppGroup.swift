//
//  AppGroup.swift
//  Linksy
//
//  Created by Pat Nakajima on 9/25/22.
//

import Foundation
import KeychainAccess

public enum AppGroup {
	public static var containerURL: URL {
		guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.fm.folder.linksy") else {
			fatalError("Could not get containerURL")
		}
		return containerURL
	}

	public static var defaults: UserDefaults {
		guard let defaults = UserDefaults(suiteName: "group.fm.folder.linksy") else {
			fatalError("Could not load defaults")
		}

		return defaults
	}

	public static var keychain: Keychain {
		return Keychain(service: "fm.folder.linksy")
			.synchronizable(true)
			.accessibility(.always)
	}
}
