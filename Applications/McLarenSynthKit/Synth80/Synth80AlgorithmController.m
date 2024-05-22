/** -*- mode: objc -*-
 *
 * Controller for MSKAlgorithmModel
 *
 */

#import <AppKit/AppKit.h>
#import "Synth80AlgorithmController.h"
#import "Synth80AppDelegate.h"

@implementation Synth80AlgorithmController

- (void) makeWidgets {

  // NSSize sliderSize = NSMakeSize(25, 50);
  // NSSize textSize = NSMakeSize(50, 25);

  NSSize circSize = NSMakeSize(100, 50);

  // _algorithmCombo = [[MLVerticalSliderWithValue alloc] initWithSliderSize:sliderSize
  // textSize:textSize];

  _algorithmCombo = [[MLCircularSliderWithValue alloc] initWithSize:circSize];
  [_algorithmCombo.titleTextField setStringValue:@"Algo"];
  [_algorithmCombo.slider setMinValue:0];
  [_algorithmCombo.slider setMaxValue:7];
  [_algorithmCombo.slider setNumberOfTickMarks:7];
  [_algorithmCombo.slider setAllowsTickMarkValuesOnly:YES];
  
}

- (id) init {
  if (self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)]) {	// nsbox
    [self setTitle:@"Algorithm"];

    [self setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    [self makeWidgets];

    [self setContentView: _algorithmCombo];
    [self sizeToFit];
  }
  return self;
}

/*
 * Helpful descriptions for the various algorithms
 */

NSString *osc1Desc = @"\n\
ALGORITHM: OSC1\n\
osc1 = wave(ϕ)\n\
\n\
    PATCHES\n\
    osc1.envelope = env1\n\
    osc1.modulation = modulation\n\
    osc1.pitchbend = pitchbend";

NSString *drawbarDesc = @"\n\
ALGORITHM: DRAWBAR\n\
osc1 = wave(ϕ) + wave(3*ϕ) + wave(2*ϕ) + wave(4*ϕ) + wave(6*ϕ)...\n\
\n\
    PATCHES\n\
    osc1.envelope = env1\n\
    osc1.modulation = modulation\n\
    osc1.pitchbend = pitchbend";

NSString *ringDesc = @"\n\
ALGORITHM: RING\n\
osc1 = wave1(ϕ)\n\
osc2 = wave2(ϕ)\n\
\n\
    PATCHES\n\
    osc1.envelope = env1\n\
    osc2.envelope = osc1";

NSString *pdDesc = @"\n\
ALGORITHM: PHASEDISTORTION\n\
osc1 = wave(ϕ)\n\
osc2 = fn(ϕ + (mod * osc1))\n\
\n\
    PATCHES\n\
    osc1.envelope = env1\n\
    osc2.env = env2\n\
    osc2.modulation = modulation\n\
    osc2.pitchbend = pitchbend";

NSString *fmpdDesc = @"\n\
ALGORITHM: FM PHASEDISTORTION\n\
osc1 = wave(ϕ)\n\
osc2 = sin(ϕ + (mod * phaseenvelope * sin(ϕ * harmonic/subharmonic)))\n\
\n\
    PATCHES\n\
    osc2.phaseenvelope = osc1\n\
    osc2.env = env2\n\
    osc2.modulation = modulation\n\
    osc2.pitchbend = pitchbend";

NSString *samp1Desc = @"\n\
ALGORITHM: SAMP1\n\
out = sample tranposed by note";

NSString *samp2Desc = @"\n\
ALGORITHM: SAMP2\n\
osc1 = wave(ϕ)\n\
out = sample * osc1";


// Render an algorithm description in the log when the algorithm changes
- (void) renderAlgorithmType:(id)sender {

  NSSlider *slider = (NSSlider*)sender;
  synth80_algorithm_type_enum val = [slider floatValue];

  AppDelegate *appDelegate = [NSApp delegate];

  switch(val) {
  case SYNTH80_ALGORITHM_TYPE_OSC1:
    [appDelegate appendLog:osc1Desc];
    break;

  case SYNTH80_ALGORITHM_TYPE_DRBR1:
    [appDelegate appendLog:drawbarDesc];
    break;

  case SYNTH80_ALGORITHM_TYPE_RING:
    [appDelegate appendLog:ringDesc];
    break;

  case SYNTH80_ALGORITHM_TYPE_PHASE:
    [appDelegate appendLog:pdDesc];
    break;
      
  case SYNTH80_ALGORITHM_TYPE_FMPHASE:
    [appDelegate appendLog:fmpdDesc];
    break;
    
  case SYNTH80_ALGORITHM_TYPE_SAMP1:
    [appDelegate appendLog:samp1Desc];
    break;

  case SYNTH80_ALGORITHM_TYPE_SAMP2:
    [appDelegate appendLog:samp2Desc];
    break;
  }

}


- (void) bindToModel:(Synth80AlgorithmModel*) model {

  // bindings
  [_algorithmCombo.slider bind:@"value"
		toObject:model
	     withKeyPath:@"algorithm"
		 options:nil];

  _algorithmCombo.slider.target = self;
  _algorithmCombo.slider.action = @selector(renderAlgorithmType:);

  [_algorithmCombo.valueTextField bind:@"value"
			      toObject:model
			   withKeyPath:@"algorithm"
			 options: @{
    NSValueTransformerBindingOption: [Synth80AlgorithmTypeValueTransformer new]
	}];

}

@end

  
