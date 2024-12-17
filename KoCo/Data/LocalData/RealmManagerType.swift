//
//  RealmManagerType.swift
//  KoCo
//
//  Created by 하연주 on 10/26/24.
//

import Foundation
import RealmSwift

protocol RealmManagerType {
//    associatedtype Item = Object
    
    var realm : Realm { get }

    func checkFileURL()
    func checkSchemaVersion()
    func createItem<M : Object>(_ data : M)
    func getAllObjects<M : Object>(tableModel : M.Type) -> Results<M>?
    func removeItem<M : Object>(_ data : M)
    func editItem<M : Object>(_ data : M.Type, at id : ObjectId ,editKey : String, to editValue : Any)
}
