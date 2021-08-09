//
//  SYAlamofireError.swift
//

/// 请求的错误反馈
public class SYAlamofireError {
    /// 错误码
    public var code = -1
    /// 错误描述
    public var localizedDescription: String

    public init(code: Int, desc: String) {
        self.code = code
        self.localizedDescription = desc
    }
}
