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

#import <Foundation/Foundation.h>

@class NonConsumableItem;

/**
 * This class provides basic storage operations on the App Store's Non-Consumable items.
 */
@interface NonConsumableStorage : NSObject

/**
 * Determines if the given Non-Consumable item exists.
 *
 * nonConsumableItem - the Non-Consumable item to check if exists.
 * return: true if exists, false otherwise
 */
- (BOOL)nonConsumableExists:(NonConsumableItem*)nonConsumableItem;

/**
 * Adds the given App Store Non-Consumable item to the storage.
 *
 * nonConsumableItem - the required App Store Non-Consumable item.
 * return: true if exists, false otherwise
 */
- (BOOL)add:(NonConsumableItem*)nonConsumableItem;

/**
 * Removes the given App Store Non-Consumable item from the storage.
 *
 * nonConsumableItem - the required App Store Non-Consumable item.
 * return: true if exists, false otherwise
 */
- (BOOL)remove:(NonConsumableItem*)nonConsumableItem;


@end
