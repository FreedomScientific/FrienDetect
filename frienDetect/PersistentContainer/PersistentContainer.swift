/******************************************************************************
Copyright (c) 2019 Freedom Scientific 
Licensed under the New BSD license

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
sTHIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
******************************************************************************/

import UIKit
import CoreData

class PersistentContainer{
    
   static let context = persistentContainer.viewContext
   static let friendEntity = NSEntityDescription.entity(forEntityName: "Friend", in: context)
   static let recentEntity = NSEntityDescription.entity(forEntityName: "Recent", in: context)

    static func queryForContactWith(appleContactID: String) -> Contact?{
        do {
            // search presistent storage for Contacts holding the appleContactID
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format: "appleContactID = %@", appleContactID)
            
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            // return a Contact or nil based on the results
            if(results.count < 1){
                return nil
            } else {
                let name = results[0].value(forKey: "name") as! String
                
                let numbersAsString = results[0].value(forKey: "numbers") as! String
                let numbers = numbersAsString.components(separatedBy: " ")

                
                let imageData = results[0].value(forKey: "imageData") as? Data
                let isBlocked = results[0].value(forKey: "blocked") as! Bool
                let appleContactID = results[0].value(forKey: "appleContactID") as! String
                
                return Contact(name: name, numbers: numbers, imageData: imageData,
                               isBlocked: isBlocked, appleContactID: appleContactID)
            }
        } catch (let error) {
            print("Failed to fetch from disk: \(error)")
            return nil
        }
    }
    
    static func getContactsWith(number: String) -> [Contact]{
        do {
            // search presistent storage for contacts holding 'number'
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate = NSPredicate(format: "numbers contains[c] %@", number)
            
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            // return a [Contact] based on the results
            var contacts = [Contact]()
            
            for result in results {
                let name = result.value(forKey: "name") as! String
            
                let numbersAsString = result.value(forKey: "numbers") as! String
                let numbers = numbersAsString.components(separatedBy: " ")
                
                
                let imageData = result.value(forKey: "imageData") as? Data
                let isBlocked = result.value(forKey: "blocked") as! Bool
                let appleContactID = result.value(forKey: "appleContactID") as! String
                
                contacts.append(
                    Contact(name: name, numbers: numbers, imageData: imageData,
                            isBlocked: isBlocked, appleContactID: appleContactID)
                )
            }
            
            return contacts
            
        } catch (let error) {
            // handle a failed fetch
            print("Failed to fetch from disk: \(error)")
            return [Contact]()
        }
    }
    
    // save new contact
    static func saveNewContact(contact: Contact){
        // add a new managed object into the persistent container
        let newFriend = NSManagedObject(entity: friendEntity!, insertInto: context)
        
        var numbersAsString = ""
        for number in contact.numbers {
            numbersAsString += "\(number) "
        }
        numbersAsString.removeLast()

        
        // set object's properties
        newFriend.setValue(contact.name, forKey: "name")
        newFriend.setValue(numbersAsString, forKey: "numbers")
        newFriend.setValue(contact.imageData, forKey: "imageData")
        newFriend.setValue(contact.isBlocked, forKey: "blocked")
        newFriend.setValue(contact.appleContactID, forKey: "appleContactID")
        

        // save the context
        do {
            try context.save()
        } catch {
            // handle a failed save
            print("Failed saving")
        }
    }
    
    // update contact data
    static func updateContactData(contact: Contact){
        // find the object needing the update
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "appleContactID = %@", contact.appleContactID)
      
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject]{
                
                var numbersAsString = ""
                for number in contact.numbers {
                    numbersAsString += "\(number) "
                }
                numbersAsString.removeLast()
                
                // set object's properties
                result.setValue(contact.name, forKey: "name")
                result.setValue(numbersAsString, forKey: "numbers")
                result.setValue(contact.imageData, forKey: "imageData")
                result.setValue(contact.isBlocked, forKey: "blocked")
                result.setValue(contact.appleContactID, forKey: "appleContactID")
            }
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
            
        } catch (let error) {
            print("Failed to fetch from disk: \(error)")
        }
        
    }
    
    // retreive Recents
    static func retreiveRecents() -> [RecentContact]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recent")
        fetchRequest.returnsObjectsAsFaults = false
        
        var recents = [RecentContact]()
 
        do {
            let result = try context.fetch(fetchRequest) as! [NSManagedObject]
            for object in result as! [NSManagedObject]{
                let name = object.value(forKey: "name") as! String
                let imageData = object.value(forKey: "imageData") as? Data
                let lastSeen = object.value(forKey: "lastSeen") as! String
                recents.append(RecentContact(name: name, imageData: imageData, lastSeen: lastSeen))
            }
            
        } catch (let error) {
            print("Failed to fetch from disk: \(error)")
        }
        
        return recents
    }
    
    // save Recents
    static func saveRecent(recent: RecentContact){
        let object = NSManagedObject(entity: recentEntity!, insertInto: context)
        object.setValue(recent.name, forKey: "name")
        object.setValue(recent.imageData, forKey: "imageData")
        object.setValue(recent.lastSeen, forKey: "lastSeen")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    // erase Recents history
    static func eraseRecentsHistory(){
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Recent")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            let result = try context.execute(request)
        }
        catch(let error){
            print(error)
        }
    }
    
    // clean-up old contacts
    static func cleanUp(goodAppleIDs: [String]){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for object in result as! [NSManagedObject]{
                let appleContactID = object.value(forKey: "appleContactID") as! String
                
                if !goodAppleIDs.contains(appleContactID) {
                    context.delete(object)
                }
            }
            
        } catch (let error) {
            print("Failed to fetch from disk: \(error)")
        }
    }
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "ContactModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
  static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
}
