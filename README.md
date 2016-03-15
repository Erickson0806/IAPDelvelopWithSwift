# IAPDelvelopWithSwift
iOS开发之内购-AppStore
1.在应用启动时添加一个交易队列观察者

```
SKPaymentQueue.defaultQueue().addTransactionObserver(self)
```

2.询问苹果的服务器能够销售哪些商品

```
func requestProducts(){
        let set = NSSet(array: productArr)
        let request = SKProductsRequest(productIdentifiers: set as! Set<String>)
        request.delegate = self
        request.start()
    }
```
3.点击某项商品后，并且在获取到商品列表后进行购买


```
extension PayManager : SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let products = response.products
        if products.count == 0 {
            debugPrint("没有商品")
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
        
        debugPrint(error.localizedDescription)
    }
}
```
4.进行购买

```
func buyProducts(product: SKProduct) {
        let payment = SKPayment(product: product)
		SKPaymentQueue.defaultQueue().addPayment(payment)
    }
```

5，处理购买结果

```
extension DKPayManager : SKPaymentTransactionObserver {
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for tran in transactions {
            switch tran.transactionState {
            case .Purchased:
                debugPrint("验证购买")

                verifyPruchase(tran.transactionIdentifier!)
                finishTransation(tran)


            case.Purchasing:
                debugPrint("商品添加进列表")

            case.Restored:
                debugPrint("已经购买过")
            case.Failed:
                debugPrint("交易失败")
                failedTransaction(tran)
                finishTransation(tran)
            default:
                break
            }
        }
    }
    
    func failedTransaction(tran:SKPaymentTransaction) {
        if tran.error?.code != SKErrorPaymentCancelled {
            debugPrint("tran error:\(tran.error?.localizedDescription)")
        }
    }
}
```
6，服务器验证

```
func verifyPruchase(transactionIdentifier:String){
        
        let receiptURL = NSBundle.mainBundle().appStoreReceiptURL

        let receiptData = NSData(contentsOfURL: receiptURL!)

        let encodeStr = receiptData?.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
        //发送encodeStr 到自己的服务器
		
    }
```
7，结束后，finishTransation

```
func finishTransation(transaction: SKPaymentTransaction) {
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
```


##注意点以及遇到的问题：
1.服务器在想Apple发送验证时出现21002错误，发现是自己这边Base64编码的问题，Apple提供了4中编码方式，我使用了第3个后，发现可以得到正确的返回结果

2.提交审核时，服务器端应该先请求AppStoreURL，也就是正式环境的URL，遇到21007错误后，再将凭证发送到SandBoxURL，因为Apple在审核时是使用SandBoxURL来审核的




