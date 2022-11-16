//
//  MoneroWalletWrapper.m
//  beldex-ios-wallet
//
//  Created by Sanada Yukimura on 5/18/22.
//

#import <Foundation/Foundation.h>
#import "BeldexWalletWrapper.h"
#import "BeldexConfig.h"

using namespace std;

struct WalletListenerImpl: Wallet::WalletListener
{
    BeldexWalletListener *_listener = NULL;
    
    ~WalletListenerImpl()
    {
        _listener = NULL;
    }
    
    void moneySpent(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    void moneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }
    
    void unconfirmedMoneyReceived(const std::string &txId, uint64_t amount)
    {
        // not implemented
    }

    void newBlock(uint64_t height)
    {
        if (_listener && _listener.newBlockHandler) {
            _listener.newBlockHandler(height);
        }
    }

    void updated()
    {
        // not implemented
    }

    void refreshed()
    {
        if (_listener && _listener.refreshHandler) {
            _listener.refreshHandler();
        }
    }
    
    void registerListener(BeldexWalletListener *listener)
    {
        _listener = listener;
    }
};


#pragma mark - Data

@interface BeldexWalletWrapper ()
{
    Wallet::Wallet* beldex_wallet;
    WalletListenerImpl* beldex_walletListener;
    Wallet::PendingTransaction* beldex_pendingTransaction;
}
@end

@implementation BeldexWalletWrapper

- (instancetype)init {
    if (self = [super init]) {
        beldex_wallet = nullptr;
    }
    return self;
}

+ (BeldexWalletWrapper *)init_beldex_wallet:(Wallet::Wallet *)beldex_wallet {
    auto stat = beldex_wallet->status();
    
    if (stat.first != Wallet::Wallet::Status_Ok) return NULL;
#if DEBUG
    Wallet::WalletManagerFactory::setLogLevel(Wallet::WalletManagerFactory::LogLevel_Max);
#endif
    BeldexWalletWrapper *walletWrapper = [[BeldexWalletWrapper alloc] init];
    walletWrapper->beldex_wallet = beldex_wallet;
    cout<<"beldex_wallet<><> init_Wallet---->"<< &beldex_wallet<< endl;
    return walletWrapper;
}

+ (BeldexWalletWrapper *)generateWithPath:(NSString *)path
                                 password:(NSString *)password
                                 language:(NSString *)language {
    struct Wallet::WalletManagerBase *walletManager = Wallet::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    string utf8Lg = [language UTF8String];
    Wallet::Wallet* beldex_wallet = walletManager->createWallet(utf8Path, utf8Pwd, utf8Lg, netType);
    cout<<"beldex_wallet---->"<< &beldex_wallet << endl;
    return [self init_beldex_wallet:beldex_wallet];
}

+ (BeldexWalletWrapper *)recoverWithSeed:(NSString *)seed
                                    path:(NSString *)path
                                password:(NSString *)password {
    struct Wallet::WalletManagerBase *walletManager = Wallet::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    string utf8Seed = [seed UTF8String];
    Wallet::Wallet* beldex_wallet = walletManager->recoveryWallet(utf8Path, utf8Pwd, utf8Seed, netType, 0, 1);
    return [self init_beldex_wallet:beldex_wallet];
}


+ (BeldexWalletWrapper *)openExistingWithPath:(NSString *)path
                                     password:(NSString *)password {
    struct Wallet::WalletManagerBase *walletManager = Wallet::WalletManagerFactory::getWalletManager();
    string utf8Path = [path UTF8String];
    string utf8Pwd = [password UTF8String];
    Wallet::Wallet* beldex_wallet = walletManager->openWallet(utf8Path, utf8Pwd, netType);
    return [self init_beldex_wallet:beldex_wallet];
}


- (void)addListener {
    if (beldex_walletListener) return;
    WalletListenerImpl * impl = new WalletListenerImpl();
    beldex_wallet->setListener(impl);
    beldex_walletListener = impl;
}

- (void)setBlocksRefresh:(BeldexWalletRefreshHandler)refresh newBlock:(BeldexWalletNewBlockHandler)newBlock {
    [self addListener];
    beldex_walletListener->registerListener(NULL);
    BeldexWalletListener *listener = [[BeldexWalletListener alloc] init];
    listener.newBlockHandler = newBlock;
    listener.refreshHandler = refresh;
    beldex_walletListener->registerListener(listener);
}
- (void)setDelegate:(id<BeldexWalletDelegate>)delegate {
    __weak typeof(delegate) weakDelegate = delegate;
    __weak typeof(self) weakSelf = self;
    [self setBlocksRefresh:^{
        if (weakSelf && weakDelegate && [weakDelegate respondsToSelector:@selector(beldexWalletRefreshed:)]) {
            BeldexWalletWrapper * wallet = weakSelf;
            [weakDelegate beldexWalletRefreshed:(wallet)];
        }
    } newBlock:^(uint64_t curreneight) {
        if (weakSelf && weakDelegate && [weakDelegate respondsToSelector:@selector(beldexWalletNewBlock:currentHeight:)]) {
            BeldexWalletWrapper * wallet = weakSelf;
            [weakDelegate beldexWalletNewBlock:wallet currentHeight:curreneight];
        }
    }];
}

- (BOOL)connectToDaemon:(NSString *)daemonAddress {
    if (!beldex_wallet) return NO;
    return beldex_wallet->init([daemonAddress UTF8String]);
}

- (BOOL)connectToDaemon:(NSString *)daemonAddress delegate:(id<BeldexWalletDelegate>)delegate {
    [self setDelegate:delegate];
    return [self connectToDaemon:daemonAddress];
}


- (BOOL)save {
    if (beldex_wallet) {
        return beldex_wallet->store(beldex_wallet->path());
    }
    return NO;
}

+ (NSString *)displayAmount:(uint64_t)amount {
    string amountStr = Wallet::Wallet::displayAmount(amount);
    return objc_str_dup(amountStr);
}

- (NSString *)getSeedString:(NSString *)language {
    string seed = "";
    if (beldex_wallet) {
        beldex_wallet->setSeedLanguage([language UTF8String]);
        seed = beldex_wallet->seed();
    }
    return objc_str_dup(seed);
}

- (NSString *)name {
    NSString *name = @"";
    if (beldex_wallet) {
        NSString *filename = objc_str_dup(beldex_wallet->filename());
        NSString *lastItem = [[filename componentsSeparatedByString:@"/"] lastObject];
        if (lastItem) {
            name = lastItem;
        }
    }
    return name;
}

- (NSString *)publicAddress {
    string address  = "";
    if (beldex_wallet) {
        address = beldex_wallet->address();
    }
    return objc_str_dup(address);
}

- (NSString *)publicViewKey {
    string key  = "";
    if (beldex_wallet) {
        key = beldex_wallet->publicViewKey();
    }
    return objc_str_dup(key);
}

- (NSString *)publicSpendKey {
    string key  = "";
    if (beldex_wallet) {
        key = beldex_wallet->publicSpendKey();
    }
    return objc_str_dup(key);
}
- (NSString *)secretViewKey {
    string key  = "";
    if (beldex_wallet) {
        key = beldex_wallet->secretViewKey();
    }
    return objc_str_dup(key);
}
- (NSString *)secretSpendKey {
    string key  = "";
    if (beldex_wallet) {
        key = beldex_wallet->secretSpendKey();
    }
    return objc_str_dup(key);
}

- (uint64_t)balance {
    if (beldex_wallet) {
        return beldex_wallet->balance();
    }
    return 0;
}

- (NSArray<BeldexSubAddress *> *)fetchSubAddressWithAccountIndex:(uint32_t)index {
    NSMutableArray<BeldexSubAddress *> *result = [NSMutableArray array];
    if (beldex_wallet) {
        Wallet::Subaddress * subAddress = beldex_wallet->subaddress();
        if (subAddress) {
            subAddress->refresh(index);
            std::vector<Wallet::SubaddressRow *> all = subAddress->getAll();
            std::size_t allCount = all.size();
            for (std::size_t i = 0; i < allCount; ++i) {
                Wallet::SubaddressRow *item = all[i];
                [result addObject:[[BeldexSubAddress alloc] initWithRowId:item->getRowId()
                                                                  address:objc_str_dup(item->getAddress())
                                                                    label:objc_str_dup(item->getLabel())]];
            }
        }
    }
    return result;
}
- (uint64_t)restoreHeight {
    if (beldex_wallet) {
        return beldex_wallet->getRefreshFromBlockHeight();
    }
    return 0;
}

- (void)startRefresh {
    if (beldex_wallet) {
        beldex_wallet->startRefresh();
    }
}

- (int64_t)transactionFee {
    if (beldex_pendingTransaction) {
        return beldex_pendingTransaction->fee();
    }
    return -1;
}


- (NSArray<BeldexTrxHistory *> *)fetchTransactionHistory {
    NSMutableArray<BeldexTrxHistory *> *result = [NSMutableArray array];
    if (beldex_wallet) {
        Wallet::TransactionHistory *history = beldex_wallet->history();
        if (history) {
            history->refresh();
            std::vector<Wallet::TransactionInfo *> allTransactionInfo = history->getAll();
            for (std::size_t i = 0; i < history->count(); ++i) {
                Wallet::TransactionInfo *transactionInfo = allTransactionInfo[i];
                BeldexTrxHistory * trx = [[BeldexTrxHistory alloc] init];
                trx.direction = (TrxDirection)transactionInfo->direction();
                trx.isPending = transactionInfo->isPending();
                trx.isFailed = transactionInfo->isFailed();
                trx.amount = transactionInfo->amount();
                trx.fee = transactionInfo->fee();
                trx.confirmations = transactionInfo->confirmations();
                trx.timestamp = transactionInfo->timestamp();
                trx.blockHeight = transactionInfo->blockHeight();
                trx.hashValue = objc_str_dup(transactionInfo->hash());
                trx.label = objc_str_dup(transactionInfo->label());
                trx.paymentId = objc_str_dup(transactionInfo->paymentId());
                trx.unlockTime = transactionInfo->unlockTime();
                [result addObject:trx];
            }
        }
    }
    return result;
}



@end
