import UIKit
import Firebase

class LoginViewController: UIViewController {
  
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var bottomLayoutGuideConstraint: NSLayoutConstraint!
  
    // MARK: View Lifecycle
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
  
    /*
        1.  First, you check to confirm the name field isn’t empty.
        2.  Then you use the Firebase Auth API to sign in anonymously. This method takes a completion handler which is passed a user and, if necessary, an error.
        3.  In the completion handler, check to see if you have an authentication error. If so, abort.
        4.  Finally, if there wasn’t an error, trigger the segue to move to the ChannelListViewController.
    */
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        if nameField?.text != "" { // 1
            Auth.auth().signInAnonymously(completion: { (user, error) in // 2
                if let err = error { // 3
                    print(err.localizedDescription)
                    return
                }
                self.performSegue(withIdentifier: "LoginToChat", sender: nil) // 4
            })
        } else {
            print("User tried loging in with blank name")
        }
    }
  
    // MARK: - Notifications

    func keyboardWillShowNotification(_ notification: Notification) {
        let keyboardEndFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        bottomLayoutGuideConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
    }

    func keyboardWillHideNotification(_ notification: Notification) {
        bottomLayoutGuideConstraint.constant = 48
    }
    
    // MARK: Navigation
    /*
     1. Retrieve the destination view controller from segue and cast it to a UINavigationController.
     2. Cast the first view controller of the UINavigationController to a ChannelListViewController.
     3. Set the senderDisplayName in the ChannelListViewController to the name provided in the nameField by the user.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVc = segue.destination as! UINavigationController // 1
        let channelVc = navVc.viewControllers.first as! ChannelListViewController // 2
        
        channelVc.senderDisplayName = nameField?.text // 3
    }
  
} //EOC

