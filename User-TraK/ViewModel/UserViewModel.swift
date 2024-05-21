//
//  UserViewModel.swift
//  User-TraK
//
//  Created by MANIKANDAN RAJA on 17/05/24.
//

import Foundation
import Alamofire
import CoreData

struct User: Codable {
    var name: String
    var mobile: String
    var email: String
    var gender: String
    var _id: String
}

class UserViewModel {
    let apiURL = "https://crudcrud.com/api/e71a12d01d4c42dd9c7b205bc00c0efc/persons/"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchUsers(completion: @escaping ([User]?) -> Void) {
        AF.request(apiURL).responseDecodable(of: [User].self) { response in
            switch response.result {
            case .success(let users):
                self.saveUsersToCoreData(users)
                completion(users)
            case .failure(let error):
                print("Error fetching users: \(error)")
                completion(nil)
            }
        }
    }
    
    private func saveUsersToCoreData(_ users: [User]) {
        for user in users {
            let fetchRequest: NSFetchRequest<Users> = Users.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", user._id)
            do {
                let existingUsers = try context.fetch(fetchRequest)
                if let existingUser = existingUsers.first {
                    existingUser.name = user.name
                    existingUser.mobile = user.mobile
                    existingUser.email = user.email
                    existingUser.gender = user.gender
                } else {
                    let newUser = Users(context: context)
                    newUser.id = user._id
                    newUser.name = user.name
                    newUser.mobile = user.mobile
                    newUser.email = user.email
                    newUser.gender = user.gender
                }
            } catch {
                print("Failed to fetch existing user: \(error)")
            }
        }
        do {
            try context.save()
            print("Users saved successfully to Core Data.")
        } catch {
            print("Failed to save users to Core Data: \(error)")
        }
    }
    
    func updateUser(_ user: Users, completion: @escaping (Bool) -> Void) {
        let parameters: [String: Any] = [
            "name": user.name ,
            "mobile": user.mobile ,
            "email": user.email ,
            "gender": user.gender
        ]
        
        let url = "\(apiURL)\(user.id ?? "")"
        
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success:
                do {
                    try self.context.save()
                    completion(true)
                } catch {
                    print("Failed to save updated user to Core Data: \(error)")
                    completion(false)
                }
            case .failure(let error):
                print("Error updating user via API: \(error)")
                completion(false)
            }
        }
    }
    
    func deleteUser(_ user: User, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<Users> = Users.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user._id)
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if let existingUser = existingUsers.first {
                context.delete(existingUser)
                try context.save()
                print("User deleted successfully from Core Data.")
                deleteUserFromAPI(user) { success in
                    completion(success)
                }
            } else {
                completion(false)
            }
        } catch {
            print("Failed to delete user from Core Data: \(error)")
            completion(false)
        }
    }

    private func deleteUserFromAPI(_ user: User, completion: @escaping (Bool) -> Void) {
        let url = "\(apiURL)\(user._id)"
        AF.request(url, method: .delete).response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Error deleting user from API: \(error)")
                completion(false)
            }
        }
    }

    func fetchSavedUsers(completion: @escaping ([Users]?) -> Void) {
        do {
            let savedUsers = try context.fetch(Users.fetchRequest()) as? [Users]
            completion(savedUsers)
        } catch {
            print("Failed to fetch saved users: \(error)")
            completion(nil)
        }
    }
}
