//
//  AppIntent.swift
//  LinksyWidget
//
//  Created by Pat Nakajima on 8/21/25.
//

import AppIntents
import Foundation
import WidgetKit

struct LinkIntent: WidgetConfigurationIntent {
	static var title: LocalizedStringResource { "Configuration" }
	static var description: IntentDescription { "This is an example widget." }
}
