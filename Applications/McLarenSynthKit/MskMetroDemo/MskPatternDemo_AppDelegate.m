# import "MskPatternDemo_AppDelegate.h"

#import <AlsaSoundKit/AlsaSoundKit.h>
#import "NSObject+MLBlocks.h"
#import "GSTable-MLdecls.h"

@implementation AppDelegate {
  GSHbox *tempoHbox;
  GSHbox *osctypeHbox;
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

- (void) makeOsctypeRow {
  osctypeHbox = [GSHbox new];
  [osctypeHbox setAutoresizingMask: NSViewWidthSizable];
  
  self.osctypeSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [self.osctypeSlider setTitle:@"Oscillator Type"];
  
  // use bindings
  [self.osctypeSlider bind:@"value"
		toObject:self
	     withKeyPath:@"oscModel.osctype"
		 options:nil];

  [self.osctypeSlider setMinValue:0];
  [self.osctypeSlider setMaxValue:5];
  [self.osctypeSlider setNumberOfTickMarks:6];
  [self.osctypeSlider setAllowsTickMarkValuesOnly:YES];
  [self.osctypeSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  NSTextField *osctypeText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  [osctypeText bind:@"value"
	 toObject:self
      withKeyPath:@"oscModel.osctype"
			 options: @{
    NSValueTransformerBindingOption: [MSKOscillatorTypeValueTransformer new]
	}];

  // pack into row
  [osctypeHbox addView:self.osctypeSlider enablingXResizing:YES];
  [osctypeHbox addView:osctypeText enablingXResizing:NO withMinXMargin:10.0];

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
 
  // Make the osctype slider
  [self makeOsctypeRow];
  [vbox addView: osctypeHbox enablingYResizing:NO withMinYMargin:10];
 
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

  [self.win setTitle: @"MSK Pattern Demo"];
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
  self.tempo = 60;
  [_seq setTempo:60 error:&err];

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
  env.shottime = 0.1;		// 10 seconds
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
 * This is the figure that is going to play with different root notes
 * and different repetition counts.
 */

- (MSKPattern*) makePat:(int)howManyTimes {
  int eigth = 55;		// ahead of the beat slightly
  MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat1"];
  [pat sync:@"beat"];
  
  [pat thunk:^{
      [self makeNote:_root vel:1.0];
    }];
  [pat ticks:eigth];
  [pat thunk:^{
      [self makeNote:_root vel:0.5];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      [self makeNote:_root+2 vel:1.0];
    }];
  [pat ticks:eigth];
  [pat thunk:^{
      [self makeNote:_root vel:0.5];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      [self makeNote:_root+3 vel:1.0];
    }];
  [pat ticks:eigth];
  [pat thunk:^{
      [self makeNote:_root vel:0.5];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      [self makeNote:_root+5 vel:1.0];
    }];
  [pat ticks:eigth];
  [pat thunk:^{
      [self makeNote:_root+3 vel:0.5];
    }];
  [pat repeat:howManyTimes];
  return pat;
}

- (MSKPattern*) makeSongPattern {

  MSKPattern *patOnce = [self makePat:1];
  MSKPattern *patTwice = [self makePat:2];
   
  // Now change the root note value
  MSKPattern *pat2 = [[MSKPattern alloc] initWithName:@"pat2"];
  [pat2 thunk:^{
      self.root = 64; // middle-E
    }];
  [pat2 pat:patTwice]; // play the figure twice

  [pat2 thunk:^{
      self.root = 69;
    }];
  [pat2 pat:patTwice]; // play the figure twice

  [pat2 thunk:^{
      self.root = 64;
    }];
  [pat2 pat:patTwice]; // play the figure twice

  [pat2 thunk:^{
      self.root = 71; // middle-E
    }];
  [pat2 pat:patOnce]; // play the figure once

  [pat2 thunk:^{
      self.root = 69; // middle-E
    }];
  [pat2 pat:patOnce]; // play the figure once

  [pat2 thunk:^{
      self.root = 64; // middle-E
    }];
  [pat2 pat:patTwice]; // play the figure  twice

  [pat2 repeat:2];

  return pat2;
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

  // Create the song pattern
  MSKPattern *songPat = [self makeSongPattern];

  NSLog(@"songPat:%@", songPat);

  // Add it to the scheduler
  [_sched addLaunch:songPat];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

}

@end
