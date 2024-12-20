/** *-* mode; objc *-*
 *
 * Controller to hold array of MLExpressiveButtons
 *
 * McLaren Labs 2024
 *
 */

#import "MLButtonsController.h"
#import "GSTable-MLdecls.h"
#import "NSColor+ColorExtensions.h"

@implementation MLButtonsController

- (id) init {

  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) { // nsbox
    [self setTitle:@"Buttons"];
    [self setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    GSTable *tab = [[GSTable alloc] initWithNumberOfRows:2 numberOfColumns:4];

    [self  makeButtons];
    
    [tab putView: _but1
	   atRow: 0 column: 0 withMargins: 5];

    [tab putView: _but2
	   atRow: 0 column: 1 withMargins: 5];

    [tab putView: _but3
	   atRow: 0 column: 2 withMargins: 5];

    [tab putView: _but4
	   atRow: 0 column: 3 withMargins: 5];

    [tab putView: _but5
	   atRow: 1 column: 0 withMargins: 5];

    [tab putView: _but6
	   atRow: 1 column: 1 withMargins: 5];

    [tab putView: _but7
	   atRow: 1 column: 2 withMargins: 5];

    [tab putView: _but8
	   atRow: 1 column: 3 withMargins: 5];

    [tab setXResizingEnabled: YES forColumn: 0];
    [tab setXResizingEnabled: YES  forColumn: 1];
    [tab setXResizingEnabled: YES  forColumn: 2];
    [tab setXResizingEnabled: YES  forColumn: 3];
    
    [tab setYResizingEnabled: YES forRow: 0];
    [tab setYResizingEnabled: YES  forRow: 1];

    [self setContentView: tab];
    [self sizeToFit];
  }
  return self;

}

- (void) makeButtons {

  NSFont *font = [NSFont userFixedPitchFontOfSize:14.0];

  NSRect rect = NSMakeRect(50, 50, 95, 45);

  self.but1 = [[MLExpressiveButton alloc] initWithFrame:rect];
  [self.but1 setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [[self.but1 cell] setColor:[NSColor mcBlueColor]];
  self.but1.font = font;
  self.but1.title = @"but1";

  self.but2 = [[MLExpressiveButton alloc] initWithFrame:rect];
  [self.but2 setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [[self.but2 cell] setColor:[NSColor mcGreenColor]];
  self.but2.font = font;
  self.but2.title = @"but2";

  self.but3 = [[MLExpressiveButton alloc] initWithFrame:rect];
  [self.but3 setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [[self.but3 cell] setColor:[NSColor mcOrangeColor]];
  self.but3.font = font;
  self.but3.title = @"but3";

  self.but4 = [[MLExpressiveButton alloc] initWithFrame:rect];
  [self.but4 setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [[self.but4 cell] setColor:[NSColor mcPurpleColor]];
  self.but4.font = font;
  self.but4.title = @"but4";

  self.but5 = [[MLExpressiveButton alloc] initWithFrame:rect];
  [self.but5 setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [[self.but5 cell] setColor:[NSColor mcBlueColor]];
  self.but5.font = font;
  self.but5.title = @"but5";

  self.but6 = [[MLExpressiveButton alloc] initWithFrame:rect];
  [self.but6 setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [[self.but6 cell] setColor:[NSColor mcGreenColor]];
  self.but6.font = font;
  self.but6.title = @"but6";

  self.but7 = [[MLExpressiveButton alloc] initWithFrame:rect];
  [self.but7 setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [[self.but7 cell] setColor:[NSColor mcOrangeColor]];
  self.but7.font = font;
  self.but7.title = @"but7";

  self.but8 = [[MLExpressiveButton alloc] initWithFrame:rect];
  [self.but8 setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  [[self.but8 cell] setColor:[NSColor mcPurpleColor]];
  self.but8.font = font;
  self.but8.title = @"but8";
}

@end
