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
    */
    var senderDisplayName: String? // 1
    var newChannelTextField: UITextField? // 2
    private var channels: [Channel] = [] // 3
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        channels.append(Channel(id: "1", name: "Channel1"))
        channels.append(Channel(id: "2", name: "Channel2"))
        channels.append(Channel(id: "3", name: "Channel3"))
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    /*
        1. Set the number of sections. Remember, the first section will include a form for adding new channels, and the second section will show a list of channels.
        2. Set the number of rows for each section. This is always 1 for the first section, and the number of channels for the second section.
        3. Define what goes in each cell. For the first section, you store the text field from the cell in your newChannelTextField property. For the second section, you just set the cell’s text label as your channel name
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
}
