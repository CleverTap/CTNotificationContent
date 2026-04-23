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
    let pt_bg_dark: String?
    let pt_chrono_title_clr: String?
    let pt_chrono_title_clr_dark: String?
    let pt_timer_threshold: Int?
    let pt_timer_end: Int?
    let pt_title_clr: String?
    let pt_title_clr_dark: String?
    let pt_msg_clr: String?
    let pt_msg_clr_dark: String?
    let pt_big_img_alt_text: String?
    let pt_big_img_alt_alt_text: String?
    let pt_gif: String?
    let pt_gif_alt: String?

    // Timer box background
    let pt_timer_bg: String?
    let pt_timer_bg_dark: String?
    let pt_timer_bg_gradient_start: String?
    let pt_timer_bg_gradient_end: String?
    let pt_timer_bg_gradient_start_dark: String?
    let pt_timer_bg_gradient_end_dark: String?
    let pt_timer_bg_gradient_angle: String?

    // Timer box gradient type ("linear" | "radial", default "linear")
    let pt_timer_bg_gradient_type: String?

    // Timer box border
    let pt_timer_border_color: String?
    let pt_timer_border_color_dark: String?
    let pt_timer_border_width: String?
    let pt_timer_border_radius: String?

    // Timer text color
    let pt_timer_text_clr: String?
    let pt_timer_text_clr_dark: String?

    enum CodingKeys: String, CodingKey {
        case pt_title, pt_title_alt, pt_msg, pt_msg_alt, pt_msg_summary, pt_dl1, pt_big_img, pt_big_img_alt, pt_bg, pt_bg_dark, pt_chrono_title_clr, pt_chrono_title_clr_dark, pt_timer_threshold, pt_timer_end, pt_title_clr, pt_title_clr_dark, pt_msg_clr, pt_msg_clr_dark, pt_big_img_alt_text, pt_big_img_alt_alt_text, pt_gif, pt_gif_alt
        case pt_timer_bg, pt_timer_bg_dark
        case pt_timer_bg_gradient_start, pt_timer_bg_gradient_end
        case pt_timer_bg_gradient_start_dark, pt_timer_bg_gradient_end_dark
        case pt_timer_bg_gradient_angle
        case pt_timer_bg_gradient_type
        case pt_timer_border_color, pt_timer_border_color_dark
        case pt_timer_border_width, pt_timer_border_radius
        case pt_timer_text_clr, pt_timer_text_clr_dark
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
        pt_bg_dark = try container.decodeIfPresent(String.self, forKey: .pt_bg_dark)
        pt_chrono_title_clr = try container.decodeIfPresent(String.self, forKey: .pt_chrono_title_clr)
        pt_chrono_title_clr_dark = try container.decodeIfPresent(String.self, forKey: .pt_chrono_title_clr_dark)
        pt_title_clr = try container.decodeIfPresent(String.self, forKey: .pt_title_clr)
        pt_msg_clr = try container.decodeIfPresent(String.self, forKey: .pt_msg_clr)
        pt_title_clr_dark = try container.decodeIfPresent(String.self, forKey: .pt_title_clr_dark)
        pt_msg_clr_dark = try container.decodeIfPresent(String.self, forKey: .pt_msg_clr_dark)
        pt_big_img_alt_text = try container.decodeIfPresent(String.self, forKey: .pt_big_img_alt_text)
        pt_big_img_alt_alt_text = try container.decodeIfPresent(String.self, forKey: .pt_big_img_alt_alt_text)
        pt_gif = try container.decodeIfPresent(String.self, forKey: .pt_gif)
        pt_gif_alt = try container.decodeIfPresent(String.self, forKey: .pt_gif_alt)

        pt_timer_bg = try container.decodeIfPresent(String.self, forKey: .pt_timer_bg)
        pt_timer_bg_dark = try container.decodeIfPresent(String.self, forKey: .pt_timer_bg_dark)
        pt_timer_bg_gradient_start = try container.decodeIfPresent(String.self, forKey: .pt_timer_bg_gradient_start)
        pt_timer_bg_gradient_end = try container.decodeIfPresent(String.self, forKey: .pt_timer_bg_gradient_end)
        pt_timer_bg_gradient_start_dark = try container.decodeIfPresent(String.self, forKey: .pt_timer_bg_gradient_start_dark)
        pt_timer_bg_gradient_end_dark = try container.decodeIfPresent(String.self, forKey: .pt_timer_bg_gradient_end_dark)
        pt_timer_bg_gradient_angle = try container.decodeIfPresent(String.self, forKey: .pt_timer_bg_gradient_angle)
        pt_timer_bg_gradient_type = try container.decodeIfPresent(String.self, forKey: .pt_timer_bg_gradient_type)
        pt_timer_border_color = try container.decodeIfPresent(String.self, forKey: .pt_timer_border_color)
        pt_timer_border_color_dark = try container.decodeIfPresent(String.self, forKey: .pt_timer_border_color_dark)
        pt_timer_border_width = try container.decodeIfPresent(String.self, forKey: .pt_timer_border_width)
        pt_timer_border_radius = try container.decodeIfPresent(String.self, forKey: .pt_timer_border_radius)
        pt_timer_text_clr = try container.decodeIfPresent(String.self, forKey: .pt_timer_text_clr)
        pt_timer_text_clr_dark = try container.decodeIfPresent(String.self, forKey: .pt_timer_text_clr_dark)

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
