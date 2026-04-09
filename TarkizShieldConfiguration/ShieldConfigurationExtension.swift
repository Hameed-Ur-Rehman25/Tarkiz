//
//  ShieldConfigurationExtension.swift
//  TarkizShieldConfiguration
//
//  Created by Hameed on 09/04/2026.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    // Explicitly nonisolated initializer to match superclass requirements for extensions
    nonisolated override init() {
        super.init()
    }

    nonisolated override func configuration(shielding application: Application) -> ShieldConfiguration {
        return createTarkizShieldConfig()
    }
    
    nonisolated override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return createTarkizShieldConfig()
    }
    
    nonisolated override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return createTarkizShieldConfig()
    }
    
    nonisolated override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return createTarkizShieldConfig()
    }
    
    private func createTarkizShieldConfig() -> ShieldConfiguration {
        // Hardcoded Tarkiz Branding (Sage Green/Premium Focus)
        // components: R: 0.486, G: 0.624, B: 0.553
        let tarkizPrimary = UIColor(red: 0.486, green: 0.624, blue: 0.553, alpha: 1.0)
        let tarkizBackground = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.85) // Dark premium feel

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: tarkizBackground,
            icon: UIImage(named: "NFCLogo") ?? UIImage(systemName: "shield.fill"),
            title: ShieldConfiguration.Label(
                text: "Blocked by Tarkiz",
                color: tarkizPrimary
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Stay focused on your goals. This app is currently restricted by Tarkiz to help you stay present and productive.",
                color: .white.withAlphaComponent(0.8)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Dismiss",
                color: .white
            ),
            primaryButtonBackgroundColor: tarkizPrimary,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Unlock with NFC",
                color: tarkizPrimary
            )
        )
    }
}
