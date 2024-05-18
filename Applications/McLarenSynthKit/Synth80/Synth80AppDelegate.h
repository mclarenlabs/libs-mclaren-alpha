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

#import "MLOscillatorController.h"
#import "MLEnvelopeController.h"
#import "MLDrawbarController.h"
#import "MLModulationController.h"
#import "MLFilterController.h"
#import "MLReverbController.h"
#import "MLAlgorithmController.h"
#import "MLContextBufferView.h"
#import "MLPianoController.h"
#import "MLSampleController.h"

#include "./GSTable-MLdecls.h"

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (nonatomic, retain, strong) NSMenu *mainMenu;
@property (nonatomic, retain, strong) NSWindow *win;

@property (nonatomic, retain, strong) NSTextView *textview;

@property (nonatomic, retain, strong) MSKContext *ctx;
@property (nonatomic, retain, strong) ASKSeq *seq;

@property (nonatomic, retain, strong) Synth80Model *model;

@property (nonatomic, retain, strong) NSScrollSlider *outputVolumeSlider;
@property (nonatomic, retain, strong) MLContextBufferView *contextBufferView;

@property (nonatomic, retain, strong) NSMutableDictionary *notes;



@end
