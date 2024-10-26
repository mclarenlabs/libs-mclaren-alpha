/** *-* mode; objc *-*
 *
 * Controller to hold MLPiano and switches
 *
 * McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MLPianoController.h"

@implementation MLPianoController

- (id) initWithFrame: (NSRect)rect {
  if (self = [super initWithFrame: rect]) {
  NSRect rect = NSMakeRect(50, 50, 15*40, 100); // 600x100

  self.piano = [[MLPiano alloc] initWithFrame:rect];
  self.piano.totalWholeNotes = 15;

  // self.piano.target = self; // send events to NSApp
  
  [self addSubview:self.piano];

  // octave up/down and display
  NSButton *down = [NSButton new];
  [down setTitle:@"▼"];
  [down setFont:[NSFont userFontOfSize:20.0]];
  [down setFrame:NSMakeRect(50, 10, 25, 25)];
  [down setTarget: self];
  [down setAction: @selector(octaveDownPressed:)];
  self.octaveDown = down;
  
  NSButton *up = [NSButton new];
  [up setTitle:@"▲"];
  [up setFont:[NSFont userFontOfSize:20.0]];
  [up setFrame:NSMakeRect(80, 10, 25, 25)];
  [up setTarget: self];
  [up setAction: @selector(octaveUpPressed:)];
  self.octaveUp = up;
  
  LabelWithValue *lv = [LabelWithValue new];
  [lv setLabel:@"octave:"];
  [lv setValue:@"c4"];
  [lv setFrame:NSMakeRect(110, 10, 125, 25)];
  self.octaveLabel = lv;
  
  [self  addSubview:up];
  [self  addSubview:down];
  [self  addSubview:lv];
  }
  return self;
}
			  
- (void) octaveUpPressed:(id)sender
{
  int octave = self.piano.octave;
  if (octave < 8) 
    {
      octave +=1;
      self.piano.octave = octave;
      [self.octaveLabel setValue:[NSString stringWithFormat:@"c%d", octave]];
    }
}

- (void) octaveDownPressed:(id)sender
{
  int octave = self.piano.octave;
  if (octave > 0) 
    {
      octave -= 1;
      self.piano.octave = octave;
      [self.octaveLabel setValue:[NSString stringWithFormat:@"c%d", octave]];
    }
}


@end



