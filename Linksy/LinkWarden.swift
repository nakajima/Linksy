import Foundation
import KeychainAccess

struct LinkWarden {
	enum Status: Equatable {
		case none, errored(String), isChecking, success
	}
		
	let baseURL: URL
	let token: String

	init(baseURL: URL, token: String) {
		self.baseURL = baseURL
		self.token = token
	}
	
	static func authedClient() -> LinkWarden? {
		if let urlString = AppGroup.keychain["url"].presence,
			 let url = URL(string: urlString),
			 let token = AppGroup.keychain["token"].presence {
			return LinkWarden(baseURL: url, token: token)
		}
		
		return nil
	}
	
	static func check(url: URL, token: String) async throws -> Status {
		let client = LinkWarden(baseURL: url, token: token)
		let response: LWCheckResponse = try await client.get(path: "/api/v2/dashboard", token: token)
		if let success = response.success, success {
			return .success
		} else {
			return .errored(response.response ?? "Unknown error")
		}
	}

	func links(cursor: Int? = nil) async throws -> ([LWLink], Int?) {
		var params = ["sort":"1"]

		if let cursor {
			params["cursor"] = "\(cursor)"
		}

		let response: LWLinkWardenResponse = try await self.get(path: "/api/v1/search", params: params, token: self.token)
		let links = response.data.links
		return (links, response.data.nextCursor)
	}
	
	func get<T: Decodable>(path: String, params: [String: String] = [:], token: String?) async throws -> T {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601

		var url = baseURL.appending(path: path)
		url.append(queryItems: params.map { URLQueryItem(name: $0, value: $1) })

		var request = URLRequest(url: url)
		
		if let token {
			request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		
		let (data, _) = try await URLSession.shared.data(for: request)
		return try decoder.decode(T.self, from: data)
	}
}
