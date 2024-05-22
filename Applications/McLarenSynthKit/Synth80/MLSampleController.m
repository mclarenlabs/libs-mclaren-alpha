/** *-* mode; objc *-*
 *
 * Controller to hold MLSampleView and Capture Button
 *
 * McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MLSampleController.h"
#import "NSColor+ColorExtensions.h"
#import "NSObject+MLBlocks.h"
#import "GSTable-MLdecls.h"

@interface MLSampleController()
// private properties

@property MSKSampleModel *sampleModel;
@end

@implementation MLSampleController

- (id) init {
  if (self = [super initWithFrame: NSMakeRect(0, 0, 300, 100)]) {
    [self setTitle:@"Sample"];

    // Make the recording machinery
    [self makeRec];		// sound input context
    [self makeRecorder];	// create a recorder and empty sample
    
    // Make the context menu for this view
    [self makeContextMenu];

    [self setAutoresizingMask: NSViewWidthSizable];
    GSHbox *hbox = [[GSHbox alloc] init];
    [hbox setAutoresizingMask: NSViewWidthSizable];

    NSRect rect1 = NSMakeRect(0, 0, 100, 80);
    NSFont *font = [NSFont userFixedPitchFontOfSize:18.0];

    self.captureButton = [[MLExpressiveButton alloc] initWithFrame:rect1];
    [[self.captureButton cell] setColor:[NSColor mcBlueColor]];
    self.captureButton.font = font;
    self.captureButton.title = @"Capture!";
    // [self.captureButton setAutoresizingMask: NSViewWidthSizable];

    self.captureButton.target = self;	// send to this controller?

    _saveSampleButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    [_saveSampleButton setButtonType: NSSwitchButton];
    [_saveSampleButton setAutoresizingMask: NSViewWidthSizable];
    [_saveSampleButton setTitle:@"Save Sample"];
    [_saveSampleButton sizeToFit];

    GSVbox *vbox = [[GSVbox alloc] init];
    [vbox setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    [vbox addView: _saveSampleButton enablingYResizing: NO withMinYMargin: 0];
    [vbox addView: _captureButton enablingYResizing: YES withMinYMargin: 5];
    [vbox sizeToFit];


    NSRect rect = NSMakeRect(0, 0, 100, 100);
    self.sampleView = [[MLSampleView alloc] initWithFrame:rect];
    [self.sampleView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];

    // [hbox addView: _captureButton enablingXResizing: NO withMinXMargin: 0];
    [hbox addView: vbox enablingXResizing: NO withMinXMargin: 0];
    [hbox addView: _sampleView enablingXResizing: YES withMinXMargin: 10];
    [self setContentView: hbox];
    [self sizeToFit];

  }
  return self;
}

/*
 * The only recording context in this application is the sample recorder.
 * So we're going to make it local to MLSampleController.
 */

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

- (void) makeContextMenu {

  id <NSMenuItem> item;

  _contextMenu = [NSMenu new];
  _contextMenu.title = @"Sample ...";

  item = [_contextMenu addItemWithTitle:@ "Save ..."
				 action:@selector(saveSampleToFile:)
			  keyEquivalent:@""];
  item.target = self;

  item = [_contextMenu addItemWithTitle:@ "Load ..."
				 action:@selector(loadSampleFromFile:)
			  keyEquivalent:@""];
  item.target = self;

}

- (NSMenu*) menuForEvent:(NSEvent*)event {
  return _contextMenu;
}
			  
/*
 * File Save Sample and Load Sample menu items
 */

- (void) saveSampleToFile:(id)sender {

  if (self.sampleModel.sample == nil) {
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
  [self.sampleModel.sample writeToFilePath:filePath error:&err];

  // Writing the sample changes its basename.
  // Force View to redraw it because binding doesn't see the change.
  [self.sampleView setNeedsDisplay:YES];

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
    // set the loaded sample as the one to play.  cause the waveform view to update.
    self.sampleModel.sample = samp;
  }    
}

/*
 * called when Capture button is pressed
 */

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

- (void) butNoteOn:(unsigned)midiNote vel:(unsigned)vel {
  NSLog(@"Button:%u %u", midiNote, vel);
  [_recorder recOn];
}
  
- (void) butNoteOff:(unsigned)midiNote vel:(unsigned)vel {
  NSLog(@"Button:%u %u", midiNote, vel);
  [_recorder recOff];

  // hold a reference to the recording sample
  MSKSample *tempSample = _recsample;

  // wait until recorder finishes writing
  [self afterDelay:0.1 performBlockOnMainThread:^{
      self.sampleModel.sample = tempSample;
    }];

  // this recreates _recsample
  [self makeRecorder];
}
  
- (void) bindToModel:(MSKSampleModel*)sampleModel {
  self.sampleModel = sampleModel;

  NSLog(@"SampleController: bindToModel");

  [_saveSampleButton bind: @"value"
		 toObject: sampleModel
	      withKeyPath: @"saveSample"
		  options: nil];

  [_sampleView bind: @"sample"
	   toObject: sampleModel
	withKeyPath: @"sample"
	    options: nil];
}

@end



