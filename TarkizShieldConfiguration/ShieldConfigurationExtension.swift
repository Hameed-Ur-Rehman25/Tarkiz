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
        // Fallback colors if the named ones aren't shared with the extension target
        let primaryColor = UIColor(named: "AppPrimaryColor") ?? UIColor.systemBlue
        let bgColor = UIColor(named: "BackgroundColor")?.withAlphaComponent(0.9) ?? UIColor.systemBackground.withAlphaComponent(0.9)
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: bgColor,
            icon: UIImage(named: "NFCLogo") ?? UIImage(systemName: "shield.fill"),
            title: ShieldConfiguration.Label(
                text: "Blocked by Tarkiz",
                color: primaryColor
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Stay focused on your goals. This app is currently restricted by Tarkiz to help you stay present and productive.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Dismiss",
                color: .white
            ),
            primaryButtonBackgroundColor: primaryColor,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Unlock with NFC",
                color: primaryColor
            )
        )
    }
}
