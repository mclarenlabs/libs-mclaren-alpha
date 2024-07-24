# import "Synth80AppDelegate.h"
# import "Synth80WindowController.h"

#import <AlsaSoundKit/AlsaSoundKit.h>
#import "NSObject+MLBlocks.h"
#import "GSTable-MLdecls.h"
#import "MLCircularSliderWithValue.h"
#import "MLStepperWithValue.h"

@implementation AppDelegate {
  int numLines;
  NSFont *font;
}

- (id) init {
  if (self = [super init]) {

    srandom(time(NULL)); // seed pseudo-random number generator
    numLines = 0;

    // the MODEL for the synthesizer
    self.model = [[Synth80Model alloc] init];

    // before textview is populated
    // font = [NSFont userFixedPitchFontOfSize:12.0];
    font = [NSFont userFontOfSize:12.0];
    // font = [NSFont fontWithName:@"Helvetica" size:14];

    // [self makeWindow];
    [self makeMenu];
    _algorithmEngine = [[Synth80AlgorithmEngine alloc] init];
  }
  return self;
}



- (void) makeSeq {

  ASKSeqOptions *options = [[ASKSeqOptions alloc] init];
  options->_sequencer_name = "midimon";

  NSError *error;
  _seq = [[ASKSeq alloc] initWithOptions:options error:&error];
  if (error != nil) {
    NSLog(@"Could not create sequencer.  Error:%@", error);
    exit(1);
  }

  AppDelegate __weak *wself = self;
  [_seq addListener:^(NSArray<ASKSeqEvent*> *events) {
      for (ASKSeqEvent* e in events) {

	if (e->_ev.type != SND_SEQ_EVENT_PITCHBEND) {
	  [wself appendLog:[NSString stringWithFormat:@"%@", e]];
	}

        if (e->_ev.type == SND_SEQ_EVENT_NOTEON) {
          // uint8_t chan = e->_ev.data.note.channel;
          uint8_t note = e->_ev.data.note.note;
          uint8_t vel = e->_ev.data.note.velocity;

	  [wself noteOn:note vel:vel];
        }

        if (e->_ev.type == SND_SEQ_EVENT_NOTEOFF) {
          // uint8_t chan = e->_ev.data.note.channel;
          uint8_t note = e->_ev.data.note.note;
          uint8_t vel = e->_ev.data.note.velocity;

	  [wself noteOff:note vel:vel];
        }

	if (e->_ev.type == SND_SEQ_EVENT_CONTROLLER) {
          // uint8_t chan = e->_ev.data.note.channel;
          uint8_t param = e->_ev.data.control.param;
          uint8_t value = e->_ev.data.control.value;

	  if (param == 1) {
	    [wself.model.modulationModel setModulationRealtime: value / 128.0];
	  }
	}

	// Pitchbend events can overwhelm the main queue where the value must be updated :-(
	// We throttle the  number of outstanding events.
        if (e->_ev.type == SND_SEQ_EVENT_PITCHBEND) {
	  double p = (double)e->_ev.data.control.value / 8192.0;
	  [wself.model.modulationModel setPitchbendRealtime: p];
	}
	
      }
    }];
}


- (void) makeGreedyListener {
  // Attempt to play notes from every SEQ in the system

  ASKSeqList *list;
  list = [[ASKSeqList alloc] initWithSeq:_seq];
  
  for (ASKSeqClientInfo *c in list.clientinfos) {
    [self appendLog:[NSString stringWithFormat:@"Client:%@", c]];
  }

  for (ASKSeqPortInfo *p in list.portinfos) {
    [self appendLog:[NSString stringWithFormat:@"Port:%@", p]];

    NSError *error;
    // listen to new port
    [_seq connectFrom:p.client port:p.port error:&error];

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
      [_seq connectFrom:p.client port:p.port error:&error];

      if (error != nil) {
	[self appendLog:[NSString stringWithFormat:@"connectFrom error:%@", error]];
      }
    }];

  [list onPortDeleted:^(ASKSeqPortInfo* p) {
      [self appendLog:[NSString stringWithFormat:@"Port Deleted:%@", p]];
    }];

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

  [fileMenu addItemWithTitle:@ "OpenDocument ..."
		      action:@selector(openDocument:)
	       keyEquivalent:@""];

  [fileMenu addItemWithTitle:@ "NewDocument ..."
		      action:@selector(newDocument:)
	       keyEquivalent:@""];

  [fileMenu addItemWithTitle:@ "RevertDocumentToSaved ..."
		      action:@selector(revertDocumentToSaved:)
	       keyEquivalent:@""];

  [fileMenu addItemWithTitle:@ "SaveAllDocuments ..."
		      action:@selector(saveAllDocuments:)
	       keyEquivalent:@""];

  [fileMenu addItemWithTitle:@ "Save ..."
		      action:@selector(saveDocument:) // NSDocument
	       keyEquivalent:@""];

  [fileMenu addItemWithTitle:@ "SaveAs ..."
		      action:@selector(saveDocumentAs:) // NSDocument
	       keyEquivalent:@""];

  // the [Edit] item
  id<NSMenuItem> editItem =
    [self.mainMenu addItemWithTitle: @"Edit"
			    action: NULL
		     keyEquivalent: @""];

  NSMenu *editMenu = [NSMenu new];
  [editItem setSubmenu:editMenu];
  editItem.title = @"Edit";

  [editMenu addItemWithTitle:@ "Undo"
		      action:@selector(undo:)
	       keyEquivalent:@"z"];

  [editMenu addItemWithTitle:@ "Redo"
		      action:@selector(redo:)
	       keyEquivalent:@"Z"];

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

- (void) clearLog:(NSControl*)sender {
  NSString *news = @"";
  NSString *olds = self.textview.textStorage.string;
  NSRange allChars = NSMakeRange(0, [olds length]);

  numLines = 0;

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
      // NSRange allChars = NSMakeRange(0, [as length]);
      // [as addAttribute:NSFontAttributeName value:font range:allChars];
    
      [self.textview.textStorage appendAttributedString:as];
      numLines++;

      // 2024-05-01
      if (numLines > 100) { // remove one
	NSCharacterSet *newlineSet = [NSCharacterSet newlineCharacterSet];
	NSRange found = [self.textview.textStorage.string rangeOfCharacterFromSet: newlineSet];
	// NSLog(@"range:%@", NSStringFromRange(found));
	// NSLog(@"%@", self.textview.textStorage.string);
	if (found.location != NSNotFound) {
	  NSRange range = NSMakeRange(0, found.location+1);
	  [self.textview.textStorage deleteCharactersInRange: range];
	}
      }

      NSRange allChars = NSMakeRange(0, [self.textview.textStorage.string length]);
      [self.textview.textStorage addAttribute:NSFontAttributeName value:font range:allChars];

      // make visible the very end
      if (scroll)
	[self.textview scrollRangeToVisible: NSMakeRange(self.textview.string.length, 0)];
    }];
}

static int evenodd = 0;

- (void) makeContext {
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;
  request.persize = 1024;
  request.periods = 2;

  NSString *devName = @"default";

  NSError *error;
  BOOL ok;

  [MSKContext setPlaysChime:YES]; // play sound when context starts
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

  [_ctx onWave:^(unsigned idx, MSKContextBuffer *buf) {
      if (((++evenodd) % 5) != 1) // Temporary Workaround
	return;
      [self performBlockOnMainThread:^{
	  _contextBufferView.sample = buf;
	  [_contextBufferView setNeedsDisplay:YES];
	}];
    }];

}

- (void) makeFxPath {
  // CTX.PBUX -> FILT -> REVERB
  MSKGeneralFilter *filt = [[MSKGeneralFilter alloc] initWithCtx:_ctx];
  filt.sInput = _ctx.pbuf;
  filt.model = self.model.filtModel;
  [filt compile];

  MSKFreeverbReverb *rb = [[MSKFreeverbReverb alloc] initWithCtx:_ctx];
  rb.sInput = filt;
  rb.model = self.model.reverbModel;
  [rb compile];

  [_ctx addFx:rb];
}

- (void) makeNote {

  // perform on SEQ queue same as pianoNoteOn to avoid race conditions
  [_seq dispatchAsync:^ {
      MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:_ctx];
      env.oneshot = YES;
      env.shottime = 1.0;		// 1.0 seconds
      env.model = _model.env1Model;
      [env compile];

      int note = (random() % 12) + 64;

      MSKDrawbarOscillator *osc = [[MSKDrawbarOscillator alloc] initWithCtx:_ctx];
      osc.iNote = note;
      osc.sEnvelope = env;
      osc.model = _model.osc1Model;
      osc.drawbarModel = _model.drawbar1Model;
      osc.modulationModel = _model.modulationModel;
      [osc compile];

      [_ctx addVoice:osc];
    }];

}

- (void) noteOn:(NSUInteger)note vel:(unsigned)vel {
  [_algorithmEngine noteOn: note
		       vel: 127
		       ctx: _ctx
		     model: _model];
  [self performBlockOnMainThread:^{
      Synth80WindowController *wc = [Synth80WindowController sharedWindowController];
      [wc.pianoController.piano pianoNoteOn: note vel:vel];
    }];
}
		    
- (void) noteOff:(NSUInteger)note vel:(unsigned)vel{
  [_algorithmEngine noteOff: note
			vel: 0
			ctx: _ctx
		      model: _model];
  [self performBlockOnMainThread:^{
      Synth80WindowController *wc = [Synth80WindowController sharedWindowController];
      [wc.pianoController.piano pianoNoteOff: note vel:vel];
    }];
}

// Actions from the Piano are received on the Main Thread, should play on MIDI Queue
- (void) pianoNoteOn:(unsigned)note vel:(unsigned)vel {
   [_seq dispatchAsync:^ {
       [self noteOn:note vel:vel];
    }];
   [self appendLog:[NSString stringWithFormat:@"pianoNoteOn:%u vel:%u", note, vel]];
}
- (void) pianoNoteOff:(unsigned)note vel:(unsigned)vel {
  [_seq dispatchAsync:^ {
      [self noteOff:note vel:vel];
    }];
   [self appendLog:[NSString stringWithFormat:@"pianoNoteOff:%u vel:%u", note, vel]];
}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
  ASKError_linker_function(); // cause NSError category to be linked
  MSKError_linker_function();

  [self appendLog:@"Welcome to Synth80"];
  
  [self makeSeq];
  [self makeGreedyListener];

  [self makeContext];
  [self makeFxPath];
  [self makeNote];

  // NOTE: the default document with WindowController is created before this
  // method is called so we can attach the volume slider here.
  Synth80WindowController *wc = [Synth80WindowController sharedWindowController];
  [_outputVolumeSlider bind:@"value"
		     toObject: _ctx
		  withKeyPath: @"volume"
		      options: nil];

  // Set the piano to play
  [wc.pianoController.piano setTarget: self];
  [wc.pianoController.piano setTarget: self];
  

  [NSDocumentController sharedDocumentController];

}

@end
