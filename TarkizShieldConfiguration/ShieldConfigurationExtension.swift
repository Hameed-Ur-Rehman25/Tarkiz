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
        // Premium Tarkiz Aesthetic (Emerald Sage & Dark Glass)
        let tarkizEmerald = UIColor(red: 0.35, green: 0.55, blue: 0.45, alpha: 1.0)
        let darkGlass = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 0.9)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: darkGlass,
            icon: UIImage(named: "NFCLogo") ?? UIImage(systemName: "shield.fill"),
            title: ShieldConfiguration.Label(
                text: "Blocked by Tarkiz",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "This app is restricted during Salah time. Focus on your prayer with peace and presence.",
                color: .white.withAlphaComponent(0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Dismiss",
                color: .white
            ),
            primaryButtonBackgroundColor: tarkizEmerald,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Unlock with NFC Tag",
                color: tarkizEmerald
            )
        )
    }
}
