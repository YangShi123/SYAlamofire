//
//  SYAlamofireRequest.swift.
//

import Alamofire
import SwiftyJSON

 open class SYAlamofireRequest: Equatable {
    
    var request: Alamofire.Request?
    
    public var successHandler: SYSuccessClosure?
    
    public var failedHandler: SYFailedClosure?
    
    private var progressHandler: SYProgressClosure?
    
    open func handleResponse(response: AFDataResponse<Any>) {
        switch response.result {
        case .failure(let error):
            if let closure = failedHandler {
                let e = SYAlamofireError(code: error.responseCode ?? -1, desc: error.localizedDescription)
                closure(e)
            }
        case .success(let json):
            if let closure = successHandler {
                closure((JSON(json)))
            }
        }
        clearReference()
    }
    
    func handleProgress(progress: Foundation.Progress) {
        if let closure = progressHandler {
            closure(progress)
        }
    }
    
    @discardableResult
    public func success(_ closure: @escaping SYSuccessClosure) -> Self {
        successHandler = closure
        return self
    }
    
    @discardableResult
    public func failed(_ closure: @escaping SYFailedClosure) -> Self {
        failedHandler = closure
        return self
    }
    
    @discardableResult
    public func progress(closure: @escaping SYProgressClosure) -> Self {
        progressHandler = closure
        return self
    }
    
    func cancel() {
        request?.cancel()
    }
    
    /// Free memory
    public func clearReference() {
        successHandler = nil
        failedHandler = nil
        progressHandler = nil
    }
    
    /// 便于子类使用
    required public init() {}
}

/// Equatable for `HWNetworkRequest`
extension SYAlamofireRequest {
    /// Returns a Boolean value indicating whether two values are equal.
    public static func == (lhs: SYAlamofireRequest, rhs: SYAlamofireRequest) -> Bool {
        return lhs.request?.id == rhs.request?.id
    }
}
