//
//  Activity.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 28.04.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActivityInstance;

@interface Activity : NSManagedObject

@property (nonatomic, retain) NSString * imageFilename;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * totalDuration;
@property (nonatomic, retain) NSSet *instances;
@property (nonatomic, retain) NSNumber * index;

@end

@interface Activity (CoreDataGeneratedAccessors)

- (void)addInstancesObject:(ActivityInstance *)value;
- (void)removeInstancesObject:(ActivityInstance *)value;
- (void)addInstances:(NSSet *)values;
- (void)removeInstances:(NSSet *)values;

@end
