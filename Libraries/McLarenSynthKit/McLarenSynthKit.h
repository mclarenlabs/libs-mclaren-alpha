/**
 * Umbrella include for McLaren Synth Kit
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/MSKError.h"
#import "McLarenSynthKit/MSKMetronome.h"
#import "McLarenSynthKit/MSKPattern.h"

#import "McLarenSynthKit/env/MSKEnvelopeFanout.h"
#import "McLarenSynthKit/env/MSKExpEnvelope.h"
#import "McLarenSynthKit/env/MSKLinEnvelope.h"

#import "McLarenSynthKit/filt/MSKGeneralFilter.h"

#import "McLarenSynthKit/fx/MSKFreeverbReverb.h"

#import "McLarenSynthKit/model/MSKEnvelopeModel.h"
// #import "McLarenSynthKit/model/MSKMetronomeModel.h"
#import "McLarenSynthKit/model/MSKOscillatorModel.h"
#import "McLarenSynthKit/model/MSKDrawbarModel.h"
#import "McLarenSynthKit/model/MSKReverbModel.h"
// #import "McLarenSynthKit/model/MSKValuesModel.h"

#import "McLarenSynthKit/voice/MSKFMPhaseEnvelopeOscillator.h"
#import "McLarenSynthKit/voice/MSKGeneralOscillator.h"
#import "McLarenSynthKit/voice/MSKDrawbarOscillator.h"
#import "McLarenSynthKit/voice/MSKPhaseDistortionOscillator.h"
#import "McLarenSynthKit/voice/MSKSinFixedOscillator.h"

#import "McLarenSynthKit/sample/MSKSample.h"
#import "McLarenSynthKit/sample/MSKSampleManager.h"
#import "McLarenSynthKit/sample/MSKSamplePlayer.h"
#import "McLarenSynthKit/sample/MSKSampleRecorder.h"
