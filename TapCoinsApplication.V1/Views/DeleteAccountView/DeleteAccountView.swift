//
//  DeleteAccountView.swift
//  TapCoinsApplication.V1
//
//  Created by Eric Viera on 5/8/24.
//

import Foundation
import SwiftUI

struct DeleteAccountView: View {
    @StateObject private var viewModel = DeleteAccountViewModel()
    var newCustomColorsModel = CustomColorsModel()
    var body: some View {
        ZStack{
            newCustomColorsModel.colorSchemeFour.ignoresSafeArea()
            if (viewModel.delete_pressed || viewModel.pressed_confirm_password){
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint:newCustomColorsModel.colorSchemeOne))
                    .scaleEffect(UIScreen.main.bounds.width * 0.01)
            }
            else{
                if viewModel.confirmed_current_password{
                    VStack(alignment: .center, spacing: UIScreen.main.bounds.width * 0.05){
                        Text("Are you sure you want to delete your account? All of your data will be lost including any TapCoins currently in your account. All of your previous TapCoins earned will still be saved in our database along with the phone number/email associated with the earnings for tax/security purposes.")
                            .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .center)
                            .font(.system(size: UIScreen.main.bounds.width * 0.04))
                            .foregroundColor(newCustomColorsModel.colorSchemeOne)
                            .bold()
                            .underline(true)
                        if viewModel.deleteAccountError {
                            Label("Unable to delete account.", systemImage: "xmark.octagon")
                                .foregroundColor(newCustomColorsModel.colorSchemeFive)
                        }
                        Button(action: {viewModel.delete_pressed ? nil : viewModel.deleteAccountTask()}, label: {
                            Text("Confirm")
                                .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.04, alignment: .center)
                                .background(newCustomColorsModel.colorSchemeOne)
                                .foregroundColor(newCustomColorsModel.colorSchemeFour)
                                .fontWeight(.bold)
                                .cornerRadius(8)
                        }).padding()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.3, alignment: .center)
                    .padding(3)
                }
                else{
                    VStack(alignment: .center, spacing: UIScreen.main.bounds.width * 0.05){
                        Text("Input password to delete account.")
                            .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .center)
                            .font(.system(size: UIScreen.main.bounds.width * 0.037))
                            .foregroundColor(newCustomColorsModel.colorSchemeOne)
                            .bold()
                            .underline(true)
                        SecureField("Password", text: $viewModel.password)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.04, alignment: .center)
                            .foregroundColor(Color(.black))
                            .background(Color(.white))
                        if viewModel.confirm_password_error {
                            Label("Invalid Password.", systemImage: "xmark.octagon")
                                .foregroundColor(newCustomColorsModel.colorSchemeFive)
                        }
                        Button(action: {viewModel.pressed_confirm_password ? nil : viewModel.confirm_password()}, label: {
                            Text("Confirm")
                                .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.04, alignment: .center)
                                .background(newCustomColorsModel.colorSchemeOne)
                                .foregroundColor(newCustomColorsModel.colorSchemeFour)
                                .fontWeight(.bold)
                                .cornerRadius(8)
                        }).padding()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.25, alignment: .center)
                    .padding(3)
                }
            }
        } // ZStack
    }
}
