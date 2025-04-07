//
//  CultureDI+DeeplinkHandler.swift
//  OSCACultureUI
//
//  Created by Stephan Breidenbach on 21.02.23.
//

import Foundation
import OSCAEssentials

extension OSCACultureUI.DIContainer {
  var deeplinkScheme: String {
    return self
      .dependencies
      .moduleConfig
      .deeplinkScheme
  }// end var deeplinkScheme
}
