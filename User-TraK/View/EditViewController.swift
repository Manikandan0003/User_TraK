//
//  EditViewController.swift
//  User-TraK
//
//  Created by MANIKANDAN RAJA on 17/05/24.
//

import UIKit
import Alamofire

class EditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    
    let genderOptions = ["Male", "Female", "Other"]
    let genderPicker = UIPickerView()
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    var user: Users?
    var viewModel: UserViewModel!
    var onUserSaved: (() -> Void)? // Closure to notify user save action

    override func viewDidLoad() {
        super.viewDidLoad()
        
                nameTextField.delegate = self
                mobileTextField.delegate = self
                emailTextField.delegate = self
                genderTextField.delegate = self
        setupGenderPicker()
              
        
        
        if user == nil {
            // This is a new user, update UI accordingly (e.g., clear text fields)
            // For example:
            nameTextField.text = ""
            mobileTextField.text = ""
            emailTextField.text = ""
            genderTextField.text = ""
        } else {
            // This is an existing user, update UI with user details
            // For example:
            nameTextField.text = user?.name
            mobileTextField.text = user?.mobile
            emailTextField.text = user?.email
            genderTextField.text = user?.gender
        }
    }
    // Setup Gender Picker
       func setupGenderPicker() {
           genderPicker.delegate = self
           genderPicker.dataSource = self
           genderTextField.inputView = genderPicker
           genderTextField.textAlignment = .left
           genderTextField.placeholder = "Select Gender"
       }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           if textField == nameTextField {
               emailTextField.becomeFirstResponder()
           } else if textField == emailTextField {
               genderTextField.becomeFirstResponder()
           } else if textField == genderTextField {
               mobileTextField.becomeFirstResponder()
           } else if textField == mobileTextField {
               mobileTextField.resignFirstResponder()
           }
           return true
       }
       // UIPickerViewDataSource
       func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1
       }
       
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
           return genderOptions.count
       }
       
       // UIPickerViewDelegate
       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return genderOptions[row]
       }
       
       func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           genderTextField.text = genderOptions[row]
         //  genderTextField.resignFirstResponder()
           mobileTextField.becomeFirstResponder()
       }
       
       // Validate email format
       func isValidEmail(_ email: String) -> Bool {
           let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
           let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
           return emailPred.evaluate(with: email)
       }
       
       // Validate all fields
       func validateFields() -> Bool {
           guard let name = nameTextField.text, !name.isEmpty else {
               displayAlert(message: "Name field cannot be empty.")
               return false
           }
           
           guard let mobile = mobileTextField.text, mobile.count == 10, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: mobile)) else {
               displayAlert(message: "Mobile number must be exactly 10 digits.")
               return false
           }
           
           guard let email = emailTextField.text, isValidEmail(email) else {
               displayAlert(message: "Please enter a valid email address.")
               return false
           }
           
           guard let gender = genderTextField.text, !gender.isEmpty else {
               displayAlert(message: "Please select a gender.")
               return false
           }
           
           return true
       }
  
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Validate fields
                guard validateFields() else {
                    return
                }
        if user == nil {
            // Create new user
            createNewUser()
        } else {
            // Update existing user
            updateExistingUser()
        }
    }
    private func createNewUser() {
        // Prepare the new user data
        let newUser = User(
            name: nameTextField.text ?? "",
            mobile: mobileTextField.text ?? "",
            email: emailTextField.text ?? "",
            gender: genderTextField.text ?? "",
            _id: "" // Initially empty, will be set after API response
        )
        
        // Prepare the parameters for the POST request
        let parameters: [String: Any] = [
            "name": newUser.name,
            "mobile": newUser.mobile,
            "email": newUser.email,
            "gender": newUser.gender
        ]
        
        // Send the POST request to the API
        AF.request(viewModel.apiURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: User.self) { response in
            switch response.result {
            case .success(let createdUser):
                // Fetch users from the API and update Core Data
                self.viewModel.fetchUsers { [weak self] users in
                    guard let self = self else { return }
                    
                    if let users = users {
                        // Notify that the user has been saved
                        self.onUserSaved?()
                        // Pop the view controller
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            self.displayAlert(message: "User Data Created Successfully")

                        }
                    } else {
                        print("Failed to fetch users after creating a new user.")
                    }
                }
            case .failure(let error):
                print("Error creating user via API: \(error)")
                self.displayAlert(message: "User Data Not Created API limit Exceeded")

            }
        }
    }
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "User Trak", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func updateExistingUser() {
        // Update the existing user object with the changes from the text fields
        user?.name = nameTextField.text ?? ""
        user?.mobile = mobileTextField.text ?? ""
        user?.email = emailTextField.text ?? ""
        user?.gender = genderTextField.text ?? ""
        
        // Update the existing user in Core Data
        viewModel.updateUser(user!) { success in
            if success {
                print("User updated successfully.")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.displayAlert(message: "User Detail Updated Successfully")

                }
            } else {
                self.displayAlert(message: "User Detail Not Updated Successfully")
            }
        }
    }
}

