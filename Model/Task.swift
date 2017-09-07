import RealmSwift

class Task: Object {
    
    dynamic var name : String?
	//Assume priority is assigned an integer where higher values are more important
	dynamic var priority : Int
    dynamic var createdAt = NSDate()
    dynamic var isCompleted = false
    
}
