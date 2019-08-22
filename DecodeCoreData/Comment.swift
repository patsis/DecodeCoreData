// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let comments = try? newJSONDecoder().decode(Comments.self, from: jsonData)

import Foundation
import CoreData

// MARK: - Comment
class Comment : NSManagedObject, Codable {
  
  @NSManaged var id : Int64
  @NSManaged var postId : Int64
  @NSManaged var name : String?
  @NSManaged var email : String?
  @NSManaged var body : String?
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case postId = "postId"
    case name = "name"
    case email = "email"
    case body = "body"
  }
  
  // MARK: - Dencodable
  required convenience init(from decoder: Decoder) throws {
          
    guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,//init(rawValue: "context"),
      let managedObjContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
      let entity = NSEntityDescription.entity(forEntityName: "Comment", in: managedObjContext) else {
        fatalError("Failed to decode User")
    }
    
    self.init(entity: entity, insertInto: managedObjContext)
    do {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      body = try values.decode(String.self, forKey: .body)
      email = try values.decode(String.self, forKey: .email)
      id = try values.decode(Int64.self, forKey: .id)
      name = try values.decode(String.self, forKey: .name)
      postId = try values.decode(Int64.self, forKey: .postId)
    } catch let error {
      print("decode error: \(error)")
    }
  }
  
  // MARK: - Encodable
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(body, forKey: .body)
    try container.encode(email, forKey: .email)
    try container.encode(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(postId, forKey: .postId)
  }
}

extension Comment {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
    return NSFetchRequest<Comment>(entityName: "Comment")
  }
}

public extension CodingUserInfoKey {
  static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

//typealias Comments = [Comment]

