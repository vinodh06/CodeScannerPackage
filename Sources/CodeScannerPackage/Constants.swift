//
//  File.swift
//  
//
//  Created by vinodh kumar on 10/05/23.
//

import Foundation

enum Constants: String, Functionable {
    case cameraFailureTitle = "Scanning not supported."
    case cameraFailureDescription = """
    Your device does not support scanning a code from an item. Please use a device with a camera.
    """
    case cameraFailureButtonTitle = "OK"
}
