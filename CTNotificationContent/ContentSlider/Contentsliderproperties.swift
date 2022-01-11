import Foundation
struct ContentSlider: Decodable {
    let orientation: String
    let showsPaging: Int
    let autoPlay: Int
    let autoDismiss: Int
    let items: [Contents]
    let type: String
}
struct Contents: Decodable {
    let imageUrl: String
    let caption: String
    let subcaption: String
    let actionUrl: String
    
}
