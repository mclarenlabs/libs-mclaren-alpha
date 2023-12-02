/*
 * ButtonSynth has three buttons that play sounds
 *
 */

#import <AppKit/AppKit.h>
#import "ToneGenerator.h"
#import "MLGauge.h"
#import "MLPad.h"
#import "MLPiano.h"
#import "LabelWithValue.h"

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (nonatomic, retain, strong) NSMenu *mainMenu;
@property (nonatomic, retain, strong) NSWindow *mainWindow;

@property (nonatomic, retain, strong) NSButton *but1;
@property (nonatomic, retain, strong) NSButton *but2;
@property (nonatomic, retain, strong) NSButton *but3;
@property (nonatomic, retain, strong) NSButton *but4;

@property (nonatomic, retain, strong) MLGauge *gauge1;
@property (nonatomic, retain, strong) MLGauge *gauge2;
@property (nonatomic, retain, strong) MLGauge *gauge3;
@property (nonatomic, retain, strong) MLGauge *gauge4;

@property (nonatomic, retain, strong) MLPad *pad;

@property (nonatomic, retain, strong) MLPiano *piano;
@property (nonatomic, retain, strong) NSButton *octaveDown;
@property (nonatomic, retain, strong) NSButton *octaveUp;
@property (nonatomic, retain, strong) LabelWithValue *octaveLabel;

@property (nonatomic, retain, strong) ToneGenerator *toneGen;

@end
