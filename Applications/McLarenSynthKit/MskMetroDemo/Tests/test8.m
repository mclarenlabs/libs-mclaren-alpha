/*
 * This will use patterns in a musical way where the third beat
 * has a sequence of sixteenths notes.
 *
 * In this test, the sixteenth note pattern also varies a parameter of a model.
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"
#import "../Pattern.h"

@interface Test : NSObject
@property (readwrite) ASKSeq *seq;
@property (readwrite) MSKMetronome *metro;
@property (readwrite) Scheduler *sched;
@property (readwrite) MSKContext *ctx;
@property (readwrite) MSKOscillatorModel *osc1Model;
@property (readwrite) MSKOscillatorModel *osc2Model;
@property (readwrite) MSKEnvelopeModel *env1Model;
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
  self.osc1Model = [[MSKOscillatorModel alloc] initWithName:@"osc1"];
  self.osc1Model.osctype = MSK_OSCILLATOR_TYPE_TRIANGLE;

  self.osc2Model = [[MSKOscillatorModel alloc] initWithName:@"osc2"];
  self.osc2Model.osctype = MSK_OSCILLATOR_TYPE_SIN;
  self.osc2Model.transpose = -6; // detuned

  self.env1Model = [[MSKEnvelopeModel alloc] initWithName:@"env1"];
  self.env1Model.attack = 0.02;
  self.env1Model.decay = 0.37;
  self.env1Model.sustain = 0.50;
  self.env1Model.rel = 1.0;

}

- (void) makeNote:(int)note {

  MSKExpEnvelope *env1 = [[MSKExpEnvelope alloc] initWithCtx:_ctx];
  env1.oneshot = YES;
  env1.shottime = 0.2;
  env1.model = _env1Model;
  [env1 compile];

  MSKGeneralOscillator *osc1 = [[MSKGeneralOscillator alloc] initWithCtx:_ctx];
  osc1.iNote = note;
  osc1.sEnvelope = env1;
  osc1.model = _osc1Model;
  [osc1 compile];

  [_ctx addVoice:osc1];

  MSKGeneralOscillator *osc2 = [[MSKGeneralOscillator alloc] initWithCtx:_ctx];
  osc2.iNote = note;
  osc2.sEnvelope = osc1;  // RING modulation
  osc2.model = _osc2Model;
  [osc2 compile];

  [_ctx addVoice:osc2];

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
      self.osc2Model.transpose = -7;
    }];
  //  for (int i = 0; i < 6; i++) {
  //    [sixt sync:@"clock"];
  //  }
  [sixt ticks:30];
  [sixt thunk:^{
      [self makeNote:80];
      self.osc2Model.transpose = -8;
    }];
  //  for (int i = 0; i < 6; i++) {
  //    [sixt sync:@"clock"];
  //}
  [sixt ticks:30];
  [sixt thunk:^{
      [self makeNote:80];
      self.osc2Model.transpose = -9;
    }];
  //  for (int i = 0; i < 6; i++) {
  //    [sixt sync:@"clock"];
  //  }
  [sixt ticks:30];
  [sixt thunk:^{
      [self makeNote:80];
      self.osc2Model.transpose = -10;
    }];
  // [sixt repeat:1];
       
      

  /*
   * A one-measure pattern with beats 1 and 2 normal, beat 3 is the sixteenth
   * note pattern above and beat 4 is normal. Repeats 4 times.
   */
   
  Pattern *pat = [[Pattern alloc] initWithName:@"pat1"];
  [pat thunk:^{
      NSLog(@"%@    INTRO ONE", [_sched fmtTime]);
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

  // The THIRD and FOURTH beat are subroutines
  [pat pat:sixt];
  [pat pat:sixt];
  [pat repeat:4];

  [_sched addLaunch:pat];

  /*
   * Play another pattern that is not rhythmically related to the first,
   * but that launches on a beat.
   */

  Pattern *pat2 = [[Pattern alloc] initWithName:@"pat2"];

  // four beats of nothing
  [pat2 sync:@"beat"];
  [pat2 sync:@"beat"];
  [pat2 sync:@"beat"];
  [pat2 sync:@"beat"];
  [pat2 intro];			// intro ends here

  [pat2 sync:@"beat"];		// repeat this part
  [pat2 thunk:^{
      [self makeNote:49];
    }];
  [pat2 seconds:0.3];
  [pat2 thunk:^{
      // NSLog(@"(%@) DID SLEEP 1", [_sched fmtTime]);
      [self makeNote:47];
    }];
  [pat2 seconds:0.3];
  [pat2 thunk:^{
      // NSLog(@"(%@) DID SLEEP 2", [_sched fmtTime]);
      [self makeNote:45];
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
