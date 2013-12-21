//
//  Groups.h
//  TUDiReader
//
//  Created by Martin Weissbach on 21/12/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Group;

@interface Groups : NSObject

- (void)addGroup:(Group *)group;
- (void)addGroups:(NSSet *)groups;

- (void)removeGroup:(Group *)group;
- (void)removeGroups:(NSSet *)groups;

- (Group *)groupAtIndex:(NSUInteger)position;
- (NSArray *)allGroups;

- (NSUInteger)count;

@end
