/** -*- mode:objc -*-
 *
 * The Base Class for Models.
 *
 * A Model should implement setters and getters for its properties.
 * When a setter modifies the value of a property, it should set the 'modified' flag.
 * When a Model saves or restores itself it should clear the 'modified' flag.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>

@interface MSKModelBase : NSObject

@property (readonly) NSString *name;
@property (readwrite) BOOL modified;

- (id) init __attribute__((unavailable("This method is not available.  Please use initWithName:")));
- (id) initWithName:(NSString*)name;

// Future:
// - (BOOL) save:(NSUserDefaults*)dict withPrefix:(NSString*)prefix;
// - (BOOL) restore:(NSUserDefaults*)dict withPrefix:(NSString*)prefix;


@end
