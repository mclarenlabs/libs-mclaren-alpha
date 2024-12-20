/**
 * Play Synth80 patches in MidiTalk.
 * One instance of this class plays one patch or sound.
 *
 * McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

@interface Synth80Synth : NSObject

- (id) initWithCtx:(MSKContext*)ctx;

- (NSString*) loadPatch:(NSString*)name;

- (BOOL) noteOn:(unsigned)note vel:(unsigned)vel;
- (BOOL) noteOff:(unsigned)note vel:(unsigned)vel;

@end
