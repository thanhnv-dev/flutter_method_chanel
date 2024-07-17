//
//  WalletCoreModule.swift
//  Runner
//
//  Created by Brock Nguyen on 17/7/24.
//

import Foundation
import Flutter
import WalletCore

class WalletCoreModule {
    
    // MARK: Handle Method Call
    
    static func handleMethodCall(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        switch call.method {
        case "createWallet":
            createWallet(result: result)
            
        case "importWallet":
            importWallet(call: call, result: result)
            
        case "getBitcoinAddressAndKey":
            getBitcoinAddressAndKey(call: call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: Create Wallet
    
    static func createWallet(result: @escaping FlutterResult) {
        if let wallet = HDWallet(strength: 128, passphrase: "") {
            result(wallet.mnemonic)
        } else {
            result(FlutterError(code: "CreateWalletError", message: "Create Wallet Error", details: nil))
        }
    }
    
    // MARK: Import Wallet
    
    static func importWallet(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let mnemonic = call.arguments as? String else {
            result(FlutterError(code: "ImportWalletError", message: "Invalid arguments", details: nil))
            return
        }
        
        if let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") {
            result(true)
        } else {
            result(FlutterError(code: "ImportWalletError", message: "Import Wallet Error", details: nil))
        }
    }
    
    // MARK: Get Bitcoin Address and Key
    
    static func getBitcoinAddressAndKey(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let env = arguments["env"] as? String,
              let mnemonic = arguments["mnemonic"] as? String else {
            result(FlutterError(code: "GetBitcoinAddressAndKeyError", message: "Missing or invalid arguments", details: nil))
            return
        }
        
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
            result(FlutterError(code: "GetBitcoinAddressAndKeyError", message: "Invalid mnemonic", details: nil))
            return
        }
        
        let bitcoinAddress: String
        let bitcoinKey: PrivateKey
        
        if env == "DEV" {
            bitcoinAddress = wallet.getAddressDerivation(coin: .bitcoin, derivation: .testnet)
            bitcoinKey = wallet.getKeyDerivation(coin: .bitcoin, derivation: .testnet)
            print("Bitcoin address in DEV: ", bitcoinAddress)
            print("Bitcoin key in DEV: ", bitcoinKey.data.hexString)
        } else {
            bitcoinAddress = wallet.getAddressForCoin(coin: .bitcoin)
            bitcoinKey = wallet.getKeyForCoin(coin: .bitcoin)
            print("Bitcoin address in PROD: ", bitcoinAddress)
            print("Bitcoin key in PROD: ", bitcoinKey.data.hexString)
        }
        
        let resultData: [String: Any] = [
            "bitcoinAddress": bitcoinAddress,
            "bitcoinKey": bitcoinKey.data.hexString
        ]
        
        result(resultData)
    }
}
