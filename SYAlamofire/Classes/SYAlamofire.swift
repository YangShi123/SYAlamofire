//
//  SYAlamofire.swift.
//

import Alamofire
import SwiftyJSON

public typealias SYSuccessClosure = (_ json: Any) -> Void

public typealias SYFailedClosure = (_ error: SYAlamofireError) -> Void

public typealias SYProgressClosure = (Progress) -> Void

public let NET = SYAlamofire.shared

public class SYAlamofire {
    /// 单例
    public static let shared = SYAlamofire()
    /// 任务队列
    private(set) var taskQueue = [SYAlamofireRequest]()
    
    var sessionManager: Alamofire.Session!
    
    var reachability: NetworkReachabilityManager?
    /// 网络状态
    public var networkStatus: SYReachabilityStatus = .unknown
    /// 全局headers
    private var globalHeaders: HTTPHeaders? = []
    /// 超时时间
    private var timeoutInterval: TimeInterval?
    /// 自己解析response的类，需继承自SYAlamofireRequest
    private var networkingRequest: SYAlamofireRequest.Type?
    
    private init() {
        let config = URLSessionConfiguration.af.default
        sessionManager = Alamofire.Session(configuration: config)
    }
    
    // MARK: -配置全局headers和超时时间
    public func config(headers: HTTPHeaders? = nil,
                       timeoutInterval: TimeInterval? = nil,
                       customNetworkingRequest: SYAlamofireRequest.Type? = nil) {
        self.globalHeaders = headers
        self.timeoutInterval = timeoutInterval
        self.networkingRequest = customNetworkingRequest
    }
    
    private func request(url: String,
                         method: HTTPMethod = .get,
                         parameters: [String: Any]?,
                         body: [String: Any]? = nil,
                         header: HTTPHeader? = nil,
                         encoding: ParameterEncoding = URLEncoding.default,
                         timeoutInterval: TimeInterval? = nil) -> SYAlamofireRequest {
        
        let task: SYAlamofireRequest
        
        /// 如果有传入自定义的NetworkingRequest，就用传入的
        if networkingRequest != nil {
            task = networkingRequest!.init()
        } else {
            task = SYAlamofireRequest()
        }
        
        if let tempHeader = header { self.globalHeaders?.add(tempHeader) }
        
        task.request = sessionManager.request(url,
                                              method: method,
                                              parameters: parameters,
                                              encoding:encoding,
                                              headers: self.globalHeaders){ (request) in
            /// 设置全局超时时间
            if let time = self.timeoutInterval { request.timeoutInterval = time }
            /// 设置单个接口超时时间
            if let time = timeoutInterval { request.timeoutInterval = time }
            /// body 传参
            if let params = body { request.httpBody = JSON(params).description.data(using: .utf8) }
        }.responseJSON(completionHandler: { [weak self] response in
            task.handleResponse(response: response)
            
            if let index = self?.taskQueue.firstIndex(of: task) { self?.taskQueue.remove(at: index) }
        })
        taskQueue.append(task)
        return task
    }
    
    private func upload(url: String,
                        method: HTTPMethod = .post,
                        parameters: [String: String]?,
                        datas: [SYMultipartFormData],
                        header: HTTPHeader? = nil) -> SYAlamofireRequest {
        let task: SYAlamofireRequest
        
        /// 如果有传入自定义的NetworkingRequest，就用传入的
        if networkingRequest != nil {
            task = networkingRequest!.init()
        } else {
            task = SYAlamofireRequest()
        }
        
        if let tempHeader = header { self.globalHeaders?.add(tempHeader) }
        
        task.request = sessionManager.upload(multipartFormData: { (multipartData) in
            // 1.参数 parameters
            if let parameters = parameters {
                for p in parameters {
                    multipartData.append(p.value.data(using: .utf8)!, withName: p.key)
                }
            }
            // 2.数据 datas
            for d in datas {
                multipartData.append(d.data, withName: d.name, fileName: d.fileName, mimeType: d.mimeType)
            }
        }, to: url, method: method, headers: self.globalHeaders).uploadProgress(queue: .main, closure: { (progress) in
            task.handleProgress(progress: progress)
        }).responseJSON(completionHandler: { [weak self] response in
            task.handleResponse(response: response)
            
            if let index = self?.taskQueue.firstIndex(of: task) {
                self?.taskQueue.remove(at: index)
            }
        })
        taskQueue.append(task)
        return task
    }
    
    // MARK: -取消所有接口
    public func cancleAllRequests(completingOnQueue queue: DispatchQueue = .main, completion: (() -> Void)? = nil) {
        sessionManager.cancelAllRequests(completingOnQueue: queue, completion: completion)
    }
}

extension SYAlamofire {
    
    // MARK: -GET
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 请求参数
    ///   - header: 请求头（额外添加）
    ///   - timeoutInterval: 接口请求超时时间，默认60
    /// - Returns: DataRequest
    @discardableResult
    public func GET(url: String,
                    parameters: [String: Any]? = nil,
                    header: HTTPHeader? = nil,
                    timeoutInterval: TimeInterval? = nil) ->SYAlamofireRequest {
        request(url: url, method: .get, parameters: parameters, header: header, timeoutInterval: timeoutInterval)
    }
    
    // MARK: -POST
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 请求参数
    ///   - body: body传参参数
    ///   - header: 请求头（额外添加）
    ///   - timeoutInterval: 接口请求超时时间，默认60
    /// - Returns: DataRequest
    @discardableResult
    public func POST(url: String,
                     parameters: [String: Any]? = nil,
                     body: [String: Any]? = nil,
                     header: HTTPHeader? = nil,
                     timeoutInterval: TimeInterval? = nil) ->SYAlamofireRequest {
        request(url: url, method: .post, parameters: parameters, body: body, header: header,timeoutInterval: timeoutInterval)
    }
    
    @discardableResult
    public func UPLOAD(url: String,
                       parameters: [String: String]? = nil,
                       datas: [SYMultipartFormData]? = nil,
                       header: HTTPHeader? = nil) ->SYAlamofireRequest {
        upload(url: url, method: .post, parameters: parameters, datas: datas!, header: header)
    }
}
