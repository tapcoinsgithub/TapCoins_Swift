//
//  ForgotPasswordViewModel.swift
//  TapCoinsApplication
//
//  Created by Eric Viera on 3/14/24.
//

import Foundation
import SwiftUI

final class ForgotPasswordViewModel: ObservableObject {
    @Published var phone_number:String = ""
    @Published var email_address:String = ""
    @Published var code:String = ""
    @Published var password:String = ""
    @Published var c_password:String = ""
    @Published var error:String = ""
    @Published var send_pressed:Bool = false
    @Published var is_phone_error = false
    @Published var is_email_error = false
    @Published var is_error = false
    @Published var is_match_error = false
    @Published var is_password_error = false
    @Published var successfully_sent = false
    @Published var submitted = false
    private var globalFunctions = GlobalFunctions()
    private var globalVariables = GlobalVariables()
    
    func sendCodeTask(){
        Task {
            do {
                print("IN SEND CODE TASK")
                DispatchQueue.main.async{
                    self.send_pressed = true
                    self.is_phone_error = false
                    self.is_email_error = false
                    self.successfully_sent = false
                    self.submitted = false
                }
                var has_phone_number = false
                var has_email_address = false
                if phone_number == ""{
                    print("DOES NOT HAVE PHONE NUMBER")
                    if email_address == ""{
                        print("DOES NOT HAVE EMAIL ADDRESS")
                        DispatchQueue.main.async{
                            self.is_phone_error = true
                            self.is_email_error = true
                            self.send_pressed = false
                            self.successfully_sent = false
                            self.submitted = false
                        }
                        return
                    }
                    else{
                        print("HAS EMAIL ADDRESS")
                        has_email_address = true
                    }
                }
                else{
                    print("HAS PHONE NUMBER")
                    has_phone_number = true
                }
                
                if has_phone_number{
                    if self.globalFunctions.check_errors(state: Error_States.Invalid_Phone_Number, _phone_number: phone_number, uName: "", p1: "", p2: "", _email_address: "") == "PHError" {
                        DispatchQueue.main.async{
                            self.is_phone_error = true
                            self.is_email_error = false
                            self.send_pressed = false
                            self.successfully_sent = false
                        }
                        return
                    }
                }
                else if has_email_address{
                    print("CHECKING FOR EMAIL ERROR")
                    if self.globalFunctions.check_errors(state: Error_States.Invalid_Email_Address, _phone_number: "", uName: "", p1: "", p2: "", _email_address: email_address) == "EAError" {
                        print("HAS AN EMAIL ERROR")
                        DispatchQueue.main.async{
                            self.is_email_error = true
                            self.is_phone_error = false
                            self.send_pressed = false
                            self.successfully_sent = false
                        }
                        return
                    }
                }
                let result:Bool = try await send_code(has_phone_number: has_phone_number, has_email_address: has_email_address)
                if !result{
                    print("Something went wrong.")
                    DispatchQueue.main.async {
                        self.send_pressed = false
                        self.is_error = true
                        self.error = "Could not send code."
                    }
                }
            } catch {
                _ = "Error: \(error.localizedDescription)"
                DispatchQueue.main.async{
                    print("IN HERE IN HERE")
                    self.send_pressed = false
                    self.is_error = true
                    self.error = "Something went wrong."
                }
            }
        }
    }
    
    func send_code(has_phone_number:Bool, has_email_address:Bool) async throws -> Bool{
        
        var url_string:String = ""
        let serverURL = globalVariables.apiUrl
        url_string = serverURL + "/tapcoinsapi/user/send_code"
        
        guard let url = URL(string: url_string) else{
            throw PostDataError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let token = "token=ForgotPassword"
        let contact_info = "&phone_number=" + phone_number + "&email_address=" + email_address
        let bool_values = "&is_phone=" + (has_phone_number ? "Yes" : "No") + "&is_email=" + (has_email_address ? "Yes" : "No")
        let requestBody = token + contact_info + bool_values
        request.httpBody = requestBody.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for:request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw PostDataError.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(Response.self, from: data)
            if response.response{
                print("RESPONSE IS TRUE")
                DispatchQueue.main.async {
                    self.successfully_sent = true
                    self.send_pressed = false
                }
                return true
            }
            else{
                print("RESPONSE IS FALSE")
                return false
            }
        }
        catch {
            throw PostDataError.invalidData
        }
    }
    
    func submitTask(){
        Task {
            do {
                print("IN SEND CODE TASK")
                DispatchQueue.main.async{
                    self.send_pressed = true
                    self.is_error = false
                    self.is_match_error = false
                    self.is_password_error = false
                    self.submitted = false
                }
                
                if password != c_password{
                    DispatchQueue.main.async{
                        self.is_match_error = true
                        self.is_password_error = false
                        self.send_pressed = false
                    }
                    return
                }
                
                if password == "" {
                    DispatchQueue.main.async{
                        self.is_password_error = true
                        self.is_match_error = false
                        self.send_pressed = false
                    }
                    return
                }
                let result:Bool = try await submit()
                if !result{
                    print("Something went wrong.")
                }
                DispatchQueue.main.async{
                    self.send_pressed = false
                }
            } catch {
                _ = "Error: \(error.localizedDescription)"
                DispatchQueue.main.async{
                    self.send_pressed = false
                    print("IN HERE IN HERE")
                    self.is_error = true
                    self.error = "Something went wrong."
                }
            }
        }
    }
    
    func submit() async throws -> Bool{
        
        var url_string:String = ""
        let serverURL = globalVariables.apiUrl
        url_string = serverURL + "/tapcoinsapi/user/change_password"
        
        guard let url = URL(string: url_string) else{
            throw PostDataError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let requestBody = "code=" + code + "&password=" + password
        request.httpBody = requestBody.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for:request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw PostDataError.invalidResponse
        }
        do {
            let response = try JSONDecoder().decode(Response2.self, from: data)
            if response.response{
                if response.expired{
                    DispatchQueue.main.async{
                        self.is_error = true
                        self.error = "Expired code."
                    }
                    return false
                }
                else{
                    DispatchQueue.main.async{
                        self.submitted = true
                    }
                }
            }
            else{
                let errorType = Error_Types.allCases.first(where: { $0.index == response.error_type })
                if errorType == Error_Types.BlankPassword{
                    DispatchQueue.main.async{
                        self.is_error = true
                        self.error = response.message
                    }
                    return false
                }
                if errorType == Error_Types.PreviousPassword{
                    DispatchQueue.main.async{
                        self.is_error = true
                        self.error = response.message
                    }
                    return false
                }
                if errorType == Error_Types.SomethingWentWrong{
                    DispatchQueue.main.async{
                        self.is_error = true
                        self.error = response.message
                    }
                    return false
                }
                if errorType == Error_Types.TimeLimitCode{
                    DispatchQueue.main.async{
                        self.is_error = true
                        self.error = response.message
                    }
                    return false
                }
            }
        }
        catch{
            throw PostDataError.invalidData
        }
        return true
    }
    
    struct Response:Codable {
        let response: Bool
    }
    
    struct Response2:Codable {
        let response: Bool
        let message: String
        let expired: Bool
        let error_type: Int
    }
}
