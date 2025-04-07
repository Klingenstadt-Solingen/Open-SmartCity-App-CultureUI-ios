//
//  BeaconSearchFlow+OSCADeeplinkHandeble.swift
//  OSCACultureUI
//
//  Created by Stephan Breidenbach on 21.02.23.
//

import Foundation
import OSCAEssentials

extension BeaconSearchFlow: OSCADeeplinkHandeble{
  ///```console
  ///xcrun simctl openurl booted \
  /// "solingen://art/"
  /// ```
  public func canOpenURL(_ url: URL) -> Bool {
    let deeplinkScheme: String = dependencies
      .deeplinkScheme
    return url.absoluteString.hasPrefix("\(deeplinkScheme)://art")
  }// end public func canOpenURL
  
  public func openURL(_ url: URL,
                      onDismissed:(() -> Void)?) throws -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function): urls: \(url.absoluteString)")
#endif
    guard canOpenURL(url)
    else { return }
    showBeaconSearch( animated: true,
                      onDismissed: onDismissed )
  }// end public func openURL
}// end extension final class BeaconSearchFlow
