//
//  TimerTemplateProperties.swift
//  CleverTap-iOS-SDK
//
//  Created by Aishwarya Nanna on 26/08/22.
//

import Foundation

struct TimerTemplateProperties: Decodable {
    let pt_title: String?
    let pt_title_alt: String?
    let pt_msg: String?
    let pt_msg_alt: String?
    let pt_msg_summary: String?
    let pt_dl1: String?
    let pt_big_img: String?
    let pt_big_img_alt: String?
    let pt_bg: String?
    let pt_chrono_title_clr: String?
    let pt_timer_threshold: Int?
    let pt_timer_end: Int?
    let pt_title_clr: String?
    let pt_msg_clr: String?
    
    enum CodingKeys: String, CodingKey {
        case pt_title, pt_title_alt, pt_msg, pt_msg_alt, pt_msg_summary, pt_dl1, pt_big_img, pt_big_img_alt, pt_bg, pt_chrono_title_clr, pt_timer_threshold, pt_timer_end, pt_title_clr, pt_msg_clr
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        pt_title = try container.decodeIfPresent(String.self, forKey: .pt_title)
        pt_title_alt = try container.decodeIfPresent(String.self, forKey: .pt_title_alt)
        pt_msg = try container.decodeIfPresent(String.self, forKey: .pt_msg)
        pt_msg_alt = try container.decodeIfPresent(String.self, forKey: .pt_msg_alt)
        pt_msg_summary = try container.decodeIfPresent(String.self, forKey: .pt_msg_summary)
        pt_dl1 = try container.decodeIfPresent(String.self, forKey: .pt_dl1)
        pt_big_img = try container.decodeIfPresent(String.self, forKey: .pt_big_img)
        pt_big_img_alt = try container.decodeIfPresent(String.self, forKey: .pt_big_img_alt)
        pt_bg = try container.decodeIfPresent(String.self, forKey: .pt_bg)
        pt_chrono_title_clr = try container.decodeIfPresent(String.self, forKey: .pt_chrono_title_clr)
        pt_title_clr = try container.decodeIfPresent(String.self, forKey: .pt_title_clr)
        pt_msg_clr = try container.decodeIfPresent(String.self, forKey: .pt_msg_clr)
        
        // Value for pt_timer_threshold and pt_timer_end key can be Int or String if received from JSON data or individual keys respectively, so checked for both case if present or else nil.
        var thresholdValue: Int? = nil
        do {
            if let intValue = try container.decodeIfPresent(Int.self, forKey: .pt_timer_threshold) {
                thresholdValue = intValue
            }
        } catch {
            if let stringValue = try container.decodeIfPresent(String.self, forKey: .pt_timer_threshold) {
                thresholdValue = Int(stringValue)
            }
        }
        pt_timer_threshold = thresholdValue
        
        var timerEndValue: Int? = nil
        do {
            if let intValue = try container.decodeIfPresent(Int.self, forKey: .pt_timer_end) {
                timerEndValue = intValue
            }
        } catch {
            if let stringValue = try container.decodeIfPresent(String.self, forKey: .pt_timer_end) {
                timerEndValue = Int(stringValue)
            }
        }
        pt_timer_end = timerEndValue
    }
}
