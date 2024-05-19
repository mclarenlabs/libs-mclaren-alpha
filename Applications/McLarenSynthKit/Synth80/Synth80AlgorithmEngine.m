/** -*- mode: objec -*-
 *
 * Synth80 Algorithms
 *
 * for each algorithm defined, this class implements the noteOn and noteOff
 * behavior.  Generally each algorithm adds a new voice graph to the Context,
 * but the topology of the graph is determined by the algorithm type.
 *
 * McLaren Labs 2024
 *
 */

#import "Synth80AlgorithmEngine.h"

@implementation Synth80AlgorithmEngine {
  NSMutableDictionary *_notes;
}

- (id) init {
  if (self = [super init]) {
    _notes = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (BOOL) noteOn:(unsigned)note vel:(unsigned)vel ctx:(MSKContext*)ctx model:(Synth80Model*)model {

  MSKContextEnvelope *e = _notes[@(note)];
  // if double repeat somehow
  if (e != nil) {
    [e noteAbort];		// release immediately
    [_notes removeObjectForKey:@(note)];
  }

  switch (model.algorithmModel.algorithm) {
  case SYNTH80_ALGORITHM_TYPE_OSC1:
    return [self osc1NoteOn:note vel:vel ctx:ctx model:model];
    break;
  case SYNTH80_ALGORITHM_TYPE_DRBR1:
    return [self drawbar1NoteOn:note vel:vel ctx:ctx model:model];
    break;
  case SYNTH80_ALGORITHM_TYPE_RING:
    return [self ringNoteOn:note vel:vel ctx:ctx model:model];
    break;
  case SYNTH80_ALGORITHM_TYPE_PHASE:
    return [self phaseNoteOn:note vel:vel ctx:ctx model:model];
    break;
  case SYNTH80_ALGORITHM_TYPE_FMPHASE:
    return [self fmphaseNoteOn:note vel:vel ctx:ctx model:model];
    break;
  }
}

/*
 * Add a simple single oscillator to the context
 */
- (BOOL) osc1NoteOn:(unsigned)note vel:(unsigned)vel ctx:(MSKContext*)ctx model:(Synth80Model*)model {
  MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx: ctx];
  env.oneshot = NO;
  env.iGain = [model.env1Model iGainForVel:vel];
  env.model = model.env1Model;
  [env compile];

  MSKGeneralOscillator *osc = [[MSKGeneralOscillator alloc] initWithCtx:ctx];
  osc.iNote = note;
  osc.sEnvelope = env;
  osc.model = model.osc1Model;
  osc.modulationModel = model.modulationModel;
  [osc compile];

  _notes[@(note)] = env;
  [ctx addVoice:osc];
  return YES;
}  
    

/*
 * Add a Drawbar Oscillator to the context
 */

- (BOOL) drawbar1NoteOn:(unsigned)note vel:(unsigned)vel ctx:(MSKContext*)ctx model:(Synth80Model*)model {

  MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx: ctx];
  env.oneshot = NO;
  env.iGain = [model.env1Model iGainForVel:vel];
  env.model = model.env1Model;
  [env compile];

  MSKDrawbarOscillator *osc = [[MSKDrawbarOscillator alloc] initWithCtx:ctx];
  osc.iNote = note;
  osc.sEnvelope = env;
  osc.model = model.osc1Model;
  osc.drawbarModel = model.drawbar1Model;
  osc.modulationModel = model.modulationModel;
  [osc compile];

  _notes[@(note)] = env;
  [ctx addVoice:osc];
  return YES;
}

/*
 * Let the output be osc1 * osc2.
 */
- (BOOL) ringNoteOn:(unsigned)note vel:(unsigned)vel ctx:(MSKContext*)ctx model:(Synth80Model*)model {

  MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx: ctx];
  env.oneshot = NO;
  env.iGain = [model.env1Model iGainForVel:vel];
  env.model = model.env1Model;
  [env compile];

  MSKGeneralOscillator *v1 = [[MSKGeneralOscillator alloc] initWithCtx:ctx];
  v1.iNote = note;
  v1.model = model.osc1Model;
  v1.sEnvelope = env;
  [v1 compile];

  MSKGeneralOscillator *v2 = [[MSKGeneralOscillator alloc] initWithCtx:ctx];
  v2.iNote = note;
  v2.model = model.osc2Model;
  v2.sEnvelope = v1;
  [v2 compile];

  _notes[@(note)] = env;
  [ctx addVoice:v2];
  return YES;
}

/*
 * Let the output be composed of two oscillators:
 *   osc1 with env1 generates a waveform.
 *   osc2 uses osc1 as its phase-distortion input
 */
- (BOOL) phaseNoteOn:(unsigned)note vel:(unsigned)vel ctx:(MSKContext*)ctx model:(Synth80Model*)model {
  MSKExpEnvelope *env1 = [[MSKExpEnvelope alloc] initWithCtx: ctx];
  env1.oneshot = NO;
  env1.iGain = [model.env1Model iGainForVel:vel];
  env1.model = model.env1Model;
  [env1 compile];

  MSKExpEnvelope *env2 = [[MSKExpEnvelope alloc] initWithCtx: ctx];
  env2.oneshot = NO;
  env2.iGain = [model.env2Model iGainForVel:vel];
  env2.model = model.env2Model;
  [env2 compile];

  MSKGeneralOscillator *v1 = [[MSKGeneralOscillator alloc] initWithCtx:ctx];
  v1.iNote = note;
  v1.model = model.osc1Model;
  v1.sEnvelope = env1;
  [v1 compile];

  MSKPhaseDistortionOscillator *v2 = [[MSKPhaseDistortionOscillator alloc] initWithCtx:ctx];
  v2.iNote = note;
  v2.model = model.osc2Model;
  v2.sEnvelope = env2;
  v2.sPhasedistortion = v1;
  [v2 compile];

  // Fan-out the method calls to multiple concurrent envelopes
  MSKEnvelopeFanout *fan = [[MSKEnvelopeFanout alloc] initWithCtx:ctx];
  fan.env1 = env1;
  fan.env2 = env2;

  _notes[@(note)] = fan;
  [ctx addVoice:v2];
  return YES;
}

/*
 * Let the output be composed of two oscillators:
 *   osc1 with env1 generates a waveform.
 *   osc2 is a pure FM SIN oscillator whose DPHI is determined by
       Harmonic/Subharmonic.  osc2's phase offset is controlled by osc1
 */
- (BOOL) fmphaseNoteOn:(unsigned)note vel:(unsigned)vel ctx:(MSKContext*)ctx model:(Synth80Model*)model {
  MSKLinEnvelope *env1 = [[MSKLinEnvelope alloc] initWithCtx: ctx];
  env1.oneshot = NO;
  env1.iGain = [model.env1Model iGainForVel:vel];
  env1.model = model.env1Model;
  [env1 compile];

  MSKExpEnvelope *env2 = [[MSKExpEnvelope alloc] initWithCtx: ctx];
  env2.oneshot = NO;
  env2.iGain = [model.env2Model iGainForVel:vel];
  env2.model = model.env2Model;
  [env2 compile];

  MSKGeneralOscillator *v1 = [[MSKGeneralOscillator alloc] initWithCtx:ctx];
  v1.iNote = note;
  v1.model = model.osc1Model;
  v1.sEnvelope = env1;
  [v1 compile];

  MSKFMPhaseEnvelopeOscillator *v2 = [[MSKFMPhaseEnvelopeOscillator alloc] initWithCtx:ctx];
  v2.iNote = note;
  v2.model = model.osc2Model;
  v2.sEnvelope = env2;
  v2.modulationModel = model.modulationModel;
  v2.sPhaseenvelope = v1;
  [v2 compile];

  // Fan-out the method calls to multiple concurrent envelopes
  MSKEnvelopeFanout *fan = [[MSKEnvelopeFanout alloc] initWithCtx:ctx];
  fan.env1 = env1;
  fan.env2 = env2;

  _notes[@(note)] = fan;
  [ctx addVoice:v2];
  return YES;
}

/*
 * NoteOff is all the same.  Find the currently playing envelope for the note and
 * tell it to begins its noteOff transition.  Release the reference to the envelope
 * from _notes.
 */
 
- (BOOL) noteOff:(unsigned)note vel:(unsigned)vel ctx:(MSKContext*)ctx model:(Synth80Model*)model {

  MSKContextEnvelope *e = _notes[@(note)];
  if (e != nil) {
    [e noteOff];		// begin release
    [_notes removeObjectForKey:@(note)];
  }

}

@end

