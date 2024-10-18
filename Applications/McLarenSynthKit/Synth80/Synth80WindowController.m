#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "Synth80AppDelegate.h"
#import "Synth80WindowController.h"

@implementation Synth80WindowController {
  NSButton *button;
  NSButton *playButton;
}

- (id) init {
  if (self = [super init]) {
    NSLog(@"Synth80WindowController init");

    [self makeWindow];
    [self setWindow: _mainWindow];

    [self makeBindings];
  }
  return self;
}

- (NSView*) populateVbox0 {

  GSVbox *vbox = [GSVbox new];
  [vbox setDefaultMinYMargin: 5];
  [vbox setBorder: 5];

  [vbox addView: [self populateBottomRow] enablingYResizing: YES];
  [vbox addView: [self populateMiddleRow] enablingYResizing: YES];
  [vbox addView: [self populateTopRow] enablingYResizing: NO];
  return vbox;
}

- (NSView*) populateTopRow {

  AppDelegate *appDelegate = [NSApp delegate];
  
  GSHbox *tophbox = [GSHbox new];
  [tophbox setDefaultMinXMargin: 5];
  [tophbox setBorder: 5];

  /* Button clearing the table.  */
  button = [NSButton new]; 
  [button setBordered: YES];
  [button setButtonType: NSMomentaryPushButton];
  [button setTitle:  @"Clear"];
  [button setImagePosition: NSNoImage]; 
  // [button setTarget: self];
  [button setTarget: appDelegate];
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
  // [playButton setTarget: self];
  [playButton setTarget: appDelegate];
  [playButton setAction: @selector(makeNote)];
  // [playButton setAutoresizingMask: NSViewMaxXMargin];
  [playButton sizeToFit];

  [tophbox addView: playButton withMinXMargin:10.0];

  return tophbox;
}

- (NSView*) populateMiddleRow {
  GSHbox *hbox = [GSHbox new];
  [hbox setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
  
  [hbox addView: [self populateOscArray] enablingXResizing: NO withMinXMargin:5];
  [hbox addView: [self populateAlgoColumn] enablingXResizing: NO withMinXMargin:5];
  [hbox addView: [self populateOutputColumn] enablingXResizing: YES withMinXMargin:5];
  return hbox;
}

- (NSView*) populateBottomRow {

  GSHbox *hbox = [GSHbox new];
  [hbox setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];

  // Make the MLPiano
  NSRect pianoRect = NSMakeRect(0, 0, 700, 200);
  _pianoController = [[MLPianoController alloc] initWithFrame: pianoRect];
  

  // Size the textview and scrollview, knowing the sizes will be computed
  AppDelegate *appDelegate = [NSApp delegate];
  
  appDelegate.textview = [NSTextView new];
  [appDelegate.textview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];  

  NSScrollView *sv = [NSScrollView new];
  [sv setHasVerticalScroller:YES];
  [sv setDocumentView:appDelegate.textview];
  [sv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];  
  [sv setFrame:NSMakeRect(0, 0, 300, 200)];

  [hbox addView: _pianoController enablingXResizing: NO];
  [hbox addView: sv enablingXResizing: YES];
  [hbox addSeparator];

  return hbox;
}

- (NSView*) populateOscArray {
  GSTable *table = [[GSTable alloc] initWithNumberOfRows:3 numberOfColumns:2];
  [table setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];

  _env1Controller = [MLEnvelopeController new];
  _env1Controller.title = @"Env1";
  [table putView: _env1Controller atRow:2 column:0];

  _osc1Controller = [MLOscillatorController new];
  _osc1Controller.title = @"Osc1";
  [table putView: _osc1Controller atRow:1 column:0];

  _drawbar1Controller = [MLDrawbarController new];
  _drawbar1Controller.title = @"Drawbar1";
  [table putView: _drawbar1Controller atRow:0 column:0];

  _env2Controller = [MLEnvelopeController new];
  _env2Controller.title = @"Env2";
  [table putView: _env2Controller atRow:2 column:1];

  _osc2Controller = [MLOscillatorController new];
  _osc2Controller.title = @"Osc2";
  [table putView: _osc2Controller atRow:1 column:1];

  _sample1Controller = [MLSampleController new];
  _sample1Controller.title = @"Sample1";
  [table putView: _sample1Controller atRow:0 column:1];
  return table;
}

- (NSView*) populateAlgoColumn {
  GSVbox *vbox = [GSVbox new];
  [vbox setAutoresizingMask: NSViewHeightSizable];

  _modulationController = [MLModulationController new];
  [_modulationController setAutoresizingMask: NSViewHeightSizable];
  
  _algorithmController = [Synth80AlgorithmController new];
  // [_algorithmController setAutoresizingMask: NSViewHeightSizable];

  [vbox addView: _algorithmController];
  [vbox addView: _modulationController];
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

- (void) makeWindow {

  NSRect windowRect = NSMakeRect(0, 100, 200, 125);
  self.mainWindow = [[NSWindow alloc]
		      initWithContentRect:windowRect
				styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
				  backing:NSBackingStoreBuffered
				    defer:NO];
  self.mainWindow.delegate = self;

  self.mainWindow.title = @"Synth80";
  // self.mainWindow.backgroundColor = [NSColor whiteColor];

  GSVbox *vbox0 = [self populateVbox0];
  [vbox0 sizeToFit];

  [self.mainWindow setMinSize: [NSWindow frameRectForContentRect: vbox0.frame
						       styleMask: [self.mainWindow styleMask]].size];
  //[self.win setContentView: vbox];
  [self.mainWindow setContentView: vbox0];
    

  // automatically save/restore window position by AppKit
  [self.mainWindow setFrameAutosaveName:@"Synth80"];

  [self.mainWindow makeKeyAndOrderFront:self];
  [self.mainWindow orderFrontRegardless];

}

- (void) bindToModel:(Synth80Model*)model {
  // TOM: To Do - connect the controllers to the models
  // [_one bindToModel: top.one];
  // [_two bindToModel: top.two];

  NSLog(@"bindToModel:%@", model.env1Model);
  NSLog(@"bindToModel:%@", _env1Controller);

  [_env1Controller bindToModel: model.env1Model];
  [_osc1Controller bindToModel: model.osc1Model];
  [_drawbar1Controller bindToModel: model.drawbar1Model];

  [_env2Controller bindToModel: model.env2Model];
  [_osc2Controller bindToModel: model.osc2Model];

  [_modulationController bindToModel: model.modulationModel];
  [_algorithmController bindToModel: model.algorithmModel];

  [_filterController bindToModel: model.filtModel];
  [_reverbController bindToModel: model.reverbModel];

  [_sample1Controller bindToModel: model.sample1Model];
  
}

- (void) makeBindings {
  AppDelegate *appDelegate = [NSApp delegate];

  NSLog(@"makeBindings:%@", appDelegate.model);
  
  [self bindToModel:appDelegate.model];

  
}

// NSWindowController wants to know that the window is loaded, and we aren't
// using a NIB, so override to get some nice Title handling
// via synchronizeWindowTitleWithDocumentName

- (BOOL) isWindowLoaded {
  return YES;
}

/*
 * This is a little bit tricky, and perhaps a little hacky.
 * This object saves the mainWindow - but the NSWindowController
 * also keeps the _window of setWindow and releases it if the window.
 * is closed.  By always setting the window of shared back to what
 * it is we make sure the window is never actually released.
 */

Synth80WindowController *shared = NULL;

+ (Synth80WindowController*) sharedWindowController {
  if (shared == NULL) {
    shared = [[Synth80WindowController alloc] init];
  }
  [shared setWindow: shared->_mainWindow];
  return shared;
}

- (void) close {
  NSLog(@"Synth80WindowController close");
}

- (void) windowWillClose:(id)sender {
  NSLog(@"Synth80WindowController windowWillClose:%@", sender);
}

- (void) dealloc {
  NSLog(@"Synth80WindowController dealloc");
}

@end
