//
//  PSPurchaseAPI.swift
//  PDFScanner
//
//  Created by heartjhl on 2020/5/27.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit

class PSPurchaseAPI: NSObject {
    
//    单例
   @objc class var shared : PSPurchaseAPI {
        struct Static {
            static let instance : PSPurchaseAPI = PSPurchaseAPI()
        }
        return Static.instance
    }
    
    var localPrice:String?
    var transactionArray = [PaymentTransaction]()
    

    //   添加交易观察者，异步执行completeTransactions，回调block时回到主线程
    @objc func registerTransactionObserverAPI(completion: @escaping (String,String,Bool) -> Void) {
        self.transactionArray.removeAll()
        SwiftyStoreKit.completeTransactions(atomically: false) { purchases in
            for purchase in purchases {
                
                let tra = purchase.transaction as! SKPaymentTransaction
                
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        self.transactionArray.append(purchase.transaction);
                    }
                    print("🔥👌：\(purchase.transaction.transactionIdentifier ?? "hhhhhhhhhhh"): \(purchase.productId)")
                    print("😊😊😊：\(purchase.needsFinishTransaction)")
                    self.localPrice = purchase.productId + "&" + (tra.payment.applicationUsername ?? "");
                    self.fetchReceiptAPI(completion)
                case .failed:
                break // do nothing
                case .purchasing:
                    break;//// do nothing
                case .deferred:
                    break;//// do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)//1000000549677840
            }
        }
    }
    
    
    @objc func shoudAddPurchaseAPI(completion: @escaping (String,String,Bool) -> Void) {
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            let indentify = payment.productIdentifier
            completion(indentify,"",true)
            return false//返回True时，点击App Store上的内购推广按钮，系统会发起购买请求
        }
    }
    
//    完成交易 1000000563058486
   @objc func finishTransaction() {
    for transaction in self.transactionArray {
        SwiftyStoreKit.finishTransaction(transaction)
     }
    print("🍑🍑🍑🍑🍑🍑交易完成：\(String(describing: self.transactionArray))")
   }
    
//    获取内购项目列表信息（异步获得当前的应用程序的所有内购项目，回调block时回到主线程）
    @objc func retrieveProductsInfoAPI(productIds:Set<String>,completiton:@escaping (Dictionary<String, Any>,Bool) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo(productIds) { result in
            var priceDic = [String:String]()
            if result.retrievedProducts.first != nil {
                
                for product in result.retrievedProducts{
                   let priceString = product.localizedPrice!//价钱
                   let key = product.productIdentifier
                    priceDic[key] = priceString;
                }
                
                completiton(priceDic,true)
                
            }else if result.invalidProductIDs.first != nil {
//                处理产品ID无效的情况
                completiton(["key":"Invalid product identifier"],false)
            }else {
//                处理由于网络请求失败等情况，所造成的内购查询失败的问题
                completiton(["key":"Error: \(String(describing: result.error))"],false)
            }
        }
    }
    
//    购买指定唯一标识符的内购项目
    @objc func purchaseProductAPI(productid:String,completion: @escaping (String,String,Bool) -> Void) {
        SwiftyStoreKit.purchaseProduct(productid, atomically: false, applicationUsername: productid) { result in
            switch result{
            case .success(let purchase):
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {//
                    self.transactionArray.removeAll()//1000000542996104
                    self.transactionArray.append(purchase.transaction)
                }
                
               let currencyCode = purchase.product.priceLocale.currencyCode!
               self.localPrice = purchase.product.price.stringValue + currencyCode;
                
                self.fetchReceiptAPI(completion)
                
                print("🍎🍎🍎购买🍎🍎🍎：\(purchase.transaction.transactionIdentifier ?? "hhhhhhhhhhh"): \(String(describing: self.localPrice))")
                
            case .error(let error):
                print("Purchase Failed: \(error)")
                switch error.code {
                case .unknown:
//                    print("Unknown error. Please contact support")
                    completion("Unknown error. Please contact support","",false)//
                case .clientInvalid:
//                    print("Not allowed to make the payment")
                    completion("Not allowed to make the payment", "",false)
                case .paymentCancelled:
                    completion("Cancel","",false)
                    break
                case .paymentInvalid:
//                    print("The purchase identifier was invalid")
                    completion("The purchase identifier was invalid","",false)
                case .paymentNotAllowed:
//                    print("The device is not allowed to make the payment")
                    completion("The device is not allowed to make the payment","",false)
                case .storeProductNotAvailable:
//                    print("The product is not available in the current storefront")
                    completion("The product is not available in the current storefront","",false)
                case .cloudServicePermissionDenied:
//                    print("Access to cloud service information is not allowed")
                    completion("Access to cloud service information is not allowed","",false)
                case .cloudServiceNetworkConnectionFailed:
//                    print("Could not connect to the network")
                    completion("Could not connect to the network","",false)
                case .cloudServiceRevoked:
//                    print("User has revoked permission to use this cloud service")
                    completion("User has revoked permission to use this cloud service","",false)
                default:
//                    print("Purchase Failed reason:\(error.localizedDescription)")
                    completion("\(error.localizedDescription)","",false)
                    break
                }
            }
        }
    }
    
//    恢复内购。如果用户之前购买过内购的项目，当用户重新安装应用程序时，可以通过此方法，恢复用户之前购买过的项目
    @objc func restorePurchaseAPI(completion: @escaping (String,String,Bool) -> Void) {
//        获得所有购买过的项目
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(String(describing: results.restoreFailedPurchases.first))")
                if (results.restoreFailedPurchases.first?.0.code)!.rawValue == 0{
                    completion("Cancel","",false)//点击系统弹框的取消
                    return;
                }
                completion("Restore Failed","",false)
            }else if results.restoredPurchases.count > 0 {
                for purchase in results.restoredPurchases {
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
//                         Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
//                        self.lastTransaction = purchase.transaction;
                    }
                }
                self.fetchReceiptAPI(completion)
//                print("Restore Success: \(results.restoredPurchases)")
            }else {
//                print("Nothing to Restore")
                completion("Nothing to Restore","",false)
            }
        }
    }
    
//    获取收据
    @objc func fetchReceiptAPI(_ completion: @escaping (String,String,Bool) -> Void) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
//                print("Fetch receipt success:\n\(encryptedReceipt)")
                completion(encryptedReceipt,self.localPrice ?? "",true)
            case .error(let error):
                print("Fetch receipt failed: \(error)")
                completion("Fetch receipt failed","",false)
            }
        }
    }
    
    @objc func existReceiptInfo(_ receiptBlock: @escaping (Bool) -> Void){
        typealias completionBlock = (String,String,Bool) -> Void
        let completion:completionBlock = { receipt,price,success in
//            print("Fetch receipt Success: \(receipt)")
            receiptBlock(success)
        }
        self.fetchReceiptAPI(completion)
    }
}
