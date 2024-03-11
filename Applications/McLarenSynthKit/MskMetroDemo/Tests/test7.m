/*
 * This will use patterns in a musical way where the third beat
 * has a sequence of sixteenths notes.
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

  /*
   * Four sixteenth notes with a high note
   */

  Pattern *sixt = [[Pattern alloc] initWithName:@"sixt"];
  [sixt sync:@"beat"];
  [sixt thunk:^{
      [self makeNote:80];
    }];
  for (int i = 0; i < 6; i++) {
    [sixt sync:@"clock"];
  }
  [sixt thunk:^{
      [self makeNote:80];
    }];
  for (int i = 0; i < 6; i++) {
    [sixt sync:@"clock"];
  }
  [sixt thunk:^{
      [self makeNote:80];
    }];
  for (int i = 0; i < 6; i++) {
    [sixt sync:@"clock"];
  }
  [sixt thunk:^{
      [self makeNote:80];
    }];
  // [sixt repeat:1];
       
      

  /*
   * A one-measure pattern with beats 1 and 2 normal, beat 3 is the sixteenth
   * note pattern above and beat 4 is normal. Repeats 4 times.
   */
   
  Pattern *pat = [[Pattern alloc] initWithName:@"pat1"];
  [pat thunk:^{
      NSLog(@"%@    INTRO ONE", [_sched fmtTime]);
      NSLog(@"sched:%@", _sched);
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    ONE", [_sched fmtTime]);
      [self makeNote:64];
    }];
  [pat sync:@"clock"];
  [pat thunk:^{
      NSLog(@"%@    CLOCK AFTER ONE", [_sched fmtTime]);
    }];

  NSLog(@"here");
  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    TWO", [_sched fmtTime]);
      [self makeNote:60];
    }];

  // The THIRD beat is a subroutine
  // [pat sync:@"beat"];
  [pat pat:sixt];

  [pat sync:@"beat"];
  [pat thunk:^{
      NSLog(@"%@    FOUR", [_sched fmtTime]);
      [self makeNote:60];
    }];
  [pat repeat:4];

  [_sched addLaunch:pat];

  /*
   * Play another pattern that is not rhythmically related to the first
   */

  Pattern *pat2 = [[Pattern alloc] initWithName:@"pat2"];
  [pat2 sync:@"beat"];
  [pat2 thunk:^{
      NSLog(@"sched:%@", _sched);
      [self makeNote:45];
    }];
  // [pat2 ticks:55];
  [pat2 seconds:0.3];
  [pat2 thunk:^{
      // double real = _sched.sec + (_sched.nsec / 1000000000.0);
      NSLog(@"%@    DID SLEEP 1", [_sched fmtTime]);
      [self makeNote:44];
    }];
  [pat2 ticks:35];
  [pat2 thunk:^{
      NSLog(@"%@    DID SLEEP 2", [_sched fmtTime]);
      [self makeNote:43];
    }];
  [pat2 ticks:85];
  [pat2 repeat:3];

  [_sched addLaunch:pat2];


  NSLog(@"sched:%@", _sched);

  [_metro start];

  sleep(12);


}

@end

int main(int argc, char *argv[]) {

  Test *test = [[Test alloc] init];
  [test run];


}
