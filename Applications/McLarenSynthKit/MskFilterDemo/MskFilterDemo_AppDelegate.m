# import "MskFilterDemo_AppDelegate.h"

#import <AlsaSoundKit/AlsaSoundKit.h>
#import "NSObject+MLBlocks.h"
#import "GSTable-MLdecls.h"

@implementation AppDelegate {
  GSHbox *filtertypeHbox;
  GSHbox *fcHbox;
  GSHbox *fcmodHbox;
  GSVbox *vbox;
  GSHbox *hbox;
  NSButton *button;
  NSButton *playButton;

  NSFont *font;

  ASKSeq *seq;
  ASKSeqList *list;
}

- (id) init {
  if (self = [super init]) {

    srandom(time(NULL)); // seed pseudo-random number generator

    [self makeWindow];
    [self makeMenu];
  }
  return self;
}

- (void) makeFiltertypeRow {

  filtertypeHbox = [GSHbox new];
  [filtertypeHbox setAutoresizingMask: NSViewWidthSizable];
  
  // make slider
  self.filtertypeSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [self.filtertypeSlider setTitle:@"filter type"];

  // use bindings
  [self.filtertypeSlider bind:@"value"
	     toObject:self
	  withKeyPath:@"filtModel.filtertype"
	       options:nil];

  [self.filtertypeSlider setMinValue:0];
  [self.filtertypeSlider setMaxValue:9];
  [self.filtertypeSlider setNumberOfTickMarks:10];
  [self.filtertypeSlider setAllowsTickMarkValuesOnly:YES];
  [self.filtertypeSlider setContinuous:YES];
  [self.filtertypeSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  NSTextField *tomText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  [tomText bind:@"value"
      toObject:self
	  withKeyPath:@"filtModel.filtertype"
	options: @{
    NSValueTransformerBindingOption: [MSKFilterTypeValueTransformer new]
	}];


    // pack into row
  [filtertypeHbox addView:self.filtertypeSlider enablingXResizing:YES];
  [filtertypeHbox addView:tomText enablingXResizing:NO withMinXMargin:10.0];
}

- (void) makeFcRow {

  fcHbox = [GSHbox new];
  [fcHbox setAutoresizingMask: NSViewWidthSizable];
  
  // make slider
  self.fcSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [self.fcSlider setTitle:@"fc"];

  // use bindings
  [self.fcSlider bind:@"value"
	     toObject:self
	  withKeyPath:@"filtModel.fc"
	      options:nil];

  [self.fcSlider setMinValue:100];
  [self.fcSlider setMaxValue:5000];
  [self.fcSlider setContinuous:YES];
  [self.fcSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  NSTextField *fcText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  [fcText bind:@"value"
      toObject:self
	  withKeyPath:@"filtModel.fc"
       options:nil];

  // number formatter
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  NSMutableDictionary *attr = [NSMutableDictionary dictionary];

  [numberFormatter setFormat:@"#####.00"];
  [numberFormatter setMinimumFractionDigits:2];
  [numberFormatter setMaximumFractionDigits:2];
  [attr setObject:[NSColor redColor] forKey:@"NSColor"];
  [numberFormatter setTextAttributesForNegativeValues:attr];
  [fcText setFormatter:numberFormatter];

  // pack into row
  [fcHbox addView:self.fcSlider enablingXResizing:YES];
  [fcHbox addView:fcText enablingXResizing:NO withMinXMargin:10.0];
}

- (void) makeFcmodRow {
  fcmodHbox = [GSHbox new];
  [fcmodHbox setAutoresizingMask: NSViewWidthSizable];
  
  self.fcmodSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [self.fcmodSlider setTitle:@"fcmod"];
  
  // use bindings
  [self.fcmodSlider bind:@"value"
		toObject:self
	     withKeyPath:@"filtModel.fcmod"
		 options:nil];

  [self.fcmodSlider setMinValue:-12];
  [self.fcmodSlider setMaxValue:12];
  [self.fcmodSlider setContinuous:YES];
  [self.fcmodSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  NSTextField *fcmodText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  [fcmodText bind:@"value"
	 toObject:self
      withKeyPath:@"filtModel.fcmod"
	  options:nil];

  // number formatter
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  NSMutableDictionary *attr = [NSMutableDictionary dictionary];

  [numberFormatter setFormat:@"###.0"];
  [numberFormatter setMinimumFractionDigits:1];
  [numberFormatter setMaximumFractionDigits:1];
  [attr setObject:[NSColor redColor] forKey:@"NSColor"];
  [numberFormatter setTextAttributesForNegativeValues:attr];
  [fcmodText setFormatter:numberFormatter];

  // pack into row
  [fcmodHbox addView:self.fcmodSlider enablingXResizing:YES];
  [fcmodHbox addView:fcmodText enablingXResizing:NO withMinXMargin:10.0];

}

- (void) makeWidgets {

  font = [NSFont userFixedPitchFontOfSize:12.0];

  hbox = [GSHbox new];
  [hbox setDefaultMinXMargin: 5];
  [hbox setBorder: 5];
  // [hbox setAutoresizingMask: NSViewWidthSizable];

  /* Button clearing the table.  */
  button = [NSButton new]; 
  [button setBordered: YES];
  [button setButtonType: NSMomentaryPushButton];
  [button setTitle:  @"Clear"];
  [button setImagePosition: NSNoImage]; 
  [button setTarget: self];
  [button setAction: @selector(clearLog:)];
  // [button setAutoresizingMask: NSViewMaxXMargin];
  [button sizeToFit];
  [button setTag: 1];

  [hbox addView: button];

  /* Button playing the note again */
  playButton = [NSButton new];
  [playButton setBordered: YES];
  [playButton setButtonType: NSMomentaryPushButton];
  [playButton setTitle: @"Play"];
  [playButton setImagePosition: NSNoImage];
  [playButton setTarget: self];
  [playButton setAction: @selector(makeNote)];
  // [playButton setAutoresizingMask: NSViewMaxXMargin];
  [playButton sizeToFit];

  [hbox addView: playButton withMinXMargin:10.0];


  vbox = [GSVbox new];
  [vbox setDefaultMinYMargin: 5];
  [vbox setBorder: 5];

  [self makeFcmodRow];
  [self makeFcRow];
  [self makeFiltertypeRow];
  
  [vbox addView: fcmodHbox enablingYResizing:NO withMinYMargin:0];
  [vbox addView: fcHbox enablingYResizing:NO withMinYMargin:5];
  [vbox addView: filtertypeHbox enablingYResizing:NO withMinYMargin:5];
 
  // Size the textview and scrollview, knowing the sizes will be computed
  self.textview = [NSTextView new];
  [self.textview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];  

  NSScrollView *sv = [NSScrollView new];
  [sv setHasVerticalScroller:YES];
  [sv setDocumentView:self.textview];
  [sv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];  
  [sv setFrame:NSMakeRect(0, 0, 300, 200)];
  
  // [vbox addView: sv];
  [vbox addView: sv enablingYResizing:YES];
 
  [vbox addView: hbox enablingYResizing: NO];
}
  

- (void) makeMenu {
  
  // The main menu - must create before [NSApp run] to get some default behavior
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


- (void) makeWindow {
  NSRect winFrame;

  winFrame.size = NSMakeSize (400, 300);
  winFrame.origin = NSMakePoint (300, 400);

  self.win = [[NSWindow alloc]
		      initWithContentRect: winFrame
				styleMask: (NSWindowStyleMaskTitled
					    | NSWindowStyleMaskClosable
					    | NSWindowStyleMaskResizable
					    | NSWindowStyleMaskMiniaturizable)
				  backing:NSBackingStoreBuffered
				    defer:NO];

  [self.win setTitle: @"MSK Filter Demo"];
  // [self.win setReleasedWhenClosed: NO];

  // automatically save/restore window position by AppKit
  [self.win setFrameAutosaveName:@"MainWindow"];

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

- (void) makeContext {
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;
  request.persize = 1024;
  request.periods = 2;

  NSString *devName = @"default";

  NSError *error;
  BOOL ok;

  _ctx = [[MSKContext alloc] initWithName:devName
				andStream:SND_PCM_STREAM_PLAYBACK
				    error:&error];

  if (error != nil) {
    NSLog(@"MSKContext init error:%@", error);
    exit(1);
  }

  ok = [_ctx configureForRequest:request error:&error];
  if (ok == NO) {
    NSLog(@"MSKContext configure error:%@", error);
    exit(1);
  }

  ok = [_ctx startWithError:&error];
  if (ok == NO) {
    NSLog(@"MSKContext starting error:%@", error);
    exit(1);
  }
}

- (void) makeFxPath {

  self.filtModel = [[MSKFilterModel alloc] initWithName:@"filt1"];
  self.filtModel.filtertype = MSK_FILTER_MOOG;
  self.filtModel.fc = 2000;
  self.filtModel.q = 2.0;

  MSKGeneralFilter *filt = [[MSKGeneralFilter alloc] initWithCtx:_ctx];
  filt.sInput = _ctx.pbuf;
  filt.model = self.filtModel;
  [filt compile];

  [_ctx addFx:filt];
}

- (void) makeNote {

  self.oscModel = [[MSKOscillatorModel alloc] initWithName:@"osc1"];
  self.oscModel.osctype = MSK_OSCILLATOR_TYPE_SQUARE;

  self.envModel = [[MSKEnvelopeModel alloc] initWithName:@"env1"];
  self.envModel.attack = 0.5;
  self.envModel.decay = 0.1;
  self.envModel.sustain = 0.9;
  self.envModel.rel = 2.0;

  MSKLinEnvelope *env = [[MSKLinEnvelope alloc] initWithCtx:_ctx];
  env.oneshot = YES;
  env.shottime = 10.0;		// 10 seconds
  env.model = _envModel;
  [env compile];

  int note = (random() % 12) + 64;

  MSKGeneralOscillator *osc = [[MSKGeneralOscillator alloc] initWithCtx:_ctx];
  osc.iNote = note;
  osc.sEnvelope = env;
  osc.model = _oscModel;
  [osc compile];

  [_ctx addVoice:osc];

  MSKGeneralOscillator *osc2 = [[MSKGeneralOscillator alloc] initWithCtx:_ctx];
  osc2.iNote = note+7;
  osc2.sEnvelope = env;
  osc2.model = _oscModel;
  [osc2 compile];

  [_ctx addVoice:osc2];

  [self appendLog:[NSString stringWithFormat:@"Playing note %d", note]];
  

}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
  ASKError_linker_function(); // cause NSError category to be linked
  MSKError_linker_function();

  [self appendLog:@"Welcome to MSK Filter Demo"];
  
  [self makeWidgets];
  [vbox sizeToFit];
  [self.win setMinSize: [NSWindow frameRectForContentRect: vbox.frame
						styleMask: [self.win styleMask]].size];
  [self.win setContentView: vbox];

  // [self makeWindow];
  // [self makeMenu];

  [self.win makeKeyAndOrderFront:self];
  [self.win orderFrontRegardless];

  [self makeContext];
  [self makeFxPath];
  [self makeNote];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

}

@end
