/*
 * Make a seq, a metronome and a scheduler and run some patterns.
 * Add a context and make some notes.
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"
#import "../Pattern.h"

@interface Test : NSObject
@property (readwrite) ASKSeq *seq;
@property (readwrite) MSKMetronome *metro;
@property (readwrite) Scheduler *sched;
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
  [_seq setTempo:90 error:&err];

  if (error != nil) {
    NSLog(@"Could not create metronome. Error:%@", error);
    exit(1);
  }
  
}

- (void) makeScheduler {

  _sched = [[Scheduler alloc] init];
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
  self.oscModel.osctype = MSK_OSCILLATOR_TYPE_SAW;
  self.oscModel.pw = 25;

  self.pdModel = [[MSKModulatedOscillatorModel alloc] initWithName:@"osc2"];
  self.pdModel.osctype = MSK_OSCILLATOR_TYPE_SIN;
  self.pdModel.modulation = 3.5;

  self.envModel = [[MSKEnvelopeModel alloc] initWithName:@"env1"];
  self.envModel.attack = 0.01;
  self.envModel.decay = 0.05;
  self.envModel.sustain = 0.8;
  self.envModel.rel = 0.05;
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


- (void) run {

  NSLog(@"start test");
  [self makeSeq];
  [self makeMetronome];
  [self makeScheduler];
  [self makeContext];
  [self makeModels];

  NSLog(@"creating pattern");

  Pattern *pat = [[Pattern alloc] initWithName:@"pat1"];
  [pat thunk:^{
      NSLog(@"(%ld) INTRO ONE", _sched.ticktime);
      NSLog(@"sched:%@", _sched);
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"(%ld) ONE", _sched.ticktime);
      [self makeNote:64];
    }];
  [pat sync:@"clock"];
  [pat thunk:^{
      NSLog(@"(%ld) CLOCK AFTER ONE", _sched.ticktime);
    }];

  NSLog(@"here");
  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"(%ld) TWO", _sched.ticktime);
      [self makeNote:60];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"(%ld) THREE", _sched.ticktime);
      [self makeNote:59];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"(%ld) FOUR", _sched.ticktime);
      [self makeNote:60];
    }];
  [pat repeat:4];

  [_sched addLaunch:pat];

  // Add a delay
  Pattern *pat2 = [[Pattern alloc] initWithName:@"pat2"];
  // [pat2 sync:@"beat"];
  [pat2 thunk:^{
      NSLog(@"sched:%@", _sched);
      [self makeNote:70];
    }];
  [pat2 ticks:5];
  [pat2 thunk:^{
      NSLog(@"(%ld) DID SLEEP 1", _sched.ticktime);
      [self makeNote:70];
    }];
  [pat2 ticks:142];
  [pat2 thunk:^{
      NSLog(@"(%ld) DID SLEEP 2", _sched.ticktime);
      [self makeNote:70];
    }];
  [pat2 repeat:3];

  [_sched addLaunch:pat2];


  NSLog(@"sched:%@", _sched);

  [_metro start];

  sleep(11);
}

@end

int main(int argc, char *argv[]) {

  Test *test = [[Test alloc] init];
  [test run];


}
