import Foundation

let json = """
{
    "name": "Ford Sierra",
    "power": 120,
    "class": "Sedan",
    "price": 10202.1
}
"""

enum DecodingError: Error{
    case dataCorruptedError
}

struct JSON: Decodable{
    var value: Any
    
    //create custom coding keys
    private struct CodingKeys: CodingKey{
        var stringValue: String
        
        init?(stringValue: String){
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        
        init?(intValue: Int){
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self){
            var result = [String: Any]()
            
            //go over the keys
            for key in container.allKeys{
                result[key.stringValue] = try container.decode(JSON.self, forKey: key).value
            }
            
            //save the result into value
            value = result
            
        //if json is just a single value
        } else if let container = try? decoder.singleValueContainer() {
            if let stringValue = try? container.decode(String.self){
                value = stringValue
            } else if let intValue = try? container.decode(Int.self){
                value = intValue
            } else if let doubleValue = try? container.decode(Double.self){
                value = doubleValue
            } else if let boolValue = try? container.decode(Bool.self){
                value = boolValue
            } else if let arrayValue = try? container.decode([JSON].self){
                value = arrayValue.map {$0.value}
            } else {
                throw DecodingError.dataCorruptedError
            }
        } else {
            throw DecodingError.dataCorruptedError
        }
    }
}


let decoded = try? JSONDecoder().decode(JSON.self, from: json.data(using: .utf8)!).value
print(decoded as! [String: Any])
