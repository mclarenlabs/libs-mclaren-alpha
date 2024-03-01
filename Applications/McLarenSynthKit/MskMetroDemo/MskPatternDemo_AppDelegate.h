/*
 * ButtonSynth has three buttons that play sounds
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "AlsaSoundKit/AlsaSoundKit.h"
#import "McLarenSynthKit/McLarenSynthKit.h"
#import "Pattern.h"

#include "./GSTable-MLdecls.h"

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (nonatomic, retain, strong) NSMenu *mainMenu;
@property (nonatomic, retain, strong) NSWindow *win;
@property (nonatomic, retain, strong) NSButton *clearButton;
@property (nonatomic, retain, strong) NSButton *startButton;
@property (nonatomic, retain, strong) NSButton *stopButton;
@property (nonatomic, retain, strong) NSButton *continueButton;
@property (nonatomic, retain, strong) NSSlider *tempoSlider;
@property (nonatomic) int tempo;
@property (nonatomic, retain, strong) NSTextView *textview;

@property (nonatomic, retain, strong) NSSlider *osctypeSlider;


@property (nonatomic, retain, strong) ASKSeq *seq;
@property (nonatomic, retain, strong) MSKMetronome *metro;
@property (readwrite) Scheduler *sched;
@property (readwrite) NSInteger root; // root note of patttern
@property (nonatomic, retain, strong) MSKContext *ctx;
@property (nonatomic, retain, strong) MSKEnvelopeModel *envModel;
@property (nonatomic, retain, strong) MSKOscillatorModel *oscModel;
@property (nonatomic, retain, strong) MSKFilterModel *filtModel;


@end
