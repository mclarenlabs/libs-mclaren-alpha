/*
 * Managing the loading of samples and creating of patterns.
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "PatternManager.h"
#import "McLarenSynthKit/MSKPattern.h"

@implementation PatternManager

- (id) initWithCtx:(MSKContext*)ctx andSched:(MSKScheduler*)sched {
  if (self = [super init]) {
    _ctx = ctx;
    _sched = sched;
  }
  return self;
}

- (MSKSample*) loadSampleWithName:(NSString*)name {
  MSKSampleManager *manager = [MSKSampleManager defaultManager];
  MSKSample *samp;
  NSString *path;
  NSError *err;

  path = [manager sampleWithName:name];
  if (path == nil) {
    NSLog(@"cannot find sample '%@'", name);
    exit(1);
  }
  samp = [[MSKSample alloc] initWithFilePath:path error:&err];
  if (err != nil) {
    NSLog(@"cannot load sample '%@'", name);
    exit(1);
  }
  NSLog(@"sample:%@", samp);
  return samp;
}

- (void) loadSamples {

  _clap = [self loadSampleWithName:@"clap1"];
  _spat = [self loadSampleWithName:@"spat1"];
  _tom = [self loadSampleWithName:@"lidtom1"];
  _clack = [self loadSampleWithName:@"spoonclack1"];

  _lowtom = [_tom resampleBy:1.5];
  NSLog(@"_lowtom %@", _lowtom);
  // _hitom = [_tom resampleBy:2.0/3.0];
  _hitom = [_tom resampleBy:1.0/3.0];
  NSLog(@"_hitom %@", _hitom);
}

- (void) makeModels {
  self.oscModel = [[MSKOscillatorModel alloc] initWithName:@"osc1"];
  self.oscModel.osctype = MSK_OSCILLATOR_TYPE_SQUARE;
  self.oscModel.pw = 25;

  self.pdModel = [[MSKModulatedOscillatorModel alloc] initWithName:@"osc2"];
  self.pdModel.osctype = MSK_OSCILLATOR_TYPE_SIN;
  self.pdModel.modulation = 1.5;

  self.envModel = [[MSKEnvelopeModel alloc] initWithName:@"env1"];
  self.envModel.attack = 0.01;
  self.envModel.decay = 0.05;
  self.envModel.sustain = 0.8;
  self.envModel.rel = 0.05;
}

- (void) makeNote:(int)note {

  MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:_ctx];
  env.oneshot = YES;
  env.shottime = 1.0;
  env.model = _envModel;
  [env compile];

  MSKGeneralOscillator *osc = [[MSKGeneralOscillator alloc] initWithCtx:_ctx];
  osc.iNote = note-1;
  osc.sEnvelope = env;
  osc.model = _oscModel;
  [osc compile];

  MSKPhaseDistortionOscillator *pd = [[MSKPhaseDistortionOscillator alloc] initWithCtx:_ctx];
  pd.iNote = note;
  pd.sEnvelope = env;
  pd.model = _pdModel;
  pd.sPhasedistortion = osc;
  [pd compile];
  

  [_ctx addVoice:pd];
}

- (void) playSample:(MSKSample*)samp {
  MSKSamplePlayer *player = [[MSKSamplePlayer alloc] initWithCtx:_ctx];
  player.sample = samp;
  [_ctx addVoice:player];
}

- (void) makePat1 {

  MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat1"];
  [pat thunk:^{
      NSLog(@"%@    INTRO ONE", [_sched fmtTime]);
    }];

  [pat sync:@"downbeat"];
  [pat thunk:^{
      NSLog(@"%@    ONE", [_sched fmtTime]);
      [self makeNote:32];
      [self playSample:_tom];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    TWO", [_sched fmtTime]);
      // [self playSample:tom];
      [self playSample:_clap];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    THREE", [_sched fmtTime]);
      [self playSample:_tom
       ];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    FOUR", [_sched fmtTime]);
      // [self playSample:tom];
      [self playSample:_clap];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    FIVE", [_sched fmtTime]);
      [self playSample:_spat];
      [self playSample:_tom];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    SIX", [_sched fmtTime]);
      // [self playSample:tom];
      [self playSample:_clap];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    SEVEN", [_sched fmtTime]);
      [self playSample:_tom
       ];
    }];

  [pat ticks:60];
  [pat thunk:^{
      // [self playSample:clap];
      [self playSample:_clack];
    }];
  
  [pat ticks:30];
  [pat thunk:^{
      // [self playSample:clap];
      [self playSample:_clack];
    }];
  
  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    EIGHT", [_sched fmtTime]);
      // [self playSample:tom];
      [self playSample:_clack];
    }];

  _pat1 = pat;
}

- (void) XXmakePat2 {
  MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat2"];

  [pat sync:@"downbeat"];	// ONE
  [pat thunk:^{
      [self playSample:_hitom];
    }];

  [pat ticks:30];
  [pat thunk:^{
      [self playSample:_hitom];
    }];
  
  [pat sync:@"beat"];		// TWO
  [pat thunk:^{
      [self playSample:_tom];
      [self playSample:_clap];
    }];

#if 1
  [pat ticks:60];
  [pat thunk:^{
      [self playSample:_lowtom];
    }];
#endif
  
  [pat sync:@"beat"];		// THREE
  [pat thunk:^{
      [self playSample:_tom];
    }];

  [pat ticks:30];
  [pat thunk:^{
      [self playSample:_hitom];
    }];
  
  [pat sync:@"beat"];		// FOUR
  [pat thunk:^{
      [self playSample:_hitom];
      [self playSample:_clap];
    }];
  
  [pat sync:@"beat"];		// FIVE
  [pat thunk:^{
      [self playSample:_tom];
    }];

#if 1
  [pat ticks:60];
  [pat thunk:^{
      [self playSample:_lowtom];
    }];
#endif
  
  [pat sync:@"beat"];		// SIX
  [pat thunk:^{
      [self playSample:_lowtom];
    }];
  [pat ticks:60];
  [pat thunk:^{
      [self playSample:_hitom];
    }];
  [pat ticks:60];
  [pat thunk:^{
      [self playSample:_clap];
    }];
  [pat ticks:60];
  [pat thunk:^{
      [self playSample:_clap];
    }];
  [pat ticks:60];		// SEVEN
  [pat thunk:^{
      [self playSample:_clap];
    }];

  _pat2 = pat;
}

- (void) makePat2:(MSKSample*)clave tom:(MSKSample*)tom {
  MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat2"];

  [pat sync:@"downbeat"];	// ONE
  [pat thunk:^{
      [self playSample:clave];
    }];

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:clave];
    }];

  [pat sync:@"beat"];		// TWO

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:clave];
    }];

  [pat sync:@"beat"];		// THREE
  [pat thunk:^{
    }];

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:clave];
    }];
  
  [pat sync:@"beat"];		// FOUR
  [pat thunk:^{
      [self playSample:clave];
    }];

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:tom];
    }];
  
  [pat ticks:30];
  [pat thunk:^{
      [self playSample:tom];
    }];
  
  [pat sync:@"beat"];		// FIVE
  [pat thunk:^{
      [self playSample:clave];
    }];

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:clave];
    }];

  [pat sync:@"beat"];		// SIX

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:clave];
    }];

  [pat sync:@"beat"];		// SEVEN

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:clave];
    }];

  [pat sync:@"beat"];		// EIGHT
  [pat thunk:^{
      [self playSample:clave];
    }];

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:tom];
    }];
  
  [pat ticks:30];
  [pat thunk:^{
      [self playSample:tom];
    }];
  
  

  _pat2 = pat;
}

- (void) makePat3:(MSKSample*)clave clap:(MSKSample*)clap {
  MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat3"];

  [pat sync:@"downbeat"];	// ONE
  [pat thunk:^{
      [self makeNote:60];
      [self playSample:clave];
    }];

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:clave];
    }];
  
  [pat sync:@"beat"];		// TWO
  [pat thunk:^{
      [self makeNote:72];
      [self playSample:clave];
    }];

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:clave];
    }];
  
  [pat sync:@"beat"];		// THREE
  [pat thunk:^{
      [self makeNote:67];
      [self playSample:clave];
    }];

  [pat ticks:60];
  [pat thunk:^{
      [self playSample:clave];
    }];
  
  [pat sync:@"beat"];		// FOUR
  [pat thunk:^{
      [self playSample:clap];
    }];

  [pat ticks:30];
  [pat thunk:^{
      [self playSample:clap];
    }];

  [pat repeat:2];		// repeat it twice so that it is 8 beats
  
  _pat3 = pat;
}

- (void) initialize {

  [self loadSamples];
  [self makeModels];
  [self makePat1];
  [self makePat2:_clack tom:_lowtom];
  [self makePat3:_hitom clap:_clap];

}

@end
