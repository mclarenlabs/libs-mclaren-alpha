/*
 * ButtonSynth has three buttons that play sounds
 *
 */

#import <AppKit/AppKit.h>
#import "MLPiano.h"
#import "MLSampleView.h"
#import "LabelWithValue.h"

#import "McLarenSynthKit/McLarenSynthKit.h"

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (nonatomic, retain, strong) NSMenu *mainMenu;
@property (nonatomic, retain, strong) NSWindow *mainWindow;

@property (nonatomic, retain, strong) MSKContext *ctx; // playback
@property (nonatomic, retain, strong) MSKContext *rec; // capture

@property (nonatomic, retain, strong) MSKSample *recsample;
@property (nonatomic, retain, strong) MSKSampleRecorder *recorder;

@property (nonatomic, retain, strong) MSKSample *playsample;

@property (nonatomic, retain, strong) NSButton *but1;

@property (nonatomic, retain, strong) MLPiano *piano;
@property (nonatomic, retain, strong) NSButton *octaveDown;
@property (nonatomic, retain, strong) NSButton *octaveUp;
@property (nonatomic, retain, strong) LabelWithValue *octaveLabel;

@property (nonatomic, retain, strong) MLSampleView *sampleView;

@end
