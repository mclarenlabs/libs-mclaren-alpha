/*
 * This will use patterns in a musical way where the third beat
 * has a sequence of sixteenths notes.
 *
 * In this test, the sixteenth note pattern also varies a parameter of a model.
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

@interface Test : NSObject
@property (readwrite) ASKSeq *seq;
@property (readwrite) MSKMetronome *metro;
@property (readwrite) MSKScheduler *sched;
@property (readwrite) MSKContext *ctx;
@property (readwrite) MSKOscillatorModel *osc1Model;
@property (readwrite) MSKOscillatorModel *osc2Model;
@property (readwrite) MSKEnvelopeModel *env1Model;
@property (readwrite) NSInteger root; // root note of the pattern

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

  NSString *devName = @"default";	// pipewire, etc
  // NSString *devName = @"hw:0,0";	// potentially better timing

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
  self.osc2Model.osctype = MSK_OSCILLATOR_TYPE_SQUARE;
  self.osc2Model.transpose = -5; // detuned

  self.env1Model = [[MSKEnvelopeModel alloc] initWithName:@"env1"];
  self.env1Model.attack = 0.02;
  self.env1Model.decay = 0.30;
  self.env1Model.sustain = 0.50;
  self.env1Model.rel = 1.0;

}

- (void) makeNote:(int)note vel:(double)vel {

  MSKExpEnvelope *env1 = [[MSKExpEnvelope alloc] initWithCtx:_ctx];
  env1.iGain = vel;
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

/*
 * This is the figure that is going to play with different root notes
 * and different repetition counts.
 */

- (MSKPattern*) makePat:(int)howManyTimes {
  int eigth = 55;		// ahead of the beat slightly
  MSKPattern *pat = [[MSKPattern alloc] initWithName:@"pat1"];
  [pat sync:@"beat"];
  
  [pat thunk:^{
      NSLog(@"%@    ONE", [_sched fmtTime]);
      [self makeNote:_root vel:1.0];
    }];
  [pat ticks:eigth];
  [pat thunk:^{
      [self makeNote:_root vel:0.5];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      [self makeNote:_root+2 vel:1.0];
    }];
  [pat ticks:eigth];
  [pat thunk:^{
      [self makeNote:_root vel:0.5];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      [self makeNote:_root+3 vel:1.0];
    }];
  [pat ticks:eigth];
  [pat thunk:^{
      [self makeNote:_root vel:0.5];
    }];

  [pat sync:@"beat"];
  [pat thunk:^{
      [self makeNote:_root+5 vel:1.0];
    }];
  [pat ticks:eigth];
  [pat thunk:^{
      [self makeNote:_root+3 vel:0.5];
    }];
  [pat repeat:howManyTimes];
  return pat;
}


- (void) run {

  NSLog(@"start test");
  [self makeSeq];
  [self makeMetronome];
  [self makeScheduler];
  [self makeContext];
  [self makeModels];

  NSLog(@"creating pattern");

  MSKPattern *patOnce = [self makePat:1];
  MSKPattern *patTwice = [self makePat:2];
   
  // Now change the root note value
  MSKPattern *pat2 = [[MSKPattern alloc] initWithName:@"pat2"];
  [pat2 thunk:^{
      self.root = 64; // middle-E
    }];
  [pat2 pat:patTwice]; // play the figure twice

  [pat2 thunk:^{
      self.root = 69;
    }];
  [pat2 pat:patTwice]; // play the figure twice

  [pat2 thunk:^{
      self.root = 64;
    }];
  [pat2 pat:patTwice]; // play the figure twice

  [pat2 thunk:^{
      self.root = 71; // middle-E
    }];
  [pat2 pat:patOnce]; // play the figure once

  [pat2 thunk:^{
      self.root = 69; // middle-E
    }];
  [pat2 pat:patOnce]; // play the figure once

  [pat2 thunk:^{
      self.root = 64; // middle-E
    }];
  [pat2 pat:patTwice]; // play the figure  twice

  [pat2 repeat:2];

  [_sched addLaunch:pat2];

  [_metro start];

  sleep(50);

}

@end

int main(int argc, char *argv[]) {

  Test *test = [[Test alloc] init];
  [test run];


}
