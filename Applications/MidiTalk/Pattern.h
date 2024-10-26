/** -*- mode: objc -*-
 *
 * Extend MSKPattern for StepTalk
 *   - implement play: operator
 *   - allow sync: to work with selectors
 *
 * McLaren Labs 2024
 */

#import "Foundation/Foundation.h"
#import "McLarenSynthKit/MSKPattern.h"

@interface Pattern : MSKPattern

- (void) play:(id)block;

@end

