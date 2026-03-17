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

}
