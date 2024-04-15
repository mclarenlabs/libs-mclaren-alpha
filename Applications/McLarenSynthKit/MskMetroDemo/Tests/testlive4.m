/*
 * Basic test of liveloop functionality.
 * A single live-loop plays on beat 1,2,3 and then gets rescheduled.
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

}

- (void) makeContext {
  MSKContextRequest *request = [[MSKContextRequest alloc] init];
  request.rate = 44000;
  request.persize = 1024;
  request.periods = 2;

  NSString *devName = @"default";

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
   
  MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat1"];
  [pat thunk:^{
      NSLog(@"%@    INTRO ONE", [_sched fmtTime]);
    }];

  [pat sync:@"downbeat"];
  [pat thunk:^{
      NSLog(@"%@    ONE", [_sched fmtTime]);
      [self makeNote:32];
      [self playSample:tom];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    TWO", [_sched fmtTime]);
      // [self playSample:tom];
      [self playSample:clap];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    THREE", [_sched fmtTime]);
      [self playSample:tom
       ];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    FOUR", [_sched fmtTime]);
      // [self playSample:tom];
      [self playSample:clap];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    FIVE", [_sched fmtTime]);
      [self playSample:spat];
      [self playSample:tom];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    SIX", [_sched fmtTime]);
      // [self playSample:tom];
      [self playSample:clap];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    SEVEN", [_sched fmtTime]);
      [self playSample:tom
       ];
    }];

  [pat ticks:60];
  [pat thunk:^{
      // [self playSample:clap];
      [self playSample:clack];
    }];
  
  [pat ticks:30];
  [pat thunk:^{
      // [self playSample:clap];
      [self playSample:clack];
    }];
  
  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    EIGHT", [_sched fmtTime]);
      // [self playSample:tom];
      [self playSample:clack];
    }];


  [_sched setLiveloop:@"loop1" pat:pat];

  NSLog(@"sched:%@", _sched);

  [_metro start];

  sleep(15);
}

@end

int main(int argc, char *argv[]) {

  Test *test = [[Test alloc] init];
  [test run];


}
