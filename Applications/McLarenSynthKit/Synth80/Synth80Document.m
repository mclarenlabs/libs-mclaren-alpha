/** -*- mode: objc -*-
 *
 * A Synth80 document records the states of the models.
 * Observers track changes to the models to implement Undo
 *
 * McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "Synth80AppDelegate.h"
#import "Synth80Document.h"
#import "Synth80WindowController.h"

@implementation Synth80Document {
  Synth80WindowController *windowController; // save so it can be closed
  NSArray *keys;
}

- (id) init {
  if (self = [super init]) {
    NSLog(@"Synth80Document init:%@", self.fileName);

    // keys of the model relative to top
    keys = @[
	     @"env1Model.attack",
	      @"env1Model.decay",
	      @"env1Model.sustain",
	      @"env1Model.rel",
	      @"env1Model.sens",

	      @"osc1Model.osctype",
	      @"osc1Model.octave",
	      @"osc1Model.transpose",
	      @"osc1Model.cents",
	      @"osc1Model.bendwidth",
	      @"osc1Model.pw",
	      @"osc1Model.harmonic",
	      @"osc1Model.subharmonic",

	      @"drawbar1Model.overtones",
	      @"drawbar1Model.amp0",
	      @"drawbar1Model.amp1",
	      @"drawbar1Model.amp2",
	      @"drawbar1Model.amp3",
	      @"drawbar1Model.amp4",
	      @"drawbar1Model.amp5",
	      @"drawbar1Model.amp6",
	      @"drawbar1Model.amp7",
	      @"drawbar1Model.amp8",

	      @"env2Model.attack",
	      @"env2Model.decay",
	      @"env2Model.sustain",
	      @"env2Model.rel",
	      @"env2Model.sens",

	      @"osc2Model.osctype",
	      @"osc2Model.octave",
	      @"osc2Model.transpose",
	      @"osc2Model.cents",
	      @"osc2Model.bendwidth",
	      @"osc2Model.pw",
	      @"osc2Model.harmonic",
	      @"osc2Model.subharmonic",

	      @"modulationModel.modulation",
	      @"modulationModel.pitchbend",

	      @"algorithmModel.algorithm",

	      // @"reverbModel.on",
	      @"reverbModel.dry",
	      @"reverbModel.wet",
	      @"reverbModel.roomsize",
	      @"reverbModel.damp",

	      @"filtModel.filtertype",
	      @"filtModel.fc",
	      @"filtModel.q",
	      @"filtModel.fcmod",
	     ];

    // TOM: 2024-05-17 -  moved this here from doc load
    [self registerObservers];
  }
  return self;
}

//
// Make the controller
//

- (void) makeWindowControllers {

  NSLog(@"Synth80Document makeWindowControllers:%@", self.fileName);
  windowController = [Synth80WindowController sharedWindowController];
  // [windowController.document close];
  Synth80Document *doc  = windowController.document;
  [doc close];

  // setDocument so we can close is, also so we get nice Title handling
  [windowController setDocument: self];

  [self addWindowController: windowController];

}

- (void) close {
  NSLog(@"Synth80Document close:%@", self.fileName);
  [self unregisterObservers];
  [self removeWindowController: windowController];
  [super close];
}

//
// KVO Observing and UNDO
//
- (void) registerObservers {

  AppDelegate *appDelegate = [NSApp delegate];
  Synth80Model *model = appDelegate.model;

  NSLog(@"registerObservers:%@", model);

  for (NSString *key in keys) {
    NSLog(@"%@ addObserver:%@", self.fileName, key);
    [model addObserver: self
	    forKeyPath: key
	       options: NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
	       context: nil];
  }

}

- (void) unregisterObservers {
  
  AppDelegate *appDelegate = [NSApp delegate];
  Synth80Model *model = appDelegate.model;

  for (NSString *key in keys) {
    NSLog(@"%@ unregisterObserver:%@", self.fileName, key);
    [model removeObserver: self
	       forKeyPath: key];
  }
}

- (void) observeValueForKeyPath: (NSString*) keyPath
		       ofObject: (Synth80Model*) model
			change: (NSDictionary*) change
			context: (void*) context
{
  NSLog(@"Observe %@", keyPath);
  NSUndoManager *undo = [self undoManager];
  
  NSLog(@"Observe '%@' of %@ %@", keyPath, model, change);
  if (![model isKindOfClass: [Synth80Model class]]) return;

  switch ([[change objectForKey: NSKeyValueChangeKindKey] intValue]) {
  case NSKeyValueChangeSetting:
    {
      id old = [change objectForKey: NSKeyValueChangeOldKey];

      // Construct the inverse invocation
      NSMethodSignature *sig = [model methodSignatureForSelector:
					       @selector(setValue:forKeyPath:)];
      NSInvocation *inv = [NSInvocation invocationWithMethodSignature: sig];
      [inv setSelector: @selector(setValue:forKeyPath:)];
      [inv setArgument: &old atIndex: 2];
      [inv setArgument: &keyPath atIndex: 3];

      /*
       * Skip undo of NSString fields: undo of Text field is handled *within* the
       * field while editing, and it also breaks the undo history at that point.
       * This is the normal behavior.  Tracking undo of wholesale changes to the
       * text field does not work (well) with the per-field mechanism.
       */
      if ([old isKindOfClass:[NSString class]]) {
	NSLog(@"skipping string value");
	return;
      }

      else {
	// Register it with the undo manager
	[[undo prepareWithInvocationTarget: model] forwardInvocation: inv];
	[undo setActionName: keyPath];
      }
    }
  }
}

//
// NSCoding
//

- (NSData*) dataOfType: (NSString*)typeName error: (NSError**)outError {

  NSLog(@"Synth80Document dataOfType:%@", typeName);
  AppDelegate *appDelegate = [NSApp delegate];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject: appDelegate.model];

  return data;
}

- (BOOL) readFromData: (NSData*)data ofType: (NSString*)typeName error: (NSError**)outError {

  NSLog(@"Synth80Document readFromData:%@", typeName);

  // This document has observers set during init.  If it is read from data, we disable UNDO
  // by unregistering the observers, and then add them back in at the end.
  [self unregisterObservers];

  Synth80Model *m = [NSKeyedUnarchiver unarchiveObjectWithData: data];


  if (nil == m) {
    *outError = [NSError errorWithDomain: NSOSStatusErrorDomain
				    code: 33
				userInfo: nil];
  }

  AppDelegate *appDelegate = [NSApp delegate];
  Synth80Model *model = appDelegate.model;

  // copy document values into the real model
  for (NSString *key in keys) {
    NSLog(@"copy:%@", key);
    id value = [m valueForKeyPath:key];

    if (value == nil) {
      NSLog(@"skipping NULL value");
      break;
    }
    
    NSLog(@"value:%@", value);
    [model setValue:value forKeyPath:key];
  }

  [self registerObservers];

  return YES;
}

- (void) dealloc {
  NSLog(@"Synth80Document dealloc:%@", self.fileName);
}

@end
