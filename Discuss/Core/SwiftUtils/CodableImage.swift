import Foundation
import UIKit

@propertyWrapper
public struct CodableImage: Codable {
    var image: UIImage?

    public enum CodingKeys: String, CodingKey {
        case image
    }

    public init(image: UIImage?) {
        self.image = image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let data = try container.decodeIfPresent(Data.self, forKey: CodingKeys.image) else {
            self.image = nil
            return
        }

        guard let image = UIImage(data: data) else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.image, in: container, debugDescription: "Decoding image failed")
        }

        self.image = image
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let image, let data = image.resizeImage(targetSize: .init(width: 512, height: 512)).jpegData(compressionQuality: 0.8) {
            try container.encode(data, forKey: CodingKeys.image)
        } else {
            try container.encodeNil(forKey: CodingKeys.image)
        }
    }

    public init(wrappedValue: UIImage?) {
        self.init(image: wrappedValue)
    }

    public var wrappedValue: UIImage? {
        get { image }
        set { image = newValue }
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
