import Foundation
import CoreNFC
import Combine

enum NFCError: LocalizedError {
    case unavailable
    case sessionError(Error)
    case invalidTag
    
    var errorDescription: String? {
        switch self {
        case .unavailable: return "NFC is not available on this device."
        case .sessionError(let error): return error.localizedDescription
        case .invalidTag: return "This tag is not compatible."
        }
    }
}

class NFCManager: NSObject, ObservableObject {
    @Published var scannedTagID: String?
    @Published var error: NFCError?
    @Published var isScanning = false
    
    private var session: NFCNDEFReaderSession?
    
    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            self.error = .unavailable
            return
        }
        
        isScanning = true
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the NFC tag."
        session?.begin()
    }
    
    func stopScanning() {
        session?.invalidate()
        isScanning = false
    }
}

extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // For simple pairing, we can just use the fact that a tag was detected,
        // or extract a unique ID if available in the payload.
        // NDEF doesn't provide a hardware ID directly, but we can generate one or read a payload.
        
        DispatchQueue.main.async {
            // Success! We'll just generate a mock tag ID for now or use the first record's payload
            if let record = messages.first?.records.first {
                let payload = String(data: record.payload, encoding: .utf8) ?? UUID().uuidString
                self.scannedTagID = payload
            } else {
                self.scannedTagID = UUID().uuidString
            }
            self.isScanning = false
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false
            if let nfcError = error as? NFCReaderError, nfcError.code != .readerSessionInvalidationErrorUserCanceled {
                self.error = .sessionError(error)
            }
        }
    }
}
