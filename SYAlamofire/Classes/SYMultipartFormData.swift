//
//  SYMultipartFormData.swift
//

import Foundation

/// 常见数据类型的`MIME Type`
public enum SYFormDataMimeType: String {
    case JPEG = "image/jpeg"
    case PNG = "image/png"
    case GIF = "image/gif"
    case HEIC = "image/heic"
    case HEIF = "image/heif"
    case WEBP = "image/webp"
    case TIF = "image/tif"
    case JSON = "application/json"
}

public class SYMultipartFormData {
    /// The data to be encoded and appended to the form data.
    let data: Data
    /// Name to associate with the `Data` in the `Content-Disposition` HTTP header.
    let name: String
    /// Filename to associate with the `Data` in the `Content-Disposition` HTTP header.
    let fileName: String
    /// The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types
    /// see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
    let mimeType: String

    /// Create SYMultipartFormData
    /// - Parameters:
    ///   - data: The data to be encoded and appended to the form data.
    ///   - name: The name to be associated with the specified data.
    ///   - fileName: The filename to be associated with the specified data.
    ///   - mimeType: The MIME type of the specified data. eg: image/jpeg
    init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }

    /// Create SYMultipartFormData
    /// - Parameters:
    ///   - data: The data to be encoded and appended to the form data.
    ///   - name: The name to be associated with the specified data.
    ///   - fileName: The filename to be associated with the specified data.
    ///   - type: The MIME type of the specified data. eg: image/jpeg
    convenience init(data: Data, name: String, fileName: String, type: SYFormDataMimeType) {
        self.init(data: data, name: name, fileName: fileName, mimeType: type.rawValue)
    }
}

