/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * Error codes and Error objects for McLaren Synth Kit
 *
 * Copyright (c) McLaren Labs 2024
 */

#import <Foundation/Foundation.h>

NSString *MSKContextErrorDomain = @"MSKContext";

@implementation NSError(MSKContext)

+ errorWithMSKContextError:(int)err str:(NSString*)str {

  NSError *nserr = [NSError errorWithDomain:MSKContextErrorDomain
                                       code:err
                                   userInfo:@{ NSLocalizedDescriptionKey: str }];
  return nserr;
}


+ errorWithMSKContextError:(int)err str:(NSString*)str under:(NSError*)under {

  NSError *nserr = [NSError errorWithDomain:MSKContextErrorDomain
                                       code:err
                                   userInfo:@{ NSLocalizedDescriptionKey: str,
                                               NSUnderlyingErrorKey: under }
                    ];
  return nserr;
}

@end

void MSKError_linker_function() {
}
