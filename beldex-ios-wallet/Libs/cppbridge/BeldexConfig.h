//
//  BeldexConfig.h
//  beldex-ios-wallet
//
//  Created by Sanada Yukimura on 6/2/22.
//

#import "wallet2_api.h"

#pragma mark - const

const Wallet::NetworkType netType = Wallet::TESTNET;

#pragma mark - method

static NSString * objc_str_dup(std::string cppstr) {
    const char * cstr = cppstr.c_str();
    return [NSString stringWithUTF8String:strdup(cstr)];
};


#pragma mark - enum

enum beldex_status {
    Status_Ok,
    Status_Error,
    Status_Critical
};


#pragma mark - struct


