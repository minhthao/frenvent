//
//  MyEventManager.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/11/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface MyEventManager : NSObject

-(void)loadData;
-(NSString *)getTitleForHeaderInSection:(NSInteger)section;
-(NSInteger)getNumberOfSections;
-(NSInteger)getNumberOfRowsInSection:(NSInteger)section;
-(Event *)getEventAtIndexPath:(NSIndexPath *)indexPath;

@end
