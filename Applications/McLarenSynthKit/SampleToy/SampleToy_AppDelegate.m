#import "SampleToy_AppDelegate.h"
#import "MLExpressiveButton.h"
#import "NSColor+ColorExtensions.h"
#import "LabelWithValue.h"
#import "NSObject+MLBlocks.h"

#import "StepTalk/StepTalk.h"

@implementation AppDelegate

- (id) init {
  if (self = [super init]) {

  [self makeWindow]; // order matters to get NSWindows95InterfaceStyle menus
  [self makeMenu];
  }
  return self;
}


- (void) makeMenu {

  // The main menu - must create before [NSApp run] to get some default behavior
  self.mainMenu = [NSMenu new];

  // the [File] item
  id<NSMenuItem> fileItem =
    [self.mainMenu addItemWithTitle: @"File"
			    action: NULL
		     keyEquivalent: @""];

  NSMenu *fileMenu = [NSMenu new];
  [fileItem setSubmenu:fileMenu];
  fileItem.title = @"File";

  [fileMenu addItemWithTitle:@ "Save ..."
		      action:@selector(saveSampleToFile:)
	       keyEquivalent:@""];

  [fileMenu addItemWithTitle:@ "Load ..."
		      action:@selector(loadSampleFromFile:)
	       keyEquivalent:@""];

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

- (void) makeWindow {

  NSRect windowRect = NSMakeRect(0, 100, 1100, 200);
  self.mainWindow = [[NSWindow alloc]
		      initWithContentRect:windowRect
				styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
				  backing:NSBackingStoreBuffered
				    defer:NO];
  self.mainWindow.delegate = self;

  self.mainWindow.title = @"SampleToy";
  // self.mainWindow.backgroundColor = [NSColor whiteColor];

  // automatically save/restore window position by AppKit
  [self.mainWindow setFrameAutosaveName:@"SampleToy"];

  [self.mainWindow makeKeyAndOrderFront:self];
  [self.mainWindow orderFrontRegardless];

}

- (void) makeButtons {

  NSFont *font = [NSFont userFixedPitchFontOfSize:24.0];

  NSRect rect1 = NSMakeRect(50, 50, 145, 100);
  self.but1 = [[MLExpressiveButton alloc] initWithFrame:rect1];
  [[self.but1 cell] setColor:[NSColor mcBlueColor]];
  self.but1.font = font;
  self.but1.title = @"Capture!";

  self.but1.target = self;	// send to NSApp

  // TOM: 2023-05-09 - implement the focus ring TAB
  [self.mainWindow.contentView addSubview:self.but1];
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

- (void) makeRecorder {

  _recsample = [[MSKSample alloc] initWithFrames:(44100*4) channels:2];
  _recorder = [[MSKSampleRecorder alloc] initWithCtx:_rec];

  _recorder.sample = _recsample;
  _recorder.sInput = _rec.rbuf;
  [_recorder compile];

  // Ask the context to record into it
  [_rec setGain:1.0];
  [_rec addVoice:_recorder];
}  

  
- (void) playSample:(double)factor {

  MSKSample *samp = [_playsample resampleBy:factor];
  MSKSamplePlayer *player = [[MSKSamplePlayer alloc] initWithCtx:_ctx];

  [player setSample:samp];
  [player compile];

  // Ask the context to play it
  [_ctx setGain:1.0];
  [_ctx addVoice:player];
}  
  
  

- (void) makePiano 
{
  NSRect rect = NSMakeRect(200, 50, 15*40, 100);

  self.piano = [[MLPiano alloc] initWithFrame:rect];
  self.piano.totalWholeNotes = 15;

  self.piano.target = self; // send events to NSApp
  
  [self.mainWindow.contentView addSubview:self.piano];

  // octave up/down and display
  NSButton *down = [NSButton new];
  [down setTitle:@"▼"];
  [down setFont:[NSFont userFontOfSize:20.0]];
  [down setFrame:NSMakeRect(200, 10, 25, 25)];
  [down setAction: @selector(octaveDownPressed:)];
  self.octaveDown = down;
  
  NSButton *up = [NSButton new];
  [up setTitle:@"▲"];
  [up setFont:[NSFont userFontOfSize:20.0]];
  [up setFrame:NSMakeRect(230, 10, 25, 25)];
  [up setAction: @selector(octaveUpPressed:)];
  self.octaveUp = up;
  
  LabelWithValue *lv = [LabelWithValue new];
  [lv setLabel:@"octave:"];
  [lv setValue:@"c4"];
  [lv setFrame:NSMakeRect(260, 10, 125, 25)];
  self.octaveLabel = lv;
  
  [self.mainWindow.contentView addSubview:up];
  [self.mainWindow.contentView addSubview:down];
  [self.mainWindow.contentView addSubview:lv];
}

- (void) makeSampleView
{
  NSRect rect = NSMakeRect(800, 50, 200, 100);

  self.sampleView = [[MLSampleView alloc] initWithFrame:rect];

  [self.mainWindow.contentView addSubview:self.sampleView];

}

/*
 * called when Capture button is pressed
 */

- (void) butNoteOn:(unsigned)midiNote vel:(unsigned)vel {
  NSLog(@"Button:%u %u", midiNote, vel);
  [_recorder recOn];
}
  
- (void) butNoteOff:(unsigned)midiNote vel:(unsigned)vel {
  NSLog(@"Button:%u %u", midiNote, vel);
  [_recorder recOff];
  _playsample = _recsample;
  [self makeRecorder];

  [self afterDelay:0.1 performBlockOnMainThread:^{
      // display it
      self.sampleView.sample = _playsample;
      [self.sampleView setNeedsDisplay:YES];
    }];
}
  

/*
 * Called when piano key is pressed
 */

- (void) pianoNoteOn:(unsigned)midiNote vel:(unsigned)vel {
  // NSLog(@"Piano:%u %u", midiNote, vel);
  double ratio = 1.0;
  if (midiNote >= 72) {
    ratio = exp2((midiNote-72) / 12.0);
    ratio = 1.0 / ratio;
  }
  else {
    ratio = exp((72-midiNote) / 12.0);
  }
  NSLog(@"ratio: %g", ratio);
  [self playSample:ratio];
}
  
- (void) pianoNoteOff:(unsigned)midiNote vel:(unsigned)vel {
  NSLog(@"Piano:%u %u", midiNote, vel);
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

/*
 * File Save Sample and Load Sample menu items
 */

- (void) saveSampleToFile:(id)sender {

  if (self.playsample == nil) {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"No sample to save";
    [alert runModal];
    return;
  }
    
  NSSavePanel *panel = [[NSSavePanel alloc] init];
  panel.allowedFileTypes = [MSKSampleManager knownFileTypes];
  panel.canCreateDirectories = YES;
  int res = [panel runModal];

  if (res != 1) {
    return; // save panel was cancelled
  }

  NSString *filePath = panel.filename;

  // Use MSKSample save write method
  NSError *err = nil;
  [self.playsample writeToFilePath:filePath error:&err];

  if (err != nil) {
    NSAlert *erralert = [NSAlert alertWithError:err];
    [erralert runModal];
  }
}


- (void) loadSampleFromFile:(id)sender {

  // Use an OpenPanel with Sample known file types
  NSOpenPanel *panel = [[NSOpenPanel alloc] init];
  panel.canChooseDirectories = NO;
  panel.allowsMultipleSelection = NO;
  int res = [panel runModalForTypes:[MSKSampleManager knownFileTypes]];

  if (res != 1) {
    return;			// load was cancelled
  }
  
  NSString *filePath = panel.filenames[0];
  NSLog(@"Loading sample file:%@", filePath);

  // Use MSKSample read sndfile init method
  NSError *err;
  MSKSample *samp = [[MSKSample alloc] initWithFilePath:filePath error:&err];
  if (err != nil) {
    NSAlert *erralert = [NSAlert alertWithError:err];
    [erralert runModal];
  }
  else {
    // set the loaded sample as the one to play.  update the waveform
    self.playsample = samp;
    self.sampleView.sample = samp;
    [self.sampleView setNeedsDisplay:YES];
  }    
}


	  
/*
 * Application Delegate Callbacks
 */

- (void) applicationWillFinishLaunching: (NSNotification *) aNotification
{
}
  

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{

  [self makeContext];		// playback context
  [self makeRec];		// recording context
  [self makeRecorder];		// create a recorder and an empty sample

  [self makeButtons];
  [self makePiano];
  [self makeSampleView];

  self.but1.nextKeyView = self.piano;

  self.piano.nextKeyView = self.octaveDown;
  self.octaveDown.nextKeyView = self.octaveUp;
  self.octaveUp.nextKeyView = self.but1;

  [self.mainWindow makeFirstResponder:self.but1];

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
