/*
 * This test plays a syncopated beat with a bass note and a drum sound.
 * The ContextRequest parameters have been adjust to a very short period
 * size of 128 frames.  The syncopation of the pattern becomes quantized
 * incorrectly with a period size of 1024.  Try both and listen to the
 * difference.
 *
 * Note: on some lower-performance computers (RPi3) such a small period
 * size may be challenging for the CPU.
 * 
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

@interface Test : NSObject
@property (readwrite) ASKSeq *seq;
@property (readwrite) MSKMetronome *metro;
@property (readwrite) MSKScheduler *sched;
@property (readwrite) MSKContext *ctx;
@property (readwrite) MSKOscillatorModel *oscModel;
@property (readwrite) MSKEnvelopeModel *envModel;
@property (readwrite) MSKModulatedOscillatorModel *pdModel;
@end

@implementation Test

- (void) makeSeq {

  ASKSeqOptions *options = [[ASKSeqOptions alloc] init];
  options->_sequencer_name = "metronome";

  NSError *error;
  _seq = [[ASKSeq alloc] initWithOptions:options error:&error];
  if (error != nil) {
    NSLog(@"Could not create sequencer.  Error:%@", error);
    exit(1);
  }
}

- (void) makeMetronome {

  NSError *error;
  _metro = [[MSKMetronome alloc] initWithSeq:_seq error:&error];

  // set tempo
  NSError *err;
  [_seq setTempo:120 error:&err];

  if (error != nil) {
    NSLog(@"Could not create metronome. Error:%@", error);
    exit(1);
  }
  
}

- (void) makeScheduler {

  _sched = [[MSKScheduler alloc] init];
  [_sched registerMetronome:_metro];

  _sched.log = YES;

}

- (void) makeContext {
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;

#define MOREPRECISE 1

#if MOREPRECISE
  request.persize = 128;
  request.periods = 4;
#else
  request.persize = 1024;
  request.periods = 2;
#endif

  NSString *devName = @"default";
  // NSString *devName = @"hw:0,0";

  NSError *error;
  BOOL ok;

  _ctx = [[MSKContext alloc] initWithName:devName
				andStream:SND_PCM_STREAM_PLAYBACK
				    error:&error];

  if (error != nil) {
    NSLog(@"MSKContext init error:%@", error);
    exit(1);
  }

  ok = [_ctx configureForRequest:request error:&error];
  if (ok == NO) {
    NSLog(@"MSKContext configure error:%@", error);
    exit(1);
  }

  ok = [_ctx startWithError:&error];
  if (ok == NO) {
    NSLog(@"MSKContext starting error:%@", error);
    exit(1);
  }

  _ctx.gain = 1.0;
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
  self.envModel.sustain = 0.8;
  // self.envModel.rel = 0.05;
  self.envModel.rel = 0.25;
}

- (void) makeNote:(int)note {

  MSKExpEnvelope *env = [[MSKExpEnvelope alloc] initWithCtx:_ctx];
  env.oneshot = YES;
  env.shottime = 0.1;
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


- (void) run {

  NSLog(@"start test");
  [self makeSeq];
  [self makeMetronome];
  [self makeScheduler];
  [self makeContext];
  [self makeModels];

  NSError *err;
  MSKSample *spat = [[MSKSample alloc] initWithFilePath:@"./spat1.wav" error:&err];
  if (err != nil) {
    NSLog(@"could not load sample 'spat1.wav'");
    exit(1);
  }

  MSKSample *tom = [[MSKSample alloc] initWithFilePath:@"./lidtom1.wav" error:&err];
  if (err != nil) {
    NSLog(@"could not load sample 'lidtom1.wav'");
    exit(1);
  }

  MSKSample *lowtom = [tom resampleBy:1.5];
  NSLog(@"_lowtom %@", lowtom);
  // _hitom = [_tom resampleBy:2.0/3.0];
  MSKSample *hitom = [tom resampleBy:1.0/3.0];
  NSLog(@"hi %@", hitom);
  

  MSKSample *clap = [[MSKSample alloc] initWithFilePath:@"./clap1.wav" error:&err];
  if (err != nil) {
    NSLog(@"could not load sample 'clap1.wav'");
    exit(1);
  }

  MSKSample *clack = [[MSKSample alloc] initWithFilePath:@"./spoonclack1.wav" error:&err];
  if (err != nil) {
    NSLog(@"could not load sample 'spoonclack1.wav'");
    exit(1);
  }

  NSLog(@"creating pattern");

  /*
   * A one-measure pattern with beats 1 and 2 normal, beat 3 is the sixteenth
   * note pattern above and beat 4 is normal. Repeats 4 times.
   */

  int note = 40;
   
  MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat1"];
  [pat sync:@"downbeat"];
  [pat thunk:^{
      [self makeNote:note];
    }];

  [pat ticks:60];
  [pat thunk:^{
      // [self makeNote:note];
    }];
  
  [pat ticks:30];
  [pat thunk:^{
      [self makeNote:note];
    }];
  

  [pat sync:@"beat"];
  [pat thunk:^{
      [self makeNote:note];
      [self playSample:hitom];
    }];

  [pat ticks:60];
  [pat thunk:^{
      [self makeNote:note];
    }];
  
  [pat ticks:30];
  [pat thunk:^{
      [self makeNote:note];
    }];
  
  [pat sync:@"beat"];
  [pat thunk:^{
      [self makeNote:note];
    }];


  [pat sync:@"beat"];
  [pat thunk:^{
      [self playSample:hitom];
    }];


  [_sched setLiveloop:@"loop1" pat:pat];

  NSLog(@"sched:%@", _sched);

  [_metro start];

  sleep(20);
}

@end

int main(int argc, char *argv[]) {

  Test *test = [[Test alloc] init];
  [test run];


}
