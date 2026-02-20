import Foundation
import Security

protocol KeychainService {
    func save(_ value: String, key: KeychainKey) throws
    func get(key: KeychainKey) throws -> String
    func delete(key: KeychainKey) throws
    func clear() throws
}

final class KeychainServiceImpl: KeychainService {
    private let service: String
    
    init(service: String = Bundle.main.bundleIdentifier ?? "com.tarkiz.app") {
        self.service = service
    }
    
    func save(_ value: String, key: KeychainKey) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        
        // Delete existing item first
        try? delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }
    
    func get(key: KeychainKey) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.itemNotFound
        }
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        
        return string
    }
    
    func delete(key: KeychainKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    func clear() throws {
        for key in KeychainKey.allCases {
            try? delete(key: key)
        }
    }
}

enum KeychainKey: String, CaseIterable {
    case accessToken = "accessToken"
    case refreshToken = "refreshToken"
    case userId = "userId"
    case biometricEnabled = "biometricEnabled"
}

enum KeychainError: LocalizedError {
    case invalidData
    case itemNotFound
    case saveFailed(OSStatus)
    case deleteFailed(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid keychain data"
        case .itemNotFound:
            return "Keychain item not found"
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        }
    }
}
