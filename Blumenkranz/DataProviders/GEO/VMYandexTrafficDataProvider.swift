import UIKit
import JavaScriptCore

enum VMYandexRegion: Int {
    case Moscow = 213
    case SaintPetersburg = 2
    case Krasnodar = 35
    case Volgograd = 38
    case Rostov = 39
    case Kazan = 43
    case NizhniyNovgorod = 47
    case Perm = 50
    case Samara = 51
    case Ekaterinburg = 54
    case Tumen = 55
    case Chelyabinsk = 56
    case Krasnoyarsk = 62
    case Irkutsk = 63
    case Novosibirsk = 65
    case Omsk = 66
    case Kiev = 143
    case Lvov = 144
    case Odessa = 145
    case Minsk = 157
    case Ufa = 172
    case Voronezh = 193
    case Saratov = 194
}

struct VMTraffic {
    var time: String
    var score: Int
    var status: String
}

let VMYandexTrafficErrorDomain = "ru.visualmyth.blumenkranz.VMYandexTrafficDataProvider"

enum VMYandexTrafficErrorCodes: Int {
    case Unknown = 0
    case NoResponse = 1
    case JSCore = 2
}

class VMYandexTrafficDataProvider {
    let providerURL = NSURL(string: "http://jgo.maps.yandex.net/trf/stat.js")
    var httpTask: NSURLSessionDataTask? = nil
    var updatedTime: Int = 0
    var providerData: [Int: VMTraffic] = [:]
    var errorCallback : ((NSError) -> Void)?
    var successCallback : (([Int: VMTraffic]) -> Void)?
    
    init() {
        httpTask = NSURLSession.sharedSession().dataTaskWithURL(providerURL!) {(data, response, error) in
            let code = (response as NSHTTPURLResponse).statusCode
            if error == nil && data != nil && code == 200 {
                var responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                if responseString?.length > 0 {
                    
                    let startRange = responseString?.rangeOfString("{")
                    let endRange = responseString?.rangeOfString("}", options: NSStringCompareOptions.BackwardsSearch)
                    let start = startRange!.location
                    let end = (endRange!.location - startRange!.location) + 1
                    responseString = responseString?.substringWithRange(NSMakeRange(start, end))
                    responseString = NSString(format: "var generateObj = %@;", responseString!)
                    
                    let jsContext: JSContext = JSContext()
                    jsContext.evaluateScript(responseString)
                    let jsObject: JSValue = jsContext.objectForKeyedSubscript("generateObj")
                    
                    if let jsonResponse = jsObject.toDictionary() {
                        
                        for jsonItem in jsonResponse {
                            let key: String = (jsonItem.0 as String)
                            if key == "timestamp" {
                                if let timestamp = (jsonItem.1 as? NSNumber) {
                                    self.updatedTime = timestamp.integerValue
                                }
                            }
                            
                            if key == "regions" {
                                for regionItem in (jsonItem.1 as NSArray) {
                                    if let regionId = (regionItem["regionId"] as String).toInt() {
                                        if let score = (regionItem["level"] as String?) {
                                            let time = regionItem["localTime"] as String
                                            let status = regionItem["style"] as String
                                            self.providerData[regionId] = VMTraffic(time: time, score: score.toInt()!, status: status)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if let successCallback = self.successCallback {
                            successCallback(self.providerData)
                        }
                        
                    } else {
                        if let errorCallback = self.errorCallback {
                            errorCallback(NSError(domain: VMYandexTrafficErrorDomain, code: VMYandexTrafficErrorCodes.JSCore.rawValue, userInfo: nil))
                        }
                    }
                    
                } else {
                    if let errorCallback = self.errorCallback {
                        errorCallback(NSError(domain: VMYandexTrafficErrorDomain, code: VMYandexTrafficErrorCodes.NoResponse.rawValue, userInfo: nil))
                    }
                }
            } else {
                if let errorCallback = self.errorCallback {
                    errorCallback(error)
                }
            }
        }
    }
    
    func request() {
        httpTask!.resume()
    }
    
    func trafficForRegion(region: VMYandexRegion) -> VMTraffic? {
        if let regionItem = providerData[region.rawValue] {
            return regionItem
        }
        return nil
    }
}