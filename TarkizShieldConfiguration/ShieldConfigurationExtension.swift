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
    
    private let appPrimaryColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0) // Matching AppPrimaryColor

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return createTarkizShieldConfig()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return createTarkizShieldConfig()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return createTarkizShieldConfig()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return createTarkizShieldConfig()
    }
    
    private func createTarkizShieldConfig() -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(named: "BackgroundColor")?.withAlphaComponent(0.9) ?? .systemBackground,
            icon: UIImage(named: "NFCLogo"),
            title: ShieldConfiguration.Label(
                text: "Blocked by Tarkiz",
                color: UIColor(named: "AppPrimaryColor") ?? .systemBlue
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Stay focused on your goals. This app is currently restricted by Tarkiz to help you stay present and productive.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Dismiss",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(named: "AppPrimaryColor") ?? .systemBlue,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Unlock with NFC",
                color: UIColor(named: "AppPrimaryColor") ?? .systemBlue
            )
        )
    }
}
