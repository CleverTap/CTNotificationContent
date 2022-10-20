//
//  ProductDisplayProperties.swift
//  CTNotificationContent
//
//  Created by Aishwarya Nanna on 22/03/22.
//

import Foundation
@objc public class ProductDisplayProperties: NSObject, Decodable {
    @objc public let pt_title: String?
    @objc public let pt_msg: String?
    @objc public let pt_subtitle: String?
    @objc public let pt_img1: String
    @objc public let pt_img2: String
    @objc public let pt_img3: String?
    @objc public let pt_bt1: String
    @objc public let pt_bt2: String
    @objc public let pt_bt3: String?
    @objc public let pt_st1: String
    @objc public let pt_st2: String
    @objc public let pt_st3: String?
    @objc public let pt_dl1: String
    @objc public let pt_dl2: String
    @objc public let pt_dl3: String?
    @objc public let pt_price1: String
    @objc public let pt_price2: String
    @objc public let pt_price3: String?
    @objc public let pt_bg: String?
    @objc public let pt_product_display_action: String
    @objc public let pt_product_display_linear: String?
    @objc public let pt_product_display_action_clr: String?
    @objc public let pt_title_clr: String?
    @objc public let pt_msg_clr: String?
}
