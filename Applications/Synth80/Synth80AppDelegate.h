/*
 * ButtonSynth has three buttons that play sounds
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "NSScrollSlider.h"
#import "McLarenSynthKit/McLarenSynthKit.h"
#import "MLCircularSliderWithValue.h"
#import "MLVerticalSliderWithValue.h"
#import "MLStepperWithValue.h"

#import "Synth80Model.h"
#import "Synth80AlgorithmEngine.h"

#import "MLOscillatorController.h"
#import "MLEnvelopeController.h"
#import "MLDrawbarController.h"
#import "MLModulationController.h"
#import "MLFilterController.h"
#import "MLReverbController.h"
#import "MLContextController.h"
#import "MLContextBufferView.h"
#import "MLVUMeterView.h"
#import "MLPianoController.h"
#import "MLSampleController.h"
#import "Synth80AlgorithmController.h"

#include "./GSTable-MLdecls.h"

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (nonatomic, retain, strong) NSMenu *mainMenu;
@property (nonatomic, retain, strong) NSWindow *win;

@property (nonatomic, retain, strong) NSTextView *textview;

@property (nonatomic, retain, strong) MSKContext *ctx;
@property (nonatomic, retain, strong) ASKSeq *seq;

@property (nonatomic, retain, strong) Synth80Model *model;

@property (nonatomic, retain, strong) Synth80AlgorithmEngine *algorithmEngine;

- (void) clearLog:(NSControl*)sender;
- (void) appendLog:(NSString*)message;
- (void) makeNote;

@end
