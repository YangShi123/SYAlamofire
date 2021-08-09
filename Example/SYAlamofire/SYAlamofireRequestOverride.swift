//
//  SYNetworkingRequestOverride.swift
//

import SYAlamofire
import Alamofire
import SwiftyJSON

class SYAlamofireRequestOverride: SYAlamofireRequest {

    override func handleResponse(response: AFDataResponse<Any>) {
        switch response.result {
        case .failure(let error):
            if let closure = failedHandler {
                let e = SYAlamofireError(code: error.responseCode ?? -1, desc: error.localizedDescription)
                closure(e)
            }
        case .success(let json):
            let code = JSON(json)["code"].intValue
            if code == 200 {
                if let closure = successHandler {
                    closure(JSON(json)["data"])
                }
            } else {
                if let closure = failedHandler {
                    let e = SYAlamofireError(code: code, desc: JSON(json)["msg"].rawValue as! String)
                    closure(e)
                }
            }
        }
        super.clearReference()
    }
}
