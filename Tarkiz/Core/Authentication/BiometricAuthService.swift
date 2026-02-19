import LocalAuthentication
import Foundation

protocol BiometricAuthService {
    func canAuthenticate() -> Bool
    func authenticate() async throws -> Bool
    var biometricType: BiometricType { get }
}

enum BiometricType {
    case none
    case touchID
    case faceID
    case opticID // For Vision Pro if needed
}

class BiometricAuthServiceImpl: BiometricAuthService {
    private let context = LAContext()
    private var error: NSError?
    
    func canAuthenticate() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    var biometricType: BiometricType {
        guard canAuthenticate() else { return .none }
        switch context.biometryType {
        case .touchID: return .touchID
        case .faceID: return .faceID
        case .opticID: return .opticID
        default: return .none
        }
    }
    
    func authenticate() async throws -> Bool {
        guard canAuthenticate() else {
            throw BiometricError.notAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let reason = "Authenticate to access Tarkiz"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else {
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
}

enum BiometricError: Error {
    case notAvailable
    case failed
}
