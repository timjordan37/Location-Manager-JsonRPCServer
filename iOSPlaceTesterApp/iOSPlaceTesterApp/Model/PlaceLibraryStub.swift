import Foundation

/**
 * Copyright 2019 Tim Jordan,
 *
 * This software is the intellectual property of the author, and can not be
 * distributed, used, copied, or reproduced, in whole or in part, for any
 * purpose, commercial or otherwise. The author grants the ASU Software
 * Engineering program the right to copy, execute, and evaluate this work for
 * the purpose of determining performance of the author in coursework, and for
 * Software Engineering program evaluation, so long as this copyright and
 * right-to-use statement is kept in-tact in such use. All other uses are
 * prohibited and reserved to the author.<br>
 * <br>
 *
 * SER 423 see http://quay.poly.asu.edu/Mobile/
 * @author Tim Jordan mailto:tsjorda1@asu.edu
 *         Software Engineering
 * @version November 24, 2019
 */

public class PlaceLibraryStub {
  
  static var id:Int = 0
  
  var url:String
  
  init(urlString: String){
    self.url = urlString
  }
  
  func asyncHttpPostJSON(url: String,  data: Data,
                         completion: @escaping (String, String?) -> Void) {
    let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
    request.httpMethod = "POST"
    request.addValue("application/json",forHTTPHeaderField: "Content-Type")
    request.addValue("application/json",forHTTPHeaderField: "Accept")
    request.httpBody = data
    httpSendRequest(request: request, callback: completion)
  }

  func httpSendRequest(request: NSMutableURLRequest,
                       callback: @escaping (String, String?) -> Void) {
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) {
      (data, response, error) -> Void in
      if (error != nil) {
        print("There was an error in the httpSendRequest method")
        callback("", error!.localizedDescription)
      } else {
        DispatchQueue.main.async(execute: {callback(NSString(data: data!,
                                                             encoding: String.Encoding.utf8.rawValue)! as String, nil)})
      }
    }
    task.resume()
  }
  
  private func prepareAsyncHttpPostJSON(params: [Any], methodName: String,
                                callback:@escaping (String, String?) -> Void) -> Bool {
    var ret:Bool = false
    PlaceLibraryStub.id = PlaceLibraryStub.id + 1
    do {
      let dict:[String:Any] = ["jsonrpc":"2.0", "method":methodName, "params":params, "id":PlaceLibraryStub.id]
      let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
      self.asyncHttpPostJSON(url:self.url, data:reqData, completion:callback)
      ret = true
    } catch let error as NSError {
      print(error)
    }
    return ret
  }
  
  func get(name: String, callback:@escaping (String, String?) -> Void) -> Bool{
    return prepareAsyncHttpPostJSON(params: [name], methodName: "get", callback: callback)
  }
  
  func getNames(callback:@escaping(String, String?) -> Void) -> Bool{
    return prepareAsyncHttpPostJSON(params: [], methodName: "getNames", callback: callback)
  }
  
  func add(placeDescription: PlaceDescription, callback:@escaping(String, String?) -> Void) -> Bool {
    return prepareAsyncHttpPostJSON(params: [placeDescription.toJsonObj()], methodName: "add", callback: callback)
  }
  
  func remove(name: String, callback:@escaping (String, String?) -> Void) -> Bool{
    return prepareAsyncHttpPostJSON(params: [name], methodName: "remove", callback: callback)
  }
  
  func getStringArrayResult(jsonRPCResult:String) -> [String] {
    var ret:[String] = [String]()
    if let data:NSData = jsonRPCResult.data(using:String.Encoding.utf8) as NSData?{
      do{
        let dict = try JSONSerialization.jsonObject(with: data as Data,options:.mutableContainers) as?[String:AnyObject]
        let resArr:[String] = dict?["result"] as! [String]
        ret = resArr
      } catch {
        print("unable to convert Json to a dictionary")
      }
    }
    return ret
  }
  
  func getPlaceDescriptionResult(jsonRPCResult:String) -> PlaceDescription {
    var ret:PlaceDescription = PlaceDescription()
    if let data:NSData = jsonRPCResult.data(using:String.Encoding.utf8) as NSData?{
      do{
        let dict = try JSONSerialization.jsonObject(with: data as Data,options:.mutableContainers) as?[String:AnyObject]
        let aPlace:PlaceDescription = PlaceDescription(jsonObjDict: dict?["result"] as? [String:Any])
        ret = aPlace
      } catch {
        print("unable to convert Json to a dictionary")
      }
    }
    return ret
  }
}
