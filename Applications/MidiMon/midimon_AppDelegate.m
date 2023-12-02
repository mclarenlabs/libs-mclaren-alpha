# import "midimon_AppDelegate.h"

#import <AlsaSoundKit/AlsaSoundKit.h>
#import "NSObject+MLBlocks.h"

@implementation AppDelegate {
  GSVbox *vbox;
  GSHbox *hbox;
  NSButton *button;

  NSFont *font;

  ASKSeq *seq;
  ASKSeqList *list;
}

- (void) makeSeq {

  ASKSeqOptions *options = [[ASKSeqOptions alloc] init];
  options->_sequencer_name = "midimon";

  NSError *error;
  seq = [[ASKSeq alloc] initWithOptions:options error:&error];
  if (error != nil) {
    NSLog(@"Could not create sequencer.  Error:%@", error);
    exit(1);
  }

  AppDelegate __weak *wself = self;
  [seq addListener:^(NSArray<ASKSeqEvent*> *events) {
      for (ASKSeqEvent* e in events) {
	[wself appendLog:[NSString stringWithFormat:@"%@", e]];
      }
    }];

  

  list = [[ASKSeqList alloc] initWithSeq:seq];
  
  for (ASKSeqClientInfo *c in list.clientinfos) {
    [self appendLog:[NSString stringWithFormat:@"Client:%@", c]];
  }

  for (ASKSeqPortInfo *p in list.portinfos) {
    [self appendLog:[NSString stringWithFormat:@"Port:%@", p]];

    NSError *error;
    // listen to new port
    [seq connectFrom:p.client port:p.port error:&error];

    if (error != nil) {
      [self appendLog:[NSString stringWithFormat:@"connectFrom error:%@", error]];
    }
  }

  [list onClientAdded:^(ASKSeqClientInfo* c) {
      [self appendLog:[NSString stringWithFormat:@"Client Added:%@", c]];
    }];

  [list onClientDeleted:^(ASKSeqClientInfo* c) {
      [self appendLog:[NSString stringWithFormat:@"Client Deleted:%@", c]];
    }];

  [list onPortAdded:^(ASKSeqPortInfo* p) {
      [self appendLog:[NSString stringWithFormat:@"Port Added:%@", p]];

      NSError *error;
      // listen to new port
      [seq connectFrom:p.client port:p.port error:&error];

      if (error != nil) {
	[self appendLog:[NSString stringWithFormat:@"connectFrom error:%@", error]];
      }
    }];

  [list onPortDeleted:^(ASKSeqPortInfo* p) {
      [self appendLog:[NSString stringWithFormat:@"Port Deleted:%@", p]];
    }];

}

- (void) makeWidgets {

  font = [NSFont userFixedPitchFontOfSize:12.0];

  hbox = [GSHbox new];
  [hbox setDefaultMinXMargin: 5];
  [hbox setBorder: 5];
  [hbox setAutoresizingMask: NSViewWidthSizable];

  /* Button clearing the table.  */
  button = [NSButton new]; 
  [button setBordered: YES];
  [button setButtonType: NSMomentaryPushButton];
  [button setTitle:  @"Clear"];
  [button setImagePosition: NSNoImage]; 
  [button setTarget: self];
  [button setAction: @selector(clearLog:)];
  [button setAutoresizingMask: NSViewMaxXMargin];
  [button sizeToFit];
  [button setTag: 1];

  [hbox addView: button];

  vbox = [GSVbox new];
  [vbox setDefaultMinYMargin: 5];
  [vbox setBorder: 5];
 
  // Size the textview and scrollview, knowing the sizes will be computed
  self.textview = [NSTextView new];
  [self.textview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];  

  NSScrollView *sv = [NSScrollView new];
  [sv setHasVerticalScroller:YES];
  [sv setDocumentView:self.textview];
  [sv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];  
  [sv setFrame:NSMakeRect(0, 0, 300, 200)];
  
  [vbox addView: sv];
 
  [vbox addView: hbox  enablingYResizing: NO];
}
  

- (void) makeMenu {
  
  self.mainMenu = [NSMenu new];
  NSMenu *appMenu = [NSMenu new];
  NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
  appMenuItem.title = @"File";

  NSMenuItem *quitMenuItem = [[NSMenuItem alloc]
			       initWithTitle:@"Quit"
				      action:@selector(terminate:)
			       keyEquivalent:@"q"];

  [self.mainMenu addItem:appMenuItem];
  [appMenu addItem:quitMenuItem];
  [appMenuItem setSubmenu:appMenu];

  [NSApp setMainMenu:self.mainMenu];
}

/*
 * main vbox constructed before calling this
 */

- (void) makeWindow {
  NSRect winFrame;

  winFrame.size = [vbox frame].size;
  winFrame.origin = NSMakePoint (300, 400);

  self.win = [[NSWindow alloc]
		      initWithContentRect: winFrame
				styleMask: (NSWindowStyleMaskTitled
					    | NSWindowStyleMaskClosable
					    | NSWindowStyleMaskResizable
					    | NSWindowStyleMaskMiniaturizable)
				  backing:NSBackingStoreBuffered
				    defer:NO];

  [self.win setTitle: @"MIDI Monitor"];
  // [self.win setReleasedWhenClosed: NO];

  // automatically save/restore window position by AppKit
  [self.win setFrameAutosaveName:@"MainWindow"];

  [self.win setContentView: vbox];
  [self.win setMinSize: [NSWindow frameRectForContentRect: winFrame
						styleMask: [self.win styleMask]].size];

}

- (void) clearLog:(NSControl*)sender {
  NSString *news = @"";
  NSString *olds = self.textview.textStorage.string;
  NSRange allChars = NSMakeRange(0, [olds length]);

  [self performBlockOnMainThread:^{
      [self.textview.textStorage replaceCharactersInRange:allChars
					       withString:news];
    }];
}

- (void) appendLog:(NSString*)message {

  NSString *messageWithNewLine = [message stringByAppendingString:@"\n"];

  // determine if the view should scroll - it should if at bottom
  double diff = NSMaxY(self.textview.visibleRect) - NSMaxY(self.textview.bounds);
  BOOL scroll = fabs(diff) < 5;

  [self performBlockOnMainThread:^{

      // Append string to textview
      NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:messageWithNewLine];
      NSRange allChars = NSMakeRange(0, [as length]);
      [as addAttribute:NSFontAttributeName value:font range:allChars];
    
      [self.textview.textStorage appendAttributedString:as];

      [self.textview.textStorage addAttribute:NSFontAttributeName value:font range:allChars];

      // make visible the very end
      if (scroll)
	[self.textview scrollRangeToVisible: NSMakeRange(self.textview.string.length, 0)];
    }];
}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
  ASKError_linker_function(); // cause NSError category to be linked

  [self appendLog:@"Welcome to MidiMon"];
  
  [self makeSeq];

  [self makeWidgets];
  [self makeWindow];
  [self makeMenu];

  [self.win makeKeyAndOrderFront:self];
  [self.win orderFrontRegardless];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

}

@end
