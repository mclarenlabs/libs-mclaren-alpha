/**
 * MidiTalk - StepTalk scriptable MIDI synth thing
 *
 */

#import <AppKit/AppKit.h>

#import "McLarenSynthKit/McLarenSynthKit.h"
#import "ASKSeqDispatcher.h"

#import "NSScrollSlider.h"
#import "MLPianoController.h"
#import "MLGaugesController.h"
#import "MLButtonsController.h"
#import "MLFilterController.h"
#import "MLReverbController.h"
#import "MLContextController.h"
#import "MLLamp.h"
#import "MLActivity.h"

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (nonatomic, retain, strong) NSMenu *mainMenu;
@property (nonatomic, retain, strong) NSWindow *mainWindow;

@property (nonatomic, retain, strong) NSButton *startButton;
@property (nonatomic, retain, strong) NSButton *stopButton;
@property (nonatomic, retain, strong) NSButton *continueButton;
@property (nonatomic, retain, strong) NSScrollSlider *tempoSlider;
@property (nonatomic) int tempo;
@property (nonatomic, retain, strong) NSTextField *tempoText;

@property (nonatomic, retain, strong) MLLamp *lamp1;
@property (nonatomic, retain, strong) MLLamp *lamp2;
@property (nonatomic, retain, strong) MLLamp *lamp3;
@property (nonatomic, retain, strong) MLLamp *lamp4;

@property (nonatomic, retain, strong) MLActivity *activity0;
@property (nonatomic, retain, strong) MLActivity *activity1;
@property (nonatomic, retain, strong) MLActivity *activity2;


@property (nonatomic, retain, strong) MLGaugesController *gaugesController;
@property (nonatomic, retain, strong) MLButtonsController *buttonsController;
@property (nonatomic, retain, strong) MLPianoController *pianoController;

// Audio Elements
@property (nonatomic, retain, strong) MSKContext *ctx;
@property (nonatomic, retain, strong) MSKContext *rec;
@property (nonatomic, retain, strong) ASKSeq *seq;
@property (nonatomic, retain, strong) ASKSeqDispatcher *disp;

@property (nonatomic, retain, strong) MSKMetronome *metro;
@property (nonatomic, retain, strong) MSKScheduler *sched;

@property MLContextController *outputContextController;
@property MLContextController *inputContextController;
@property MLFilterController *filterController;
@property MLReverbController *reverbController;

@property (nonatomic, retain, strong) MSKFilterModel *filterModel;
@property (nonatomic, retain, strong) MSKReverbModel *reverbModel;



@end
