//
//  BaseRepository.swift
//  KoCo
//
//  Created by 하연주 on 10/26/24.
//

import Foundation
import RealmSwift


class BaseRepository : RepositoryType {
    var realm = try! Realm()
    
    func checkFileURL() {
        print("🔥 fileURL -> ", realm.configuration.fileURL!)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func checkSchemaVersion() {
        do {
            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
            print("🔥 version -> ",version)
        }catch {
            print(error)
        }
    }
    
    
    //아이템 추가 Create
    func createItem<M : Object>(_ data : M) {
        do {
            try realm.write{
                realm.add(data)
                print("Realm Create Succeed -> ", getAllObjects(tableModel: M.self))
            }
        } catch {
            print(error)
        }
    }
    
    //전체 리스트 Read
    func getAllObjects<M : Object>(tableModel : M.Type) -> Results<M>? {
       
        let value =  realm.objects(M.self)
        return value
    }
    
    //아이템 삭제 Delete
    func removeItem<M : Object>(_ data : M) {
        print("❤️removeItem")
        do {
            try realm.write {
                realm.delete(data)
            }
        }catch {
            print(error)
        }
    }
    
    //아이템 수정 Update
    func editItem<M : Object>(_ data : M.Type, at id : ObjectId ,editKey : String, to editValue : Any) {
        do {
            try realm.write{
                realm.create(
                    M.self,
                    value: [
                        "id" : id, //수정할 컬럼
                        editKey : editValue
                    ],
                    update: .modified
                )
            }
        }catch {
            print(error)
        }
        
    }
}


