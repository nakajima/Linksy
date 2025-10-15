// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let lWLinkWardenResponse = try? JSONDecoder().decode(LWLinkWardenResponse.self, from: jsonData)

import Foundation

// MARK: - LWLinkWardenResponse

struct LWLinkWardenResponse: Codable {
	let data: LWData
	let success: Bool
	let message: String
}

struct LWCheckResponse: Codable {
	let message: String?
	let success: Bool?
	let response: String?
}

// MARK: - LWData

struct LWData: Codable {
	let links: [LWLink]
	let nextCursor: Int?
}

// MARK: - LWLink

struct LWLink: Codable {
	let id: Int
	var name: String
	let type: LWType
	var description: String
	let createdByID, collectionID: Int
	let icon, iconWeight, color: String?
	let url: String?
	let preview, image, pdf, readable: String?
	let monolith: String?
	let aiTagged: Bool
	let indexVersion: Int?
	let lastPreserved: String?
	let importDate: Date?
	let createdAt, updatedAt: Date
	let tags: [LWTag]
	let collection: LWCollection
	var textContent: String?

	enum CodingKeys: String, CodingKey {
		case id, name, type, description
		case createdByID = "createdById"
		case collectionID = "collectionId"
		case icon, iconWeight, color, url, preview, image, pdf, readable, monolith, aiTagged, indexVersion, lastPreserved, importDate, createdAt, updatedAt, tags, collection, textContent
	}
}

// MARK: - LWCollection

struct LWCollection: Codable {
	let id: Int
	let name: LWName
	let description: String
	let icon, iconWeight: JSONNull?
	let color: LWColor
	let parentID: JSONNull?
	let isPublic: Bool
	let ownerID, createdByID: Int
	let createdAt, updatedAt: LWAtedAt

	enum CodingKeys: String, CodingKey {
		case id, name, description, icon, iconWeight, color
		case parentID = "parentId"
		case isPublic
		case ownerID = "ownerId"
		case createdByID = "createdById"
		case createdAt, updatedAt
	}
}

enum LWColor: String, Codable {
	case the0Ea5E9 = "#0ea5e9"
}

enum LWAtedAt: String, Codable {
	case the20250725T080131401Z = "2025-07-25T08:01:31.401Z"
}

enum LWName: String, Codable {
	case unorganized = "Unorganized"
}

// MARK: - LWTag

struct LWTag: Codable {
	let id: Int
	let name: String
	let ownerID: Int
	let archiveAsScreenshot, archiveAsMonolith, archiveAsPDF, archiveAsReadable: Bool?
	let archiveAsWaybackMachine, aiTag: String?
	let createdAt, updatedAt: String

	enum CodingKeys: String, CodingKey {
		case id, name
		case ownerID = "ownerId"
		case archiveAsScreenshot, archiveAsMonolith, archiveAsPDF, archiveAsReadable, archiveAsWaybackMachine, aiTag, createdAt, updatedAt
	}
}

enum LWType: String, Codable {
	case image
	case pdf
	case url
}

// MARK: - LWArchive

struct LWArchive: Codable {
	let title: String
	let byline, dir, lang: String?
	let content, textContent: String?
	let length: Int
	let excerpt: String
	let siteName: String?
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
	public static func == (_: JSONNull, _: JSONNull) -> Bool {
		return true
	}

	public var hashValue: Int {
		return 0
	}

	public init() {}

	public required init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if !container.decodeNil() {
			throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encodeNil()
	}
}

class JSONCodingKey: CodingKey {
	let key: String

	required init?(intValue _: Int) {
		return nil
	}

	required init?(stringValue: String) {
		self.key = stringValue
	}

	var intValue: Int? {
		return nil
	}

	var stringValue: String {
		return key
	}
}

class JSONAny: Codable {
	let value: Any

	static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
		let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
		return DecodingError.typeMismatch(JSONAny.self, context)
	}

	static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
		let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
		return EncodingError.invalidValue(value, context)
	}

	static func decode(from container: SingleValueDecodingContainer) throws -> Any {
		if let value = try? container.decode(Bool.self) {
			return value
		}
		if let value = try? container.decode(Int64.self) {
			return value
		}
		if let value = try? container.decode(Double.self) {
			return value
		}
		if let value = try? container.decode(String.self) {
			return value
		}
		if container.decodeNil() {
			return JSONNull()
		}
		throw decodingError(forCodingPath: container.codingPath)
	}

	static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
		if let value = try? container.decode(Bool.self) {
			return value
		}
		if let value = try? container.decode(Int64.self) {
			return value
		}
		if let value = try? container.decode(Double.self) {
			return value
		}
		if let value = try? container.decode(String.self) {
			return value
		}
		if let value = try? container.decodeNil() {
			if value {
				return JSONNull()
			}
		}
		if var container = try? container.nestedUnkeyedContainer() {
			return try decodeArray(from: &container)
		}
		if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
			return try decodeDictionary(from: &container)
		}
		throw decodingError(forCodingPath: container.codingPath)
	}

	static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
		if let value = try? container.decode(Bool.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(Int64.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(Double.self, forKey: key) {
			return value
		}
		if let value = try? container.decode(String.self, forKey: key) {
			return value
		}
		if let value = try? container.decodeNil(forKey: key) {
			if value {
				return JSONNull()
			}
		}
		if var container = try? container.nestedUnkeyedContainer(forKey: key) {
			return try decodeArray(from: &container)
		}
		if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
			return try decodeDictionary(from: &container)
		}
		throw decodingError(forCodingPath: container.codingPath)
	}

	static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
		var arr: [Any] = []
		while !container.isAtEnd {
			let value = try decode(from: &container)
			arr.append(value)
		}
		return arr
	}

	static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
		var dict = [String: Any]()
		for key in container.allKeys {
			let value = try decode(from: &container, forKey: key)
			dict[key.stringValue] = value
		}
		return dict
	}

	static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
		for value in array {
			if let value = value as? Bool {
				try container.encode(value)
			} else if let value = value as? Int64 {
				try container.encode(value)
			} else if let value = value as? Double {
				try container.encode(value)
			} else if let value = value as? String {
				try container.encode(value)
			} else if value is JSONNull {
				try container.encodeNil()
			} else if let value = value as? [Any] {
				var container = container.nestedUnkeyedContainer()
				try encode(to: &container, array: value)
			} else if let value = value as? [String: Any] {
				var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
				try encode(to: &container, dictionary: value)
			} else {
				throw encodingError(forValue: value, codingPath: container.codingPath)
			}
		}
	}

	static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
		for (key, value) in dictionary {
			let key = JSONCodingKey(stringValue: key)!
			if let value = value as? Bool {
				try container.encode(value, forKey: key)
			} else if let value = value as? Int64 {
				try container.encode(value, forKey: key)
			} else if let value = value as? Double {
				try container.encode(value, forKey: key)
			} else if let value = value as? String {
				try container.encode(value, forKey: key)
			} else if value is JSONNull {
				try container.encodeNil(forKey: key)
			} else if let value = value as? [Any] {
				var container = container.nestedUnkeyedContainer(forKey: key)
				try encode(to: &container, array: value)
			} else if let value = value as? [String: Any] {
				var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
				try encode(to: &container, dictionary: value)
			} else {
				throw encodingError(forValue: value, codingPath: container.codingPath)
			}
		}
	}

	static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
		if let value = value as? Bool {
			try container.encode(value)
		} else if let value = value as? Int64 {
			try container.encode(value)
		} else if let value = value as? Double {
			try container.encode(value)
		} else if let value = value as? String {
			try container.encode(value)
		} else if value is JSONNull {
			try container.encodeNil()
		} else {
			throw encodingError(forValue: value, codingPath: container.codingPath)
		}
	}

	public required init(from decoder: Decoder) throws {
		if var arrayContainer = try? decoder.unkeyedContainer() {
			self.value = try JSONAny.decodeArray(from: &arrayContainer)
		} else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
			self.value = try JSONAny.decodeDictionary(from: &container)
		} else {
			let container = try decoder.singleValueContainer()
			self.value = try JSONAny.decode(from: container)
		}
	}

	public func encode(to encoder: Encoder) throws {
		if let arr = value as? [Any] {
			var container = encoder.unkeyedContainer()
			try JSONAny.encode(to: &container, array: arr)
		} else if let dict = value as? [String: Any] {
			var container = encoder.container(keyedBy: JSONCodingKey.self)
			try JSONAny.encode(to: &container, dictionary: dict)
		} else {
			var container = encoder.singleValueContainer()
			try JSONAny.encode(to: &container, value: value)
		}
	}
}
