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

#include "./GSTable-MLdecls.h"

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (nonatomic, retain, strong) NSMenu *mainMenu;
@property (nonatomic, retain, strong) NSWindow *win;

@property (nonatomic, retain, strong) NSTextView *textview;

@property (nonatomic, retain, strong) MSKContext *ctx;
@property (nonatomic, retain, strong) MSKEnvelopeModel *envModel;
@property (nonatomic, retain, strong) MSKDrawbarOscillatorModel *oscModel;
@property (nonatomic, retain, strong) MSKReverbModel *reverbModel;
@property (nonatomic, retain, strong) MSKFilterModel *filtModel;

@property (nonatomic, retain, strong) NSMutableDictionary *notes;

@property (nonatomic, retain, strong) GSHbox *oscillatorHbox;
@property (nonatomic, retain, strong) MLCircularSliderWithValue *oscCombo;
@property (nonatomic, retain, strong) MLCircularSliderWithValue *attackCombo;
@property (nonatomic, retain, strong) MLCircularSliderWithValue *decayCombo;
@property (nonatomic, retain, strong) MLCircularSliderWithValue *sustainCombo;
@property (nonatomic, retain, strong) MLCircularSliderWithValue *releaseCombo;

@property (nonatomic, retain, strong) GSTable *reverbTable;
@property (nonatomic, retain, strong) NSSlider *drySlider;
@property (nonatomic, retain, strong) NSSlider *wetSlider;
@property (nonatomic, retain, strong) NSSlider *roomsizeSlider;
@property (nonatomic, retain, strong) NSSlider *dampSlider;
@property (nonatomic, retain, strong) NSTextField *dryText;
@property (nonatomic, retain, strong) NSTextField *wetText;
@property (nonatomic, retain, strong) NSTextField *roomsizeText;
@property (nonatomic, retain, strong) NSTextField *dampText;

@property (nonatomic, retain, strong) GSTable *filterTable;
@property (nonatomic, retain, strong) NSSlider *filtertypeSlider;
@property (nonatomic, retain, strong) NSSlider *fcSlider;
@property (nonatomic, retain, strong) NSSlider *fcmodSlider;
@property (nonatomic, retain, strong) NSTextField *filtertypeText;
@property (nonatomic, retain, strong) NSTextField *fcText;
@property (nonatomic, retain, strong) NSTextField *fcmodText;



@property (nonatomic, retain, strong) GSHbox *drawbarHbox;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v0;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v1;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v2;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v3;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v4;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v5;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v6;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v7;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v8;


@end
