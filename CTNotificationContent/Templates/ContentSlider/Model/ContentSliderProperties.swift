//
//  ContentSliderProperties.swift
//  CleverTap-iOS-SDK
//
//  Created by Aishwarya Nanna on 26/08/22.
//

import Foundation

struct ContentSliderProperties: Decodable {
    let orientation: String
    let showsPaging: Int
    let autoPlay: Int
    let autoDismiss: Int
    let items: [ItemContent]
    let type: String
}

struct ItemContent: Decodable {
    let caption: String
    let subcaption: String
    let imageUrl: String
    let actionUrl: String
}

