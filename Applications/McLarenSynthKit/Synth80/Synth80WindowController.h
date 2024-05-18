#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface Synth80WindowController : NSWindowController

@property (readwrite) NSWindow *mainWindow;

// the controllers
@property MLOscillatorController *osc1Controller;
@property MLEnvelopeController *env1Controller;
@property MLOscillatorController *osc2Controller;
@property MLEnvelopeController *env2Controller;
@property MLFilterController *filterController;
@property MLReverbController *reverbController;
@property MLModulationController *modulationController;
@property MLAlgorithmController *algorithmController;
@property (nonatomic, retain, strong) MLDrawbarController *drawbar1Controller;
@property (nonatomic, retain, strong) MLSampleController *sample1Controller;
@property (nonatomic, retain, strong) MLPianoController *pianoController;


+ (Synth80WindowController*) sharedWindowController;

@end
