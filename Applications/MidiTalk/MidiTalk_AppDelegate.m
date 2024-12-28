/**
 * MidiTalk - StepTalk scriptable MIDI synth thing
 *
 */

// enable Object memory use inspection panel
#define USE_GSMEMORY_PANEL 1

#import "AlsaSoundKit/AlsaSoundKit.h"
#import "MidiTalk_ASKSeq.h"

#import "MidiTalk_AppDelegate.h"
#import "GSTable-MLdecls.h"

#import "STScriptingSupport.h"

#include "StepTalk/STEnvironment.h"

#if USE_GSMEMORY_PANEL
#import "GNUstepGUI/GSMemoryPanel.h"
#endif

@implementation AppDelegate

- (id) init {
  if (self = [super init]) {

    if ([NSApp isScriptingSupported]) {
      NSLog(@"YES Scripting is supported.  calling initializeApplicationScripting");

      // This call sets up the scripting environment by calling the category method
      // added to NSApplication in the file
      //    ./STScriptingSupport.h
      // which is provided as part of the StepTalk distribution.
      [NSApp initializeApplicationScripting];
      [self prepopulateConstants];
    }

    [self makeWindow];
    [self makeMenu];
  }
  return self;
}

/*
 * NSApplication+additions.h in StepTalk defines some methods that we
 * access dynamically.  [NSApp scriptingEnvironment] is one of them.
 */

- (void) prepopulateConstants {
  SEL sel = @selector(scriptingEnvironment);
  STEnvironment *env;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

  if ([NSApp respondsToSelector:sel]) {
    // NSLog(@"NSApp responds to selector:%d", sel);
    env = [NSApp performSelector:sel];
  }
    
#pragma clang diagnostic pop

  if (env != nil) {
    [env setObject:@(MSK_OSCILLATOR_TYPE_SIN) forName: @"MSK_OSCILLATOR_TYPE_SIN"];
    [env setObject:@(MSK_OSCILLATOR_TYPE_SAW) forName: @"MSK_OSCILLATOR_TYPE_SAW"];
    [env setObject:@(MSK_OSCILLATOR_TYPE_SQUARE) forName: @"MSK_OSCILLATOR_TYPE_SQUARE"];
    [env setObject:@(MSK_OSCILLATOR_TYPE_TRIANGLE) forName: @"MSK_OSCILLATOR_TYPE_TRIANGLE"];
    [env setObject:@(MSK_OSCILLATOR_TYPE_REVSAW) forName: @"MSK_OSCILLATOR_TYPE_REVSAW"];
  }
}

- (void) makeWindow {

  // NSRect windowRect = NSMakeRect(0, 100, 1000, 300);
  NSRect windowRect = NSMakeRect(0, 100, 100, 100);
  self.mainWindow = [[NSWindow alloc]
		      initWithContentRect:windowRect
				styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
				  backing:NSBackingStoreBuffered
				    defer:NO];
  self.mainWindow.delegate = self;

  self.mainWindow.title = @"MidiTalk";
  // self.mainWindow.backgroundColor = [NSColor whiteColor];

  // automatically save/restore window position by AppKit
  [self.mainWindow setFrameAutosaveName:@"MidiTalk"];

  [self.mainWindow makeKeyAndOrderFront:self];
  [self.mainWindow orderFrontRegardless];

}

- (GSVbox*) populateVbox0 {

  GSVbox *vbox = [GSVbox new];
  [vbox setDefaultMinYMargin: 5];
  [vbox setBorder: 5];

  [vbox addView: [self populateMiddleRow] enablingYResizing: NO];
  [vbox addView: [self populateTopRow] enablingYResizing: NO];

  [vbox sizeToFit];
  return vbox;
}

- (NSView*) populateTopRow {

  // NSFont *font = [NSFont userFixedPitchFontOfSize:12.0];

  GSHbox *hbox = [GSHbox new];
  [hbox setDefaultMinXMargin: 5];
  [hbox setBorder: 5];
  [hbox setAutoresizingMask: NSViewWidthSizable];

  /* Metronome Activity */
  _activity0 = [[MLActivity alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)];
  [hbox addView: _activity0 enablingXResizing: NO withMinXMargin: 5.0];

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

  [hbox addView: _startButton enablingXResizing: NO withMinXMargin:5.0];

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

  [hbox addView: _stopButton enablingXResizing: NO withMinXMargin:5.0];


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

  [hbox addView: _continueButton enablingXResizing: NO withMinXMargin:5.0];

  /* Tempo Slider */
  _tempoSlider = [[NSScrollSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [_tempoSlider setTitle:@"tempo"];
  [_tempoSlider setAction:@selector(tempoChanged:)];
  
  // use bindings
  [_tempoSlider bind:@"value"
		toObject:self
	     withKeyPath:@"tempo"
		 options:nil];

  [_tempoSlider setMinValue:30];
  [_tempoSlider setMaxValue:150];
  [_tempoSlider setContinuous:YES];
  [_tempoSlider setAutoresizingMask: NSViewWidthSizable];

  [hbox addView: _tempoSlider withMinXMargin:5.0];

  // make text
  _tempoText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 50, 25)];

  [_tempoText bind:@"value"
	 toObject:self
      withKeyPath:@"tempo"
	  options:nil];

  // set initial value
  self.tempo = 120;

  // number formatter
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  NSMutableDictionary *attr = [NSMutableDictionary dictionary];

  [numberFormatter setFormat:@"###.0"];
  [numberFormatter setMinimumFractionDigits:1];
  [numberFormatter setMaximumFractionDigits:1];
  [attr setObject:[NSColor redColor] forKey:@"NSColor"];
  [numberFormatter setTextAttributesForNegativeValues:attr];
  [_tempoText setFormatter:numberFormatter];

  [hbox addView: _tempoText withMinXMargin: 5.0];

  // Activity indicators
  GSHbox *span = [GSHbox new];
  [span setAutoresizingMask: NSViewWidthSizable];
  _lamp1 = [[MLLamp alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)];
  _lamp2 = [[MLLamp alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)];
  _lamp3 = [[MLLamp alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)];
  _lamp4 = [[MLLamp alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)];
  _activity1 = [[MLActivity alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)];
  _activity2 = [[MLActivity alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)];

  [hbox addView: span enablingXResizing: YES];
  [hbox addView: _lamp1 enablingXResizing: NO withMinXMargin: 5.0];
  [hbox addView: _lamp2 enablingXResizing: NO withMinXMargin: 5.0];
  [hbox addView: _lamp3 enablingXResizing: NO withMinXMargin: 5.0];
  [hbox addView: _lamp4 enablingXResizing: NO withMinXMargin: 5.0];
  [hbox addSeparator];
  [hbox addView: _activity1 enablingXResizing: NO withMinXMargin: 5.0];
  [hbox addView: _activity2 enablingXResizing: NO withMinXMargin: 5.0];

  return hbox;
}

- (void) makeMenu {

  // The main menu - must create before [NSApp run] to get some default behavior
  self.mainMenu = [NSMenu new];

  // the [Info] item
  id<NSMenuItem> infoItem =
    [self.mainMenu addItemWithTitle: @"Info"
			    action: NULL
		     keyEquivalent: @""];

  NSMenu *infoMenu = [NSMenu new];
  [infoItem setSubmenu:infoMenu];
  infoItem.title = @"Info";

  [infoMenu addItemWithTitle:@ "About"
		      action:@selector(orderFrontStandardAboutPanel:)
	       keyEquivalent:@""];
#if 0
  // Use StepTalk/ApplicationScripting provided menu
  if([NSApp isScriptingSupported])
    {
      id<NSMenuItem> scriptingItem =
	[self.mainMenu addItemWithTitle: @"Scripting"
			action: NULL
		 keyEquivalent: @""];

      NSMenu *scriptingMenu = [NSApp scriptingMenu];
      [scriptingItem setSubmenu: scriptingMenu];
    }
  
#endif
#if 1
  // Note: the [NSApp scriptingMenu] installs itself as the main
  // menu and also does not work well with
  //   defaults write pad NSMenuInterfaceStyle NSWindows95InterfaceStyle
  // so we write it ourselves
  
  if([NSApp isScriptingSupported])
    {
      id<NSMenuItem> scriptingItem =
	[self.mainMenu addItemWithTitle: @"Scripting"
			action: NULL
		 keyEquivalent: @""];

      NSMenu *scriptingMenu = [NSMenu new];
      [scriptingMenu addItemWithTitle: @"Scripts panel ..."
			       action: @selector(orderFrontScriptsPanel:)
			keyEquivalent: @""];
      [scriptingMenu addItemWithTitle: @"Transcript ..."
			       action: @selector(orderFrontTranscriptWindow:)
			keyEquivalent: @""];

      [scriptingMenu addItemWithTitle: @"Do Selection"
			       action: @selector(executeSelectionScript:)
			keyEquivalent: @"e"];
      [scriptingMenu addItemWithTitle: @"Do and Show Selection"
			       action: @selector(executeAndShowSelectionScript:)
			keyEquivalent: @"d"];

      [scriptingItem setSubmenu: scriptingMenu];
    }
  
#endif

  // the [Services] item
  id<NSMenuItem> servicesItem =
    [self.mainMenu addItemWithTitle: @"Services"
			    action: NULL
		     keyEquivalent: @""];
  NSMenu *servicesMenu = [NSMenu new];
  [servicesItem setSubmenu: servicesMenu];


  // the [Windows] item
  id<NSMenuItem> windowsItem =
    [self.mainMenu addItemWithTitle: @"Windows"
			    action: NULL
		     keyEquivalent: @""];
  NSMenu *windowsMenu = [NSMenu new];

  [windowsMenu addItemWithTitle:@"Arrange in Front"
			 action:@selector(arrangeInFront:)
		  keyEquivalent:@""];

  [windowsItem setSubmenu: windowsMenu];


  // The last two on the main menu
  [self.mainMenu addItemWithTitle:@ "Hide"
			   action:@selector(hide:)
		    keyEquivalent:@"h"];

  [self.mainMenu addItemWithTitle:@ "Quit"
		      action:@selector(terminate:)
	       keyEquivalent:@"q"];



  [NSApp setServicesMenu:servicesMenu];
  [NSApp setWindowsMenu:windowsMenu];
  [NSApp setMainMenu:self.mainMenu];
}

- (NSView*) populateMiddleRow {
  GSHbox *hbox = [GSHbox new];
  [hbox setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  
  [hbox addView: [self populateWidgetsColumn] enablingXResizing: YES withMinXMargin:5];
  [hbox addView: [self populateOutputColumn] enablingXResizing: YES withMinXMargin:5];
  return hbox;
}

- (NSView*) populateWidgetsColumn {

  GSVbox *vbox = [GSVbox new];
  [vbox setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];

  _gaugesController = [[MLGaugesController alloc] init];

  _buttonsController = [[MLButtonsController alloc] init];

  NSRect pianoRect = NSMakeRect(0, 0, 700, 200);
  _pianoController = [[MLPianoController alloc] initWithFrame: pianoRect];

  [vbox addView: _pianoController enablingYResizing: NO withMinYMargin: 5];
  [vbox addView: _buttonsController enablingYResizing: YES withMinYMargin: 5];
  [vbox addView: _gaugesController enablingYResizing: YES withMinYMargin: 5];

  return vbox;
}

- (NSView*) populateOutputColumn {

  GSVbox *vbox = [GSVbox new];
  [vbox setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];

  _outputContextController = [[MLContextController alloc] initWithTitle:@"Output"];
  _inputContextController = [[MLContextController alloc] initWithTitle:@"Input"];

  _filterController = [MLFilterController new];
  _filterController.title = @"Filt1";

  _reverbController = [MLReverbController new];
  _reverbController.title = @"Reverb1";

  [vbox addView: _reverbController enablingYResizing: NO withMinYMargin: 5];
  [vbox addView: _filterController enablingYResizing: NO withMinYMargin: 5];
  [vbox addView: _inputContextController enablingYResizing: YES withMinYMargin: 5];
  [vbox addView: _outputContextController enablingYResizing: YES withMinYMargin: 5];

  [vbox sizeToFit];
  return vbox;
}

/*
 * Metronome control section
 */

- (void) startMetronome:(id)sender {
  NSLog(@"metro start");
  [_metro start];
}
  
- (void) stopMetronome:(id)sender {
  NSLog(@"metro stop");
  [_metro stop];
}
  
- (void) continueMetronome:(id)sender {
  NSLog(@"metro continue");
  [_metro kontinue];
}

- (void) tempoChanged:(id)sender {
  NSLog(@"tempoChanged:%d", _tempo);
  NSError *err;
  [_metro setTempo:_tempo error:&err];
}

- (void) makeMetronome {

  NSError *error;
  _metro = [[MSKMetronome alloc] initWithSeq:_seq error:&error];

  if (error != nil) {
    NSLog(@"Could not create metronome. Error:%@", error);
    exit(1);
  }

  // synchronize metro tempo with control
  NSError *err;
  [_seq setTempo:120 error:&err];

  if (error != nil) {
    NSLog(@"Could not set metronome tempo. Error:%@", err);
    exit(1);
  }

}

- (void) makeSeq {

  ASKSeqOptions *options = [[ASKSeqOptions alloc] init];
  options->_sequencer_name = "miditalk";

  NSError *error;
  // _seq = [[ASKSeq alloc] initWithOptions:options error:&error];
  MidiTalk_ASKSeq *mtseq = [[MidiTalk_ASKSeq alloc] initWithOptions:options error:&error];
  mtseq.metronomeBeatActivity = _activity0;
  mtseq.midiInActivity = _activity1;
  mtseq.midiOutActivity = _activity2;

  _seq = mtseq;

  if (error != nil) {
    NSLog(@"Could not create sequencer.  Error:%@", error);
    exit(1);
  }

  // create a default dispatcher
  _disp = [[ASKSeqDispatcher alloc] initWithSeq:_seq];

}

#if 0
// TOM: dead code I think
- (void) midiInTickler {
  [_activity1 tickle];
}
#endif

- (void) makeScheduler {

  _sched = [[MSKScheduler alloc] init];
  [_sched registerMetronome:_metro];

}



- (void) makeContext {
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;

#define HIGHRESOLUTION 0

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

- (void) makeRec {
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;
  request.persize = 1024;
  request.periods = 2;

  NSString *devName = @"default";

  NSError *error;
  BOOL ok;

  _rec = [[MSKContext alloc] initWithName:devName
				andStream:SND_PCM_STREAM_CAPTURE
				    error:&error];

  if (error != nil) {
    NSLog(@"MSKContext init error:%@", error);
    exit(1);
  }

  ok = [_rec configureForRequest:request error:&error];
  if (ok == NO) {
    NSLog(@"MSKContext configure error:%@", error);
    exit(1);
  }

  ok = [_rec startWithError:&error];
  if (ok == NO) {
    NSLog(@"MSKContext starting error:%@", error);
    exit(1);
  }
}

- (void) makeModels {

  _filterModel = [[MSKFilterModel alloc] init];
  _reverbModel = [[MSKReverbModel alloc] init];
  _reverbModel.on = YES; // is always on

}

- (void) makeFxPath {

  // CTX.PBUF -> FILT -> REVERB
  MSKGeneralFilter *filt = [[MSKGeneralFilter alloc] initWithCtx:_ctx];
  filt.sInput = _ctx.pbuf;
  filt.model = self.filterModel;
  [filt compile];

  MSKFreeverbReverb *rb = [[MSKFreeverbReverb alloc] initWithCtx:_ctx];
  rb.sInput = filt;
  rb.model = self.reverbModel;
  [rb compile];

  [_ctx addFx:rb];
}

/*
 * Make the bindings
 */

- (void) makeBindings {

  [_filterController bindToModel: _filterModel];
  [_reverbController bindToModel: _reverbModel];
}
  

/*
 * Application Delegate Callbacks
 */

- (void) applicationWillFinishLaunching: (NSNotification *) aNotification
{
}
  

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
  ASKError_linker_function(); // cause NSError category to be linked
  MSKError_linker_function();

  NSLog(@"Welcome to MidiTalk");

  GSVbox *vbox0 = [self populateVbox0];
  [vbox0 sizeToFit];
  [_mainWindow setMinSize: [NSWindow frameRectForContentRect: vbox0.frame
						    styleMask: [_mainWindow styleMask]].size];
  [_mainWindow setContentView: vbox0];

  [self makeSeq];
  [self makeMetronome];
  [self makeScheduler];

  [self makeContext];
  [self makeRec];
  [self makeModels];
  [self makeFxPath];

  [self makeBindings];

  [_outputContextController bindToContext: _ctx];

#if 0
  [_outputContextController.vuMeterView rmsL:0.5 rmsR:0.25 peakL:0.7 peakR:0.60];
#endif

  [_ctx onRms:^(unsigned idx, double rmsl, double rmsr, double absl, double absr) {
      [_outputContextController.vuMeterView rmsL:rmsl rmsR:rmsr peakL:absl peakR:absr];
    }];
  
  [_inputContextController bindToContext: _rec];

  [_rec onRms:^(unsigned idx, double rmsl, double rmsr, double absl, double absr) {
      [_inputContextController.vuMeterView rmsL:rmsl rmsR:rmsr peakL:absl peakR:absr];
    }];
  
#if 0
  self.but1.nextKeyView = self.but2;
  self.but2.nextKeyView = self.but3;
  self.but3.nextKeyView = self.but4;
  self.but4.nextKeyView = self.gauge1;

  self.gauge1.nextKeyView = self.gauge2;
  self.gauge2.nextKeyView = self.gauge3;
  self.gauge3.nextKeyView = self.gauge4;
  self.gauge4.nextKeyView = self.pad;

  self.pad.nextKeyView = self.piano;

  self.piano.nextKeyView = self.octaveDown;
  self.octaveDown.nextKeyView = self.octaveUp;
  self.octaveUp.nextKeyView = self.but1;
#endif

#if 0
  [self.mainWindow makeFirstResponder:self.but1];
#endif

#if 1
  // convenient when developing to have these always open
  [NSApp orderFrontScriptsPanel:self];
  [NSApp orderFrontTranscriptWindow:self];
#endif

#if USE_GSMEMORY_PANEL
  [NSApp orderFrontSharedMemoryPanel:self];  // show memory stats
#endif

}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSNotification*)aNotification
{
  // NSLog(@"applicationShouldTerminate");
  return NSTerminateNow;
}

- (void) applicationWillTerminate:(NSNotification*)aNotification
{
  // NSLog(@"applicationWillTerminate");
}


@end
