//
//  ViewController.swift
//  InAppPayDemo
//
//  Created by Erickson on 16/3/15.
//  Copyright © 2016年 paiyipai. All rights reserved.
//

import UIKit
import StoreKit

/// 在Developer后台配置
let productArr = ["1","2","3"]

class ViewController: UIViewController {

    var productDict = [String:SKProduct]()
    var productId : String?

    @IBOutlet weak var button: UIButton!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStore()
        
    }
    
    func setupStore() {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    @IBAction func buyAction(sender: AnyObject) {
        requestProducts()
        
    }
    
    /**
     获取商品列表
     */
    func requestProducts() {
        
        let set = NSSet(array: productArr)
        let request = SKProductsRequest(productIdentifiers: set as! Set<String>)
        request.delegate = self
        request.start()
    }
    

    func buyProducts(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    func finishTransation(transaction: SKPaymentTransaction) {
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    /**
     验证
     */
    func verifyPruchase(transactionIdentifier:String) {
        let receiptURL = NSBundle.mainBundle().appStoreReceiptURL
        let receiptData = NSData(contentsOfURL: receiptURL!)
        
        let encodeString = receiptData?.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
        
        if let code = encodeString {
            print("发送到自己服务器验证\(code)")
        }
        
        
    }
}

extension ViewController : SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let products =  response.products
        if products.count == 0 {
            print("没有商品")
            return
        }
        
        for prod in products {
            
            productDict[prod.productIdentifier] = prod
            debugPrint(prod.productIdentifier)
            debugPrint(prod.localizedTitle)
        }
        
        
        if SKPaymentQueue.canMakePayments() {
            buyProducts(productDict[productId!]!)
        }
        
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
}

extension ViewController : SKPaymentTransactionObserver {
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for tran in transactions {
            switch tran.transactionState {
            case .Purchasing:
                print("正在购买")
                
            case .Purchased:
                
                verifyPruchase(tran.transactionIdentifier!)

                print("验证购买")
                finishTransation(tran)
            case .Failed:
                print("购买失败")
                finishTransation(tran)
            case .Restored: 
                print("购买过")
            case .Deferred: 
                break
            }
            
        }
        
    }
}

