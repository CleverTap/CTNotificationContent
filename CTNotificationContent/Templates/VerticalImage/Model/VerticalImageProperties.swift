//
//  VerticalImageProperties.swift
//  CTNotificationContent
//

import Foundation

struct VerticalImageProperties: Decodable {
    // MARK: - Base
    let pt_title: String?
    let pt_msg: String?
    let pt_msg_summary: String?
    let pt_title_clr: String?
    let pt_msg_clr: String?
    let pt_bg: String?
    let pt_default_dl: String?
    let pt_title_clr_dark: String?
    let pt_msg_clr_dark: String?
    let pt_bg_dark: String?

    // MARK: - Expanded Media
    let pt_big_img: String?
    let pt_big_img_alt_text: String?
    let pt_gif: String?
    let pt_scale_type: String?

    // MARK: - Expanded Text Overlays
    let pt_text1: String?
    let pt_text1_clr: String?
    let pt_text1_clr_dark: String?
    let pt_text2: String?
    let pt_text2_clr: String?
    let pt_text2_clr_dark: String?

    // MARK: - Expanded Button
    let pt_btn_name: String?
    let pt_btn_dl: String?
    let pt_btn_style: String?
    let pt_btn_clr: String?
    let pt_btn_border_clr: String?
    let pt_btn_text_clr: String?
    let pt_btn_grad_clr1: String?
    let pt_btn_grad_clr2: String?
    let pt_btn_grad_dir: String?
    let pt_btn_border_radius: FlexibleDouble?
    let pt_btn_border_width: FlexibleDouble?

}

/// Decodes a numeric value that may arrive as an Int, Double, or numeric String.
struct FlexibleDouble: Decodable {
    let value: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = Double(intVal)
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let strVal = try? container.decode(String.self), let parsed = Double(strVal) {
            value = parsed
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                .init(codingPath: decoder.codingPath,
                      debugDescription: "Expected Int, Double, or numeric String")
            )
        }
    }
}
