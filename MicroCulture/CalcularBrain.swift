//
//  CalcularBrain.swift
//  MicroCulture
//
//  Created by wang tie on 17/2/13.
//  Copyright © 2017年 developer. All rights reserved.
//

import Foundation


/*
 关系】f:父,m:母,h:夫,w:妻,s:子,d:女,xb:兄弟,ob:兄,lb:弟,xs:姐妹,os:姐,ls:妹
 
 【修饰符】 1:男性,0:女性,&o:年长,&l:年幼,#:隔断,[a|b]:并列
 */


class CalcularBrain {
    
    
    
    // 称谓集合
    lazy var chengWeiData:Dictionary <String,Array<Any>> = {
        var data = Dictionary<String,Array<Any>>()
        let filePath = Bundle.main.path(forResource: "data", ofType: "json")
        let fileUrl = URL.init(fileURLWithPath: filePath!, isDirectory: true)
        let fileData = try? Data(contentsOf: fileUrl, options: [])
        if let fileData = fileData {
            data = try! JSONSerialization.jsonObject(with: fileData, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Array<Any>>
        }
        return data
    }()
    
    // 关系链集合
    lazy var relationShipData:Array<Dictionary<String,String>> = {
        var relationShipData = Array<Dictionary<String,String>>()
        let filePath = Bundle.main.path(forResource: "filter", ofType: "json")
        let fileUrl = URL.init(fileURLWithPath: filePath!, isDirectory: true)
        let fileData = try? Data(contentsOf: fileUrl, options: [])
        if let fileData = fileData {
            let data:AnyObject! = try? JSONSerialization.jsonObject(with: fileData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject!
            if let data = data {
                relationShipData = data["filter"] as! Array<Dictionary<String, String>>
            }
            
        }
        return relationShipData
    }()
    
    // 称谓转换成关联字符
    private func selectors(str:String) -> String? {
        var lists = str.components(separatedBy: "的")
        var result = String()
        //var match = true
        while lists.count > 0 {
            let name = lists.first
            lists.removeFirst()
            var arr = String()
            var has = false
            for (key,value) in chengWeiData {
                let isContain = value.contains {
                    if let f = $0 as? String {
                        return f == name
                    }
                    return false
                }
                
                if isContain && (key != "") { // 过滤 “我”
                    arr = key
                    has = true
                }
            }

            if has{
                result.append(",\(arr)")
            }
            
        }
        //result.remove(at: result.startIndex)
        return result
    }
    
    
    struct RegexHelper {
        let regex: NSRegularExpression
        init(_ pattern: String) throws {
            try regex = NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        }
        func replace(input:String,template:String) -> String {
            return regex.stringByReplacingMatches(in: input, options: [], range: NSMakeRange(0, input.utf16.count), withTemplate: template);
        }
    }
    
    struct FilteHelper {
        var result: Array<String>
        let selector: String
        var hash = Set<String>()
        var relationShipData:Array<Dictionary<String,String>>
        init(_ input: String,res:Array<Dictionary<String,String>>) {
            result = Array()
            selector = input
            relationShipData = res
        }
        mutating func filter(input:String){
            var sel = input
            var s = String()
            if (!hash.contains(sel)){
                hash.insert(sel)
                var status = true
                repeat{
                    s = sel
                    for item in relationShipData {
                        let exp = item["exp"]
                        let str = item["str"]
                        let replacer: RegexHelper = try! RegexHelper(exp!)
                        sel = replacer.replace(input: sel, template: str!)
                        print(sel)
                        if sel.contains("#"){
                            let sep = sel.components(separatedBy: "#")
                            for key in sep {
                                //filterSelectors(selector: key)
                                print(key)
                                filter(input: key)
                            }
                            status = false
                            break
                        }
                    }
                }while s != sel
                
                if (status){
                    result.append(sel)
                }
            }
        }
        
        mutating func filterSelectors(){
            filter(input:selector)
        }
    }
    
     private func getData(d:String) -> Array<String>{
        var res = Array<String>()
        let filter =  "[olx]"
        let replacer: RegexHelper = try! RegexHelper(filter)
        for (key,values) in chengWeiData {
            let newkey = replacer.replace(input: key, template: "")
            if (newkey == d){
                let value = values.first as! String
                res.append(value)
            }
        }
        return res
    }
    
    
    //return valueByKey(key: newkey)
    private func valueByKey(key:String) -> String? {
        
        let values = chengWeiData[key]
        if let values = values {
            let value = values.first as! String
            return value
        }

        return nil
    }
    
   private func dataValueByKeys(result:Array<String>) -> String? {
        var dataValue = String()
        var array = Array<String>()
        for key in result {
            print(key)
            var temp = key
            if !temp.isEmpty {
                temp.remove(at: temp.startIndex)
            }
            
            let value  = valueByKey(key: temp)
            if  let value = value {
                array.append(value)
            }else {
                
                array = getData(d: temp)
                if array.isEmpty {
                    let replacer: RegexHelper = try! RegexHelper("[ol]") // 过滤兄弟、姐妹这种大小关系
                    let newkey = replacer.replace(input: temp, template: "")
                    array = getData(d: newkey)
                }
                if array.isEmpty {
                    let replacer: RegexHelper = try! RegexHelper("[ol]") // 过滤兄弟、姐妹这种大小关系
                    let newkey = replacer.replace(input: temp, template: "x")
                    array = getData(d: newkey)
                }
                if array.isEmpty {
                    let replacer: RegexHelper = try! RegexHelper("x") // 过滤兄弟、姐妹这种大小关系
                    var newkey = replacer.replace(input: temp, template: "l")
                    array = getData(d: newkey)
                    newkey = replacer.replace(input: temp, template: "o")
                    array = array + getData(d: newkey)
                }
            }
        }
        for v in array {
            dataValue = dataValue + "/\(v)"
        }
        dataValue.remove(at: dataValue.startIndex)
        return dataValue
    }

    
    
    
}
