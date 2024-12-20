# import "MskOrganDemo_AppDelegate.h"

#import <AlsaSoundKit/AlsaSoundKit.h>
#import "NSObject+MLBlocks.h"
#import "GSTable-MLdecls.h"
#import "MLCircularSliderWithValue.h"

@implementation AppDelegate {
  GSVbox *vbox;
  GSHbox *tophbox;
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
    _notes = [[NSMutableDictionary alloc] init];
  }
  return self;
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

        if (e->_ev.type == SND_SEQ_EVENT_NOTEON) {
          // uint8_t chan = e->_ev.data.note.channel;
          uint8_t note = e->_ev.data.note.note;
          // uint8_t vel = e->_ev.data.note.velocity;

	  [wself noteOn:note];
        }

        if (e->_ev.type == SND_SEQ_EVENT_NOTEOFF) {
          // uint8_t chan = e->_ev.data.note.channel;
          uint8_t note = e->_ev.data.note.note;
          // uint8_t vel = e->_ev.data.note.velocity;

	  [wself noteOff:note];
        }
	
      }
    }];
}


- (void) makeGreedyListener {
  // Attempt to play notes from every SEQ in the system

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

- (void)configureDrawbar:(MLVerticalSliderWithValue*)v path:(NSString*)path
{
  NSSlider *slider = v.slider;
  NSTextField *valueTextField = v.valueTextField;

  [slider setMinValue:0];
  [slider setMaxValue:8];
  [slider setNumberOfTickMarks:9];
  [slider setAllowsTickMarkValuesOnly:YES];

  [slider bind:@"value"
      toObject:self
	  withKeyPath:path
       options:nil];

  [valueTextField bind:@"value"
	      toObject:self
	   withKeyPath:path
	       options:nil];
}

- (void) makeDrawbarRow {
  GSHbox *hbox = [GSHbox new];
  _drawbarHbox = hbox;
  [hbox setAutoresizingMask: NSViewWidthSizable];

  NSSize sliderSize = NSMakeSize(25, 200);
  NSSize textSize = NSMakeSize(50, 25);
  
  _v0 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v1 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v2 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v3 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v4 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v5 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v6 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v7 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];
  _v8 =   [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
						       textSize:textSize];

  [hbox addView: _v0 enablingXResizing: YES withMinXMargin:10.0];
  [hbox addView: _v1 enablingXResizing: YES withMinXMargin:10.0];
  [hbox addView: _v2 enablingXResizing: YES withMinXMargin:10.0];
  [hbox addView: _v3 enablingXResizing: YES withMinXMargin:10.0];
  [hbox addView: _v4 enablingXResizing: YES withMinXMargin:10.0];
  [hbox addView: _v5 enablingXResizing: YES withMinXMargin:10.0];
  [hbox addView: _v6 enablingXResizing: YES withMinXMargin:10.0];
  [hbox addView: _v7 enablingXResizing: YES withMinXMargin:10.0];
  [hbox addView: _v8 enablingXResizing: YES withMinXMargin:10.0];

  [_v0.titleTextField setStringValue:@"16"];
  [_v1.titleTextField setStringValue:@"5 1/3"];
  [_v2.titleTextField setStringValue:@"8"];
  [_v3.titleTextField setStringValue:@"4"];
  [_v4.titleTextField setStringValue:@"2 2/3"];
  [_v5.titleTextField setStringValue:@"2"];
  [_v6.titleTextField setStringValue:@"1 3/5"];
  [_v7.titleTextField setStringValue:@"1 1/3"];
  [_v8.titleTextField setStringValue:@"1"];

  [self configureDrawbar:_v0 path:@"drawbarModel.amp0"];
  [self configureDrawbar:_v1 path:@"drawbarModel.amp1"];
  [self configureDrawbar:_v2 path:@"drawbarModel.amp2"];
  [self configureDrawbar:_v3 path:@"drawbarModel.amp3"];
  [self configureDrawbar:_v4 path:@"drawbarModel.amp4"];
  [self configureDrawbar:_v5 path:@"drawbarModel.amp5"];
  [self configureDrawbar:_v6 path:@"drawbarModel.amp6"];
  [self configureDrawbar:_v7 path:@"drawbarModel.amp7"];
  [self configureDrawbar:_v8 path:@"drawbarModel.amp8"];
  
}

- (void) makeOscillatorRow {
  GSHbox *hbox = [GSHbox new];
  _oscillatorHbox = hbox;
  [hbox setAutoresizingMask: NSViewWidthSizable];

  // Oscillator Type
  _oscCombo = [[MLCircularSliderWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_oscCombo.titleTextField setStringValue:@"Osc Type"];
  [_oscCombo.slider setMinValue:0];
  [_oscCombo.slider setMaxValue:6];
  [_oscCombo.slider setNumberOfTickMarks:6];
  [_oscCombo.slider setAllowsTickMarkValuesOnly:YES];
  
  // bindings
  [_oscCombo.slider bind:@"value"
		toObject:self
	     withKeyPath:@"oscModel.osctype"
		 options:nil];

  [_oscCombo.valueTextField bind:@"value"
			toObject:self
		     withKeyPath:@"oscModel.osctype"
			 options: @{
    NSValueTransformerBindingOption: [MSKOscillatorTypeValueTransformer new]
	}];

  // Envelope - Attack
  _attackCombo = [[MLCircularSliderWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_attackCombo.titleTextField setStringValue:@"Attack"];
  [_attackCombo.slider setMinValue:0];
  [_attackCombo.slider setMaxValue:0.5];
  [_attackCombo.slider setNumberOfTickMarks:50];
  [_attackCombo.slider setAllowsTickMarkValuesOnly:YES];
  
  // bindings
  [_attackCombo.slider bind:@"value"
		toObject:self
	     withKeyPath:@"envModel.attack"
		 options:nil];

  [_attackCombo.valueTextField bind:@"value"
			toObject:self
		     withKeyPath:@"envModel.attack"
			    options: nil];

  // Envelope - Decay
  _decayCombo = [[MLCircularSliderWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_decayCombo.titleTextField setStringValue:@"Decay"];
  [_decayCombo.slider setMinValue:0];
  [_decayCombo.slider setMaxValue:0.5];
  [_decayCombo.slider setNumberOfTickMarks:50];
  [_decayCombo.slider setAllowsTickMarkValuesOnly:YES];
  
  // bindings
  [_decayCombo.slider bind:@"value"
		toObject:self
	     withKeyPath:@"envModel.decay"
		 options:nil];

  [_decayCombo.valueTextField bind:@"value"
			toObject:self
		     withKeyPath:@"envModel.decay"
			    options: nil];

  // Envelope - Sustain
  _sustainCombo = [[MLCircularSliderWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_sustainCombo.titleTextField setStringValue:@"Sustain"];
  [_sustainCombo.slider setMinValue:0];
  [_sustainCombo.slider setMaxValue:1.0];
  [_sustainCombo.slider setNumberOfTickMarks:100];
  [_sustainCombo.slider setAllowsTickMarkValuesOnly:YES];
  
  // bindings
  [_sustainCombo.slider bind:@"value"
		toObject:self
	     withKeyPath:@"envModel.sustain"
		 options:nil];

  [_sustainCombo.valueTextField bind:@"value"
			toObject:self
		     withKeyPath:@"envModel.sustain"
			    options: nil];

  // Envelope - Release
  _releaseCombo = [[MLCircularSliderWithValue alloc] initWithSize:NSMakeSize(125, 50)];
  [_releaseCombo.titleTextField setStringValue:@"Release"];
  [_releaseCombo.slider setMinValue:0];
  [_releaseCombo.slider setMaxValue:2.0];
  [_releaseCombo.slider setNumberOfTickMarks:100];
  [_releaseCombo.slider setAllowsTickMarkValuesOnly:YES];
  
  // bindings
  [_releaseCombo.slider bind:@"value"
		toObject:self
	     withKeyPath:@"envModel.rel"
		 options:nil];

  [_releaseCombo.valueTextField bind:@"value"
			toObject:self
		     withKeyPath:@"envModel.rel"
			    options: nil];

  // arrange the views
  double marg = 5.0;
  [hbox addView: _oscCombo enablingXResizing: NO];
  [hbox addView: _attackCombo enablingXResizing: NO withMinXMargin:marg];
  [hbox addView: _decayCombo enablingXResizing: NO withMinXMargin:marg];
  [hbox addView: _sustainCombo enablingXResizing: NO withMinXMargin:marg];
  [hbox addView: _releaseCombo enablingXResizing: NO withMinXMargin:marg];
}

- (void) makeFilterRow {
  GSTable *tab = [[GSTable alloc] initWithNumberOfRows:3 numberOfColumns:2];
  _filterTable = tab;
  [tab setAutoresizingMask: NSViewWidthSizable];

  // make slider
  _filtertypeSlider = [[NSScrollSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [_filtertypeSlider setTitle:@"filtertype"];

  // use bindings
  [_filtertypeSlider bind:@"value"
	  toObject:self
       withKeyPath:@"filtModel.filtertype"
	   options:nil];

  [_filtertypeSlider setMinValue:0];
  [_filtertypeSlider setMaxValue:9];
  [_filtertypeSlider setNumberOfTickMarks:10];
  [_filtertypeSlider setAllowsTickMarkValuesOnly:YES];
  [_filtertypeSlider setContinuous:YES];
  [_filtertypeSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  _filtertypeText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  [_filtertypeText bind:@"value"
      toObject:self
	  withKeyPath:@"filtModel.filtertype"
	options: @{
    NSValueTransformerBindingOption: [MSKFilterTypeValueTransformer new]
	}];

  // FC
  _fcSlider = [[NSScrollSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [_fcSlider setTitle:@"fc"];

  // use bindings
  [_fcSlider bind:@"value"
	     toObject:self
	withKeyPath:@"filtModel.fc"
	      options:nil];

  [_fcSlider setMinValue:100];
  [_fcSlider setMaxValue:5000];
  [_fcSlider setContinuous:YES];
  [_fcSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  _fcText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  [_fcText bind:@"value"
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
  [_fcText setFormatter:numberFormatter];

  // FCMOD
  _fcmodSlider = [[NSScrollSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];
  [_fcmodSlider setTitle:@"fcmod"];
  
  // use bindings
  [_fcmodSlider bind:@"value"
		toObject:self
	     withKeyPath:@"filtModel.fcmod"
		 options:nil];

  [_fcmodSlider setMinValue:-12];
  [_fcmodSlider setMaxValue:12];
  [_fcmodSlider setContinuous:YES];
  [_fcmodSlider setAutoresizingMask: NSViewWidthSizable];

  // make text
  _fcmodText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 25)];

  [_fcmodText bind:@"value"
	  toObject:self
       withKeyPath:@"filtModel.fcmod"
	   options:nil];

  // number formatter
  NSNumberFormatter *numberFormatterRed = [[NSNumberFormatter alloc] init];
  NSMutableDictionary *attrRed = [NSMutableDictionary dictionary];

  [numberFormatterRed setFormat:@"###.0"];
  [numberFormatterRed setMinimumFractionDigits:1];
  [numberFormatterRed setMaximumFractionDigits:1];
  [attrRed setObject:[NSColor redColor] forKey:@"NSColor"];
  [numberFormatterRed setTextAttributesForNegativeValues:attrRed];
  [_fcmodText setFormatter:numberFormatterRed];


  // arrange in table
  [tab putView: _filtertypeSlider atRow:2 column:0];
  [tab putView: _filtertypeText atRow:2 column:1
       withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

  [tab putView: _fcSlider atRow:1 column:0];
  [tab putView: _fcText atRow:1 column:1
       withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

  [tab putView: _fcmodSlider atRow:0 column:0];
  [tab putView: _fcmodText atRow:0 column:1
       withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

  [tab setXResizingEnabled: YES forColumn: 0];
  [tab setXResizingEnabled: NO  forColumn: 1];
}

- (void) makeReverbRow {
  GSTable *tab = [[GSTable alloc] initWithNumberOfRows:4 numberOfColumns:2];
  _reverbTable = tab;
  [tab setAutoresizingMask: NSViewWidthSizable];


  NSRect textRect = NSMakeRect(0, 0, 100, 25);
  NSRect sliderRect = NSMakeRect(0, 0, 200, 25);

  // Dry
  _drySlider = [[NSScrollSlider alloc] initWithFrame:sliderRect];
  [_drySlider setAutoresizingMask: NSViewWidthSizable];
  [_drySlider setTitle:@"dry"];
  [_drySlider setMinValue: 0.0];
  [_drySlider setMaxValue: 100.0];
  [_drySlider setNumberOfTickMarks:101];
  [_drySlider setAllowsTickMarkValuesOnly:YES];
  
  _dryText = [[NSTextField alloc] initWithFrame:textRect];

  [_drySlider bind:@"value"
	  toObject:self
       withKeyPath:@"reverbModel.dry"
	   options:nil];

  [_dryText bind:@"value"
	toObject:self
     withKeyPath:@"reverbModel.dry"
	 options:nil];
  // Wet
  _wetSlider = [[NSScrollSlider alloc] initWithFrame:sliderRect];
  [_wetSlider setAutoresizingMask: NSViewWidthSizable];
  [_wetSlider setTitle:@"wet"];
  [_wetSlider setMinValue: 0.0];
  [_wetSlider setMaxValue: 100.0];
  [_wetSlider setNumberOfTickMarks:101];
  [_wetSlider setAllowsTickMarkValuesOnly:YES];
  
  _wetText = [[NSTextField alloc] initWithFrame:textRect];

  [_wetSlider bind:@"value"
	  toObject:self
       withKeyPath:@"reverbModel.wet"
	   options:nil];

  [_wetText bind:@"value"
	toObject:self
     withKeyPath:@"reverbModel.wet"
	 options:nil];

  // Roomsize
  _roomsizeSlider = [[NSScrollSlider alloc] initWithFrame:sliderRect];
  [_roomsizeSlider setAutoresizingMask: NSViewWidthSizable];
  [_roomsizeSlider setTitle:@"roomsize"];
  [_roomsizeSlider setMinValue: 0.0];
  [_roomsizeSlider setMaxValue: 100.0];
  [_roomsizeSlider setNumberOfTickMarks:101];
  [_roomsizeSlider setAllowsTickMarkValuesOnly:YES];
  
  _roomsizeText = [[NSTextField alloc] initWithFrame:textRect];

  [_roomsizeSlider bind:@"value"
	  toObject:self
       withKeyPath:@"reverbModel.roomsize"
	   options:nil];

  [_roomsizeText bind:@"value"
	toObject:self
     withKeyPath:@"reverbModel.roomsize"
	 options:nil];

  // Damp
  _dampSlider = [[NSScrollSlider alloc] initWithFrame:sliderRect];
  [_dampSlider setAutoresizingMask: NSViewWidthSizable];
  [_dampSlider setTitle:@"damp"];
  [_dampSlider setMinValue: 0.0];
  [_dampSlider setMaxValue: 100.0];
  [_dampSlider setNumberOfTickMarks:101];
  [_dampSlider setAllowsTickMarkValuesOnly:YES];
  
  _dampText = [[NSTextField alloc] initWithFrame:textRect];

  [_dampSlider bind:@"value"
	  toObject:self
       withKeyPath:@"reverbModel.damp"
	   options:nil];

  [_dampText bind:@"value"
	toObject:self
     withKeyPath:@"reverbModel.damp"
	 options:nil];

  // Arrange Views
  [tab putView:_drySlider atRow:3 column:0];
  [tab putView:_dryText atRow:3 column:1
       withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

  [tab putView:_wetSlider atRow:2 column:0];
  [tab putView:_wetText atRow:2 column:1
       withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

  [tab putView:_roomsizeSlider atRow:1 column:0];
  [tab putView:_roomsizeText atRow:1 column:1
       withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

  [tab putView:_dampSlider atRow:0 column:0];
  [tab putView:_dampText atRow:0 column:1
       withMinXMargin:10 maxXMargin:0 minYMargin:0 maxYMargin:0];

  [tab setXResizingEnabled: YES forColumn: 0];
  [tab setXResizingEnabled: NO  forColumn: 1];

}

- (void) makeWidgets {

  font = [NSFont userFixedPitchFontOfSize:12.0];

  tophbox = [GSHbox new];
  [tophbox setDefaultMinXMargin: 5];
  [tophbox setBorder: 5];
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

  [tophbox addView: button];

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

  [tophbox addView: playButton withMinXMargin:10.0];


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
  [vbox addSeparator];
 
  [self makeOscillatorRow];
  [self makeDrawbarRow];
  [self makeFilterRow];
  [self makeReverbRow];  
  
  // [self.fcSlider sizeToFit];
  [vbox addView: _reverbTable enablingYResizing:NO withMinYMargin:0];
  [vbox addSeparator];
  [vbox addView: _filterTable enablingYResizing:NO withMinYMargin:0];
  [vbox addSeparator];
  [vbox addView: _drawbarHbox enablingYResizing:NO withMinYMargin:10];
  [vbox addSeparator];
  [vbox addView: _oscillatorHbox enablingYResizing:NO withMinYMargin:10];
 
  [vbox addView: tophbox enablingYResizing: NO];
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

  winFrame.size = NSMakeSize (300, 400);
  winFrame.origin = NSMakePoint (300, 400);

  self.win = [[NSWindow alloc]
		      initWithContentRect: winFrame
				styleMask: (NSWindowStyleMaskTitled
					    | NSWindowStyleMaskClosable
					    | NSWindowStyleMaskResizable
					    | NSWindowStyleMaskMiniaturizable)
				  backing:NSBackingStoreBuffered
				    defer:NO];

  [self.win setTitle: @"MSK Organ Demo"];
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
}

- (void) makeFxPath {

  MSKGeneralFilter *filt = [[MSKGeneralFilter alloc] initWithCtx:_ctx];
  filt.sInput = _ctx.pbuf;
  filt.model = self.filtModel;
  [filt compile];

  MSKFreeverbReverb *rb = [[MSKFreeverbReverb alloc] initWithCtx:_ctx];
  rb.sInput = filt;
  rb.model = self.reverbModel;
  [rb compile];

  [_ctx addFx:rb];
}

- (void) makeModels {
  self.oscModel = [[MSKOscillatorModel alloc] init];
  self.oscModel.osctype = MSK_OSCILLATOR_TYPE_SQUARE;

  self.drawbarModel = [[MSKDrawbarModel alloc] init];

  self.envModel = [[MSKEnvelopeModel alloc] init];
  self.envModel.attack = 0.05;
  self.envModel.decay = 0.1;
  self.envModel.sustain = 0.8;
  self.envModel.rel = 0.2;

  self.filtModel = [[MSKFilterModel alloc] init];
  self.filtModel.filtertype = MSK_FILTER_MOOG;
  self.filtModel.fc = 2500;
  self.filtModel.q = 2.0;

  self.reverbModel = [[MSKReverbModel alloc] init];
  self.reverbModel.on = YES; // ToDo: make a GUI switch
}

- (void) makeNote {

  MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:_ctx];
  env.oneshot = YES;
  env.shottime = 1.0;		// 1.0 seconds
  env.model = _envModel;
  [env compile];

  int note = (random() % 12) + 64;

  MSKDrawbarOscillator *osc = [[MSKDrawbarOscillator alloc] initWithCtx:_ctx];
  osc.iNote = note;
  osc.sEnvelope = env;
  osc.model = _oscModel;
  osc.drawbarModel = _drawbarModel;
  [osc compile];

  [_ctx addVoice:osc];

}

/*
 * ToDo:
 * noteOn and noteOff are called from the MIDI queue, while makeNote
 * is called on the main thread.  This could lead to a race condition
 * retaining voices.
 */

- (void) noteOn:(NSUInteger)note {

  MSKContextEnvelope *e = _notes[@(note)];
  // if double repeat somehow
  if (e != nil) {
    [e noteAbort];		// release immediately
    [_notes removeObjectForKey:@(note)];
  }

  MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:_ctx];
  env.oneshot = NO;
  env.model = _envModel;
  [env compile];

  MSKDrawbarOscillator *osc = [[MSKDrawbarOscillator alloc] initWithCtx:_ctx];
  osc.iNote = note;
  osc.sEnvelope = env;
  osc.model = _oscModel;
  [osc compile];

  _notes[@(note)] = env;
  [_ctx addVoice:osc];
}

- (void) noteOff:(NSUInteger)note {
  MSKContextEnvelope *e = _notes[@(note)];
  if (e != nil) {
    [e noteOff];		// begin release
    [_notes removeObjectForKey:@(note)];
  }

}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
  ASKError_linker_function(); // cause NSError category to be linked
  MSKError_linker_function();

  [self appendLog:@"Welcome to MSK Organ Demo"];
  
  [self makeSeq];
  [self makeGreedyListener];

  [self makeWidgets];
  [vbox sizeToFit];
  // make min window size natural compacted size
  [self.win setMinSize: [NSWindow frameRectForContentRect: vbox.frame
  						styleMask: [self.win styleMask]].size];
  [self.win setContentView: vbox];
  

  [self.win makeKeyAndOrderFront:self];
  [self.win orderFrontRegardless];

  [self makeModels];
  [self makeContext];
  [self makeFxPath];
  [self makeNote];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

}

@end
