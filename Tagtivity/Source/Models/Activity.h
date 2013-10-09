//
//  Activity.h
//  Tagtivity
//
//  Created by Rafał Grodziński on 08.10.2013.
//  Copyright (c) 2013 UnalignedByte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ActivityInstance;

@interface Activity : NSManagedObject

@property (nonatomic, retain) NSString * imageFilename;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * totalDuration;
@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSSet *instances;
@end

@interface Activity (CoreDataGeneratedAccessors)

- (void)addInstancesObject:(ActivityInstance *)value;
- (void)removeInstancesObject:(ActivityInstance *)value;
- (void)addInstances:(NSSet *)values;
- (void)removeInstances:(NSSet *)values;

@end
