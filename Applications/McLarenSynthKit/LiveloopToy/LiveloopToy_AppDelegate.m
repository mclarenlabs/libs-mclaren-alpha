#import "LiveloopToy_AppDelegate.h"

#import <AlsaSoundKit/AlsaSoundKit.h>
#import "NSObject+MLBlocks.h"
#import "GSTable-MLdecls.h"
#import "PatternManager.h"

@implementation AppDelegate {
  GSHbox *tempoHbox;
  GSHbox *osctypeHbox;
  GSHbox *loop1Hbox;
  GSVbox *vbox;
  GSHbox *hbox;

  NSFont *font;
}

- (id) init {
  if (self = [super init]) {

    srandom(time(NULL)); // seed pseudo-random number generator

    [self makeWindow];
    [self makeMenu];
  }
  return self;
}

- (void) makeTempoRow {
  tempoHbox = [GSHbox new];
  [tempoHbox setAutoresizingMask: NSViewWidthSizable];
  
  self.tempoSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [self.tempoSlider setTitle:@"tempo"];
  [self.tempoSlider setAction:@selector(tempoChanged:)];
  
  // use bindings
  [self.tempoSlider bind:@"value"
		toObject:self
	     withKeyPath:@"tempo"
		 options:nil];

  [self.tempoSlider setMinValue:30];
  [self.tempoSlider setMaxValue:150];
  [self.tempoSlider setContinuous:YES];
  [self.tempoSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  NSTextField *tempoText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  [tempoText bind:@"value"
	 toObject:self
      withKeyPath:@"tempo"
	  options:nil];

  // number formatter
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  NSMutableDictionary *attr = [NSMutableDictionary dictionary];

  [numberFormatter setFormat:@"###.0"];
  [numberFormatter setMinimumFractionDigits:1];
  [numberFormatter setMaximumFractionDigits:1];
  [attr setObject:[NSColor redColor] forKey:@"NSColor"];
  [numberFormatter setTextAttributesForNegativeValues:attr];
  [tempoText setFormatter:numberFormatter];

  // pack into row
  [tempoHbox addView:self.tempoSlider enablingXResizing:YES];
  [tempoHbox addView:tempoText enablingXResizing:NO withMinXMargin:10.0];

}

- (void) loop1EnableToggle:(NSButton*)sender {

  long val = [sender integerValue];
  NSLog(@"loop1Enable:%ld", val);

  if (val == 0) {
    [_sched disableLiveloop:@"loop1"];
  }
  
  if (val == 1) {
    [_sched enableLiveloop:@"loop1"];
  }
  

}

- (void) loop1PatternChanged:(NSSlider*)sender {

  NSLog(@"loop1PatternChanged:%d", _loop1Selection);

  if (_loop1Selection == 1) {
    [_sched setLiveloop:@"loop1" pat:_mgr.pat1];
  }

  if (_loop1Selection == 2) {
    [_sched setLiveloop:@"loop1" pat:_mgr.pat2];
  }

  if (_loop1Selection == 3) {
    [_sched setLiveloop:@"loop1" pat:_mgr.pat3];
  }

}

- (void) makeLoop1Row {
  loop1Hbox = [GSHbox new];
  [loop1Hbox setAutoresizingMask: NSViewWidthSizable];

  self.loop1EnableButton = [NSButton new];
  [self.loop1EnableButton setBordered: YES];
  // [self.loop1EnableButton setButtonType: NSToggleButton];
  [self.loop1EnableButton setButtonType: NSPushOnPushOffButton];
  [self.loop1EnableButton setTitle:@"Enabled"];
  [self.loop1EnableButton setIntegerValue:1];
  [self.loop1EnableButton setTarget: self];
  [self.loop1EnableButton setAction: @selector(loop1EnableToggle:)];
  
  // [self.loop1EnableButton setImagePosition: NSNoImage];
  [self.loop1EnableButton sizeToFit];
  [self.loop1EnableButton setTag: 2];

  _loop1Selection = 1; // initial value

  self.loop1Slider = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [self.loop1Slider setTitle:@"Loop1 Pattern"];
  [self.loop1Slider setMinValue:1];
  [self.loop1Slider setMaxValue:3];
  [self.loop1Slider setNumberOfTickMarks:3];
  [self.loop1Slider setAllowsTickMarkValuesOnly:YES];
  [self.loop1Slider setContinuous:NO];
  [self.loop1Slider setAutoresizingMask: NSViewWidthSizable];
  [self.loop1Slider setTarget: self];
  [self.loop1Slider setAction: @selector(loop1PatternChanged:)];

  // bind value
  [self.loop1Slider bind:@"value"
		toObject:self
	     withKeyPath:@"loop1Selection"
		 options:nil];

  // make text
  self.loop1Text = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  [self.loop1Text bind:@"value"
	      toObject:self
	   withKeyPath:@"loop1Selection"
	       options:nil];

  // number formatter
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];

  [numberFormatter setPositivePrefix:@"Pattern "];
  [numberFormatter setFormat:@"###"];
  [numberFormatter setMinimumFractionDigits:0];
  [numberFormatter setMaximumFractionDigits:0];
  [self.loop1Text setFormatter:numberFormatter];

  // pack into row
  [loop1Hbox addView:self.loop1EnableButton enablingXResizing:NO];
  [loop1Hbox addView:self.loop1Slider enablingXResizing:YES withMinXMargin:10.0];
  [loop1Hbox addView:self.loop1Text enablingXResizing:NO withMinXMargin:10.0];


}

- (void) makeWidgets {

  font = [NSFont userFixedPitchFontOfSize:12.0];

  hbox = [GSHbox new];
  [hbox setDefaultMinXMargin: 5];
  [hbox setBorder: 5];
  // [hbox setAutoresizingMask: NSViewWidthSizable];

  /* Start Button */
  _clearButton = [NSButton new]; 
  [_clearButton setBordered: YES];
  [_clearButton setButtonType: NSMomentaryPushButton];
  [_clearButton setTitle:  @"Clear"];
  [_clearButton setImagePosition: NSNoImage]; 
  [_clearButton setTarget: self];
  [_clearButton setAction: @selector(clearLog:)];
  // [_clearButton setAutoresizingMask: NSViewMaxXMargin];
  [_clearButton sizeToFit];
  [_clearButton setTag: 1];

  [hbox addView: _clearButton];

  /* Start Button */
  _startButton = [NSButton new]; 
  [_startButton setBordered: YES];
  [_startButton setButtonType: NSMomentaryPushButton];
  [_startButton setTitle:  @"Start"];
  [_startButton setImagePosition: NSNoImage]; 
  [_startButton setTarget: self];
  [_startButton setAction: @selector(startMetronome:)];
  // [_startButton setAutoresizingMask: NSViewMaxXMargin];
  [_startButton sizeToFit];
  [_startButton setTag: 1];

  [hbox addView: _startButton withMinXMargin:20];

  /* Stop Button */
  _stopButton = [NSButton new];
  [_stopButton setBordered: YES];
  [_stopButton setButtonType: NSMomentaryPushButton];
  [_stopButton setTitle: @"Stop"];
  [_stopButton setImagePosition: NSNoImage];
  [_stopButton setTarget: self];
  [_stopButton setAction: @selector(stopMetronome:)];
  // [_stopButton setAutoresizingMask: NSViewMaxXMargin];
  [_stopButton sizeToFit];

  [hbox addView: _stopButton withMinXMargin:5.0];


  /* Continue Button */
  _continueButton = [NSButton new];
  [_continueButton setBordered: YES];
  [_continueButton setButtonType: NSMomentaryPushButton];
  [_continueButton setTitle: @"Continue"];
  [_continueButton setImagePosition: NSNoImage];
  [_continueButton setTarget: self];
  [_continueButton setAction: @selector(continueMetronome:)];
  // [_continueButton setAutoresizingMask: NSViewMaxXMargin];
  [_continueButton sizeToFit];

  [hbox addView: _continueButton withMinXMargin:5.0];


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
  
  // [vbox addView: sv];
  [vbox addView: sv enablingYResizing:YES];

  // Make the tempo slider
  [self makeTempoRow];
  [vbox addView: tempoHbox enablingYResizing:NO withMinYMargin:10];
 
  // Make the loop1 row
  [self makeLoop1Row];
  [vbox addView: loop1Hbox enablingYResizing:NO withMinYMargin:10];
 
  [vbox addView: hbox enablingYResizing: NO];
}

- (void) startMetronome:(id)sender {
  [_metro start];
}
  
- (void) stopMetronome:(id)sender {
  [_metro stop];
}
  
- (void) continueMetronome:(id)sender {
  [_metro kontinue];
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

  [self.win setTitle: @"Liveloop Toy"];
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

- (void) tempoChanged:(id)sender {
  [self appendLog:[NSString stringWithFormat:@"tempoChanged:%d", _tempo]];
  NSError *err;
  [_metro setTempo:_tempo error:&err];
}

- (void) makeSeq {

  ASKSeqOptions *options = [[ASKSeqOptions alloc] init];
  options->_sequencer_name = "metronome";

  NSError *error;
  _seq = [[ASKSeq alloc] initWithOptions:options error:&error];
  if (error != nil) {
    NSLog(@"Could not create sequencer.  Error:%@", error);
    exit(1);
  }
}

- (void) makeMetronome {

  NSError *error;
  _metro = [[MSKMetronome alloc] initWithSeq:_seq error:&error];

  // synchronize metro tempo with control
  NSError *err;
  self.tempo = 120;
  [_seq setTempo:120 error:&err];

  if (error != nil) {
    NSLog(@"Could not create metronome. Error:%@", error);
    exit(1);
  }
}

- (void) makeScheduler {

  _sched = [[PrettyScheduler alloc] init];
  [_sched registerMetronome:_metro];

  _sched.textView = self.textview;

}



- (void) makeContext {
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;

#define HIGHRESOLUTION 1

#if HIGHRESOLUTION
  request.persize = 128;
  request.periods = 4;
#else
  request.persize = 1024;
  request.periods = 2;
#endif

  NSString *devName = @"default";
  // NSString *devName = @"hw:MGXU";

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

  self.filtModel = [[MSKFilterModel alloc] init];
  self.filtModel.filtertype = MSK_FILTER_MOOG;
  self.filtModel.fc = 2000;
  self.filtModel.q = 2.0;

  MSKGeneralFilter *filt = [[MSKGeneralFilter alloc] initWithCtx:_ctx];
  filt.sInput = _ctx.pbuf;
  filt.model = self.filtModel;
  [filt compile];

  [_ctx addFx:filt];
}

- (void) makeModels {

  self.oscModel = [[MSKOscillatorModel alloc] init];
  self.oscModel.osctype = MSK_OSCILLATOR_TYPE_SQUARE;
  self.oscModel.octave = -1;

  self.envModel = [[MSKEnvelopeModel alloc] init];
  self.envModel.attack = 0.02;
  self.envModel.decay = 0.1;
  self.envModel.sustain = 0.9;
  self.envModel.rel = 0.1;

}

- (void) makeNote:(int)note vel:(double)vel {

  MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:_ctx];
  env.iGain = vel;
  env.oneshot = YES;
  env.shottime = 0.1;
  env.model = _envModel;
  [env compile];

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

/*
 * Use the pattern manager to load the samples and patterns
 */
- (void) makePatterns {

  _mgr = [[PatternManager alloc] initWithCtx:_ctx andSched:_sched];
  [_mgr initialize];

  [_sched setLiveloop:@"loop1" pat:_mgr.pat1];

}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
  ASKError_linker_function(); // cause NSError category to be linked
  MSKError_linker_function();

  [self appendLog:@"Welcome to MSK PATTERN Demo"];
  
  [self makeWidgets];
  [vbox sizeToFit];
  [self.win setMinSize: [NSWindow frameRectForContentRect: vbox.frame
						styleMask: [self.win styleMask]].size];
  [self.win setContentView: vbox];

  // [self makeWindow];
  // [self makeMenu];

  [self.win makeKeyAndOrderFront:self];
  [self.win orderFrontRegardless];

  [self makeSeq];
  [self makeMetronome];
  [self makeScheduler];
  [self makeContext];
  [self makeModels];
  [self makeFxPath];

  // load the samples and patterns
  [self makePatterns];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

}

@end