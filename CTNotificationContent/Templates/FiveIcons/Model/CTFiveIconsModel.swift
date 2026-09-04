import Foundation

struct CTFiveIconsModel: Decodable {
    let pt_bg: String?
    let pt_bg_dark: String?

    let pt_title: String?
    let pt_title_clr: String?
    let pt_title_clr_dark: String?
    let pt_msg: String?
    let pt_msg_clr: String?
    let pt_msg_clr_dark: String?

    let pt_img1: String?
    let pt_img2: String?
    let pt_img3: String?
    let pt_img4: String?
    let pt_img5: String?

    let pt_dl1: String?
    let pt_dl2: String?
    let pt_dl3: String?
    let pt_dl4: String?
    let pt_dl5: String?

    let pt_img1_alt_text: String?
    let pt_img2_alt_text: String?
    let pt_img3_alt_text: String?
    let pt_img4_alt_text: String?
    let pt_img5_alt_text: String?

    var iconItems: [(imageURL: String, deepLink: String?)] {
        let raw: [(String?, String?)] = [
            (pt_img1, pt_dl1), (pt_img2, pt_dl2), (pt_img3, pt_dl3),
            (pt_img4, pt_dl4), (pt_img5, pt_dl5)
        ]
        return raw.compactMap { img, dl in
            guard let img = img, !img.isEmpty else { return nil }
            return (img, dl)
        }
    }

    var iconAltTexts: [String?] {
        let raw: [(String?, String?)] = [
            (pt_img1, pt_img1_alt_text),
            (pt_img2, pt_img2_alt_text),
            (pt_img3, pt_img3_alt_text),
            (pt_img4, pt_img4_alt_text),
            (pt_img5, pt_img5_alt_text),
        ]
        return raw.compactMap { img, alt in
            guard let img = img, !img.isEmpty else { return nil }
            return alt
        }
    }
}
