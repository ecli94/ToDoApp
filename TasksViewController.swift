
import UIKit
import RealmSwift

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
	@IBOutlet weak var tasksTableView: UITableView!
	@IBOutlet var search: UITextField!
    var currentCreateAction:UIAlertAction!
    
    var isEditingMode = false
    var taskList : Results<Task>!
	
    override func viewDidLoad() {
		super.viewDidLoad()
		tasksTableView.delegate = self
		tasksTableView.dataSource = self
		search.delegate = self
	    readTasksAndUpateUI()
    }
	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User Actions -
	
    @IBAction func didClickOnEditTasks(_ sender: AnyObject) {
        isEditingMode = !isEditingMode
        self.tasksTableView.setEditing(isEditingMode, animated: true)
    }
	
    @IBAction func didClickOnNewTask(_ sender: AnyObject) {
        self.displayAlertToAddTask(nil)
    }
	
	@IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            
            // Priority
            self.lists = self.lists.sorted(byProperty: "priority", ascending: false)
        }
        else{
            // date
            self.lists = self.lists.sorted(byProperty: "createdAt", ascending:false)
        }
        self.taskListsTableView.reloadData()
    }
	
	override func viewWillAppear(_ animated: Bool) {
        readTasksAndUpdateUI()
    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
    func readTasksAndUpateUI(){
        self.tasksTableView.setEditing(false, animated: true)
		self.showAll()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
		cell.textLabel?.text = taskList[indexPath.row].name!
        return cell
    }
    
    func displayAlertToAddTask(_ updatedTask:Task!){
        
        var title = "New Task"
        var doneTitle = "Create"
        if updatedTask != nil{
            title = "Update Task"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Describe your task", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let taskName = alertController.textFields![0] as UITextField
			let taskPriority = alertController.textFields![1] as UITextField
            
            if updatedTask != nil{
                // update mode
				let realm = try! Realm()
                try! realm.write{
                    updatedTask.name = taskName!
					updatedTask.priority = Int(taskPriority!)
                    self.readTasksAndUpateUI()
                }
            }
            else{
                
                let newTask = Task()
				let realm = try! Realm()
                newTask.name = taskName!
				newTask.priority = Int(taskPriority!)
                
                try! realm.write{
                    
                    self.taskList.append(newTask)
                    self.readTasksAndUpateUI()
                }
            }
            
            print(taskName ?? "")
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task Name"
            textField.addTarget(self, action: #selector(TasksViewController.taskNameFieldDidChange(_:)) , for: UIControlEvents.editingChanged)
            if updatedTask != nil{
                textField.text = updatedTask.name
            }
        }
		
		alertController.addTextField { (textField) -> Void in
			textField.placeholder = "Priority"
			textField.addTarget(self, action: #selector(TasksViewController.taskNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
			if updatedTask != nil{
				textField.text = updatedTask.priority
			}
		}
        
        self.present(alertController, animated: true, completion: nil)
    }

    //Enable the create action of the alert only if textfield text is not empty
    func taskNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = textField.text?.characters.count > 0
    }
    
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.taskList.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { 
            if (textField.text?.characters.count)! > 0{
                let realm = try! Realm()
                let predicate = NSPredicate(format: "name CONTAINS [c] %@", textField.text!)
                var filtered_tasks = realm.objects(Task).filter(predicate)
                for each in filtered_tasks{
                    self.taskList.append(each)
                    self.tasksTableView.reloadData()
                }
            } else {
                self.showAll()
            }
        }
        
        return true
    }
	
	func showAll(){
		let realm = try! Realm()
        var allTasks = realm.objects(Task)
        for each in allTasks{
            self.taskList.append(each)
        }
        self.tasksTableView.reloadData()
	}
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let taskToBeUpdated: self.taskList[indexPath.row]
			let realm = try! Realm()
            
            try! realm.write{
                realm.delete(taskToBeDeleted)
                self.readTasksAndUpateUI()
            }
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Editing will go here
            let taskToBeUpdated: self.taskList[indexPath.row]
            
            self.displayAlertToAddTask(taskToBeUpdated)
            
        }
        
        let doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Done") { (doneAction, indexPath) -> Void in
            // Editing will go here
            let taskToBeUpdated: self.taskList[indexPath.row]
			let realm = try! Realm()
            
            try! realm.write{
                taskToBeUpdated.isCompleted = true
                self.readTasksAndUpateUI()
            }
            
        }
        return [deleteAction, editAction, doneAction]
    }

}
