/*
 * Copyright (C) 2012 Soomla Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "StorageManager.h"
#import "KeyValDatabase.h"
#import "VirtualCurrencyStorage.h"
#import "VirtualGoodStorage.h"
#import "NonConsumableStorage.h"
#import "ObscuredNSUserDefaults.h"
#import "StoreConfig.h"
#import "StoreDatabase.h"
#import "StoreEncryptor.h"

@interface StorageManager (Private)
- (void)migrateOldData;
@end

@implementation StorageManager

@synthesize kvDatabase, virtualCurrencyStorage, virtualGoodStorage, nonConsumableStorage;

+ (StorageManager*)getInstance{
    static StorageManager* _instance = nil;
    
    @synchronized( self ) {
        if( _instance == nil ) {
            _instance = [[StorageManager alloc ] init];
        }
    }
    
    return _instance;
}

- (void)migrateOldData {
    if ([StoreDatabase checkDatabaseExists]) {
        NSLog(@"Old store database doesn't exist. Nothing to migrate.");
        return;
    }
    
    NSLog(@"Old store database exists. Migrating now!");
    
    StoreDatabase* storeDatabase = [[StoreDatabase alloc] init];
    
    NSArray* currencies = [storeDatabase getCurrencies];
    for (NSDictionary* dict in currencies) {
        NSString* itemId = [dict valueForKey:DICT_KEY_ITEM_ID];
        itemId = [StoreEncryptor decryptToString:itemId];
        NSString* balanceStr = [dict valueForKey:DICT_KEY_BALANCE];
        
        NSString* key = [StoreEncryptor encryptString:[KeyValDatabase keyCurrencyBalance:itemId]];
        
        [kvDatabase setVal:balanceStr forKey:key];
    }
    
    NSArray* goods = [storeDatabase getGoods];
    for (NSDictionary* dict in goods) {
        NSString* itemId = [dict valueForKey:DICT_KEY_ITEM_ID];
        itemId = [StoreEncryptor decryptToString:itemId];
        NSString* balanceStr = [dict valueForKey:DICT_KEY_BALANCE];
        NSString* equippedStr = [dict valueForKey:DICT_KEY_EQUIP];
        
        NSString* key = [StoreEncryptor encryptString:[KeyValDatabase keyGoodBalance:itemId]];
        [kvDatabase setVal:balanceStr forKey:key];
        
        if (equippedStr) {
            key = [StoreEncryptor encryptString:[KeyValDatabase keyGoodEquipped:itemId]];
            [kvDatabase setVal:equippedStr forKey:key];
        }
    }
    
    NSArray* noncons = [storeDatabase getNonConsumables];
    for (NSDictionary* dict in noncons) {
        NSString* productId = [dict valueForKey:DICT_KEY_PRODUCT_ID];
        productId = [StoreEncryptor decryptToString:productId];
        
        NSString* key = [StoreEncryptor encryptString:[KeyValDatabase keyNonConsExists:productId]];
        
        [kvDatabase setVal:@"" forKey:key];
    }
    
    NSString* storeInfo = [storeDatabase getStoreInfo];
    NSString* key = [StoreEncryptor encryptString:[KeyValDatabase keyMetaStoreInfo]];
    [kvDatabase setVal:storeInfo forKey:key];
    
    NSString* storefrontInfo = [storeDatabase getStoreInfo];
    key = [StoreEncryptor encryptString:[KeyValDatabase keyMetaStorefrontInfo]];
    [kvDatabase setVal:storefrontInfo forKey:key];
    
//    [StoreDatabase purgeDatabase];
    
    NSLog(@"Finished Migrating old database!");
}

- (id)init{
    self = [super init];
    if (self){
        self.kvDatabase = [[KeyValDatabase alloc] init];
        self.virtualCurrencyStorage = [[VirtualCurrencyStorage alloc] init];
        self.virtualGoodStorage = [[VirtualGoodStorage alloc] init];
        self.nonConsumableStorage = [[NonConsumableStorage alloc] init];
        
        [self migrateOldData];
        
        int mt_ver = [ObscuredNSUserDefaults intForKey:@"MT_VER"];
        int sa_ver_old = [ObscuredNSUserDefaults intForKey:@"SA_VER_OLD"];
        int sa_ver_new = [ObscuredNSUserDefaults intForKey:@"SA_VER_NEW"];
        if (mt_ver < METADATA_VERSION || sa_ver_old < sa_ver_new) {
            [ObscuredNSUserDefaults setInt:METADATA_VERSION forKey:@"MT_VER"];
            [ObscuredNSUserDefaults setInt:sa_ver_new forKey:@"SA_VER_OLD"];
            
            [kvDatabase deleteKeyValWithKey:[KeyValDatabase keyMetaStoreInfo]];
            [kvDatabase deleteKeyValWithKey:[KeyValDatabase keyMetaStorefrontInfo]];
        }
    }
    
    return self;
}

@end