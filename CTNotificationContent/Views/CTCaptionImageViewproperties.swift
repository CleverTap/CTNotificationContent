import Foundation
struct CaptionView: Decodable {
    let orientation: String
    let showsPaging: Int
    let autoPlay: Int
    let autoDismiss: Int
    let items: [Images]
    let type: String
}
struct Images: Decodable {
    let imageUrl: String
    let caption: String
    let subcaption: String
    let actionUrl: String
    
}
