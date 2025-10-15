//
//  String.swift
//  Linksy
//
//  Created by Pat Nakajima on 8/21/25.
//

import Foundation
import UIKit

extension String? {
	var presence: String? {
		guard let s = self else {
			return nil
		}

		return s.presence
	}
}

extension String {
	var presence: String? {
		if trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			.none
		} else {
			.some(self)
		}
	}
}
