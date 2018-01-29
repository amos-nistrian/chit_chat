import UIKit
import Firebase

// enum to hold your different table view sections.
enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}

class ChannelListViewController: UITableViewController {
    
    // MARK: Properties
    
    /*
        1. Add a simple property to store the sender’s name.
        2. Add a text field, which you’ll use later for adding new Channels.
        3. Create an empty array of Channel objects to store your channels.
        4. store a reference to the list of channels in the database
        5. holds a handle to the reference so you can remove it later on.
    */
    var senderDisplayName: String? // 1
    var newChannelTextField: UITextField? // 2
    private var channels: [Channel] = [] // 3
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels") // 4
    private var channelRefHandle: DatabaseHandle? // 5
    
   
    // MARK: View Lifecycle
    /*
        This calls your new observeChannels() method when the view controller loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chats"
        observeChannels()
    }
    /*
        You also stop observing database changes when the view controller dies by checking if channelRefHandle is set and then calling removeObserver(withHandle:)
     */
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    
    
    // MARK: Firebase related methods
    /*  Query the Firebase database and get a list of channels to show in your table view.
        1. call observe:with: on your channel reference, storing a handle to the reference. This calls the completion block every time a new channel is added to your database.
        2. The completion receives a FIRDataSnapshot (stored in snapshot), which contains the data and other helpful methods.
        3. You pull the data out of the snapshot and, if successful, create a Channel model and add it to your channels array.
    */
    private func observeChannels() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            if let name = channelData["name"] as! String!, name.count > 0 { // 3
                self.channels.append(Channel(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
    
    // MARK :Actions
    /*
        1. First check if you have a channel name in the text field.
        2. Create a new channel reference with a unique key using childByAutoId()
        3. Create a dictionary to hold the data for this channel. A [String: AnyObject] works as a JSON-like object
        4. Finally, set the name on this new channel, which is saved to Firebase automatically!
     */
    @IBAction func createChannel(_ sender: AnyObject) {
        if let name = newChannelTextField?.text { // 1
            let newChannelRef = channelRef.childByAutoId() // 2
            let channelItem = [ // 3
                "name": name
            ]
            newChannelRef.setValue(channelItem) // 4
        }
    }
    
    
    // MARK: UITableViewDataSource
    /*
        1. Set the number of sections. Remember, the first section will include a form for adding new channels, and the second section will show a list of channels.
        2. Set the number of rows for each section. This is always 1 for the first section, and the number of channels for the second section.
        3. Define what goes in each cell. For the first section, you store the text field from the cell in your newChannelTextField property. For the second section, you just set the cell’s text label as your channel name
        4.  Add code for when a channel is tapped
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 2
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return channels.count
            }
        } else {
            return 0
        }
    }
    
    // 3
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
            if let createNewChannelCell = cell as? CreateChannelCell {
                newChannelTextField = createNewChannelCell.newChannelNameField
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
        }
        
        return cell
    }
    
    // 4
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.currentChannelsSection.rawValue {
            let channel = channels[(indexPath as NSIndexPath).row]
            self.performSegue(withIdentifier: "ShowChannel", sender: channel)
        }
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = senderDisplayName
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
    }
}
