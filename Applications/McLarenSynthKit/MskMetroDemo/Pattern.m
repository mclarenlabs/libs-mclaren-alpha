/** -*- mode: objc -*-
 *
 * A Pattern mechanism to ease the specification and execution of musical
 * patterns.  Inspired by Smalltalk syntax.  An example pattern to play
 * four beats and repeat 2 times could be specified like this in StepTalk.
 *
 *   pat := Pattern alloc initWithName:'pat1'.
 *   pat
 *     sync: #beat;
 *     play: [ synth makeNote:64. ];
 *     sync: #beat;
 *     play: [ synth makeNote:60. ];
 *     sync: #beat;
 *     play: [ synth makeNote:60. ];
 *     sync: #beat;
 *     play: [ synth makeNote:60. ];
 *     repeat: 2.
 *
 * McLaren Labs 2024
 */

#import "Pattern.h"

@implementation Instruction
- (id) initWithKind:(InstructionKind)kind {
  if (self = [super init]) {
    _kind = kind;
  }
  return self;
}
@end

@implementation Sync
- (id) init {
  if (self = [super initWithKind:INSTRUCTION_KIND_SYNC]) {
  }
  return self;
}
@end

@implementation Ticks
- (id) init {
  if (self = [super initWithKind:INSTRUCTION_KIND_TICKS]) {
  }
  return self;
}
@end

@implementation Seconds
- (id) init {
  if (self = [super initWithKind:INSTRUCTION_KIND_SECONDS]) {
  }
  return self;
}
@end

@implementation Thunk
- (id) init {
  if (self = [super initWithKind:INSTRUCTION_KIND_THUNK]) {
  }
  return self;
}
@end

@implementation Frame
- (id) initWithPat:(Pattern*)pat andThreadId:(NSUInteger)threadId {
  if (self = [super init]) {
    _pat = pat;
    _ip = 0;
    _repeatCount = pat.repeatSpec; // how many times
    _threadId = threadId;
  }
  return self;
}

- (BOOL) incrIP {

  _ip++;
  
  if (_ip >= [_pat.instructions count]) {
    if (_repeatCount > 0) {
      _repeatCount--;
      if (_repeatCount == 0) {
	return NO;	// is dead
      }
      else {
	// _ip = 0;	// goto beginning
	_ip = _pat.introEndsAt;	// go to end of intro
	return YES;	// more to come
      }
    }
    else {
      // repeat count is not 0
      // return YES;
      return NO;	// is dead
    }
  }
  else {
    // nothing
    return YES;
  }
}


@end

@implementation Pattern

- (id) initWithName:(NSString*)name {
  if (self = [super initWithKind:INSTRUCTION_KIND_PAT]) {

    _patname = name;
    _instructions = [[NSMutableArray alloc] init];
				// _repeatSpec = -1; // plays through once
    _repeatSpec = 1;		// plays through once
    _introEndsAt = 0;		// where the intro section ends
  }
  return self;
}

- (void) sync:(NSString*)waitchan {
  Sync *s = [[Sync alloc] init];
  s.chan = waitchan;
  [_instructions addObject:s];
}

- (void) ticks:(long)ticks {
  Ticks *t = [[Ticks alloc] init];
  t.ticks = ticks;
  [_instructions addObject:t];
}

- (void) seconds:(double)sec {
  unsigned tv_sec = trunc(sec);
  unsigned tv_nsec = (sec - tv_sec) * 1000000000;
  Seconds *s = [[Seconds alloc] init];
  s.sec = tv_sec;
  s.nsec = tv_nsec;
  [_instructions addObject:s];
}

- (void) thunk:(MLThunkBlock)thunk {
  Thunk *t = [[Thunk alloc] init];
  t.thunkblock = thunk;
  [_instructions addObject:t];
}

- (void) pat:(Pattern*)pat {
  [_instructions addObject:pat];
}

- (void) repeat:(NSInteger)repeatSpec {
  _repeatSpec = repeatSpec;
}

- (void) intro {
  _introEndsAt = [_instructions count]; // mark current position as end of intro
}

- (NSString*)description {
  NSMutableString *s = [NSMutableString stringWithFormat:@"pat:%@<%ld>\n", _patname, _repeatSpec];
  [s appendString:[_instructions description]];
  return s;
}

@end

@implementation Thread

- (id) initWithThreadId:(NSUInteger)threadId {
  if (self = [super init]) {
    _threadId = threadId;
    _stack = [[NSMutableArray alloc] init];

    _isTickTime = YES;
    _ticktime = -1;
  }
  return self;
}

- (void) push:(Pattern*)pat {
  Frame *frame = [[Frame alloc] initWithPat:pat andThreadId:_threadId];
  [_stack addObject:frame];
}

- (Frame*) pop {
  Frame *frame = [_stack lastObject];
  [_stack removeLastObject];
  return frame;
}

- (Frame*) currentFrame {
  return [_stack lastObject];
}

- (NSString*) currentPatName {
  Frame *frame = [self currentFrame];
  if (frame == nil) {
    return @"thread-exited";
  }
  else {
    return frame.pat.patname;
  }
}

- (BOOL) hasSeenTick:(unsigned) ticktime {
  // then last time was a tick
  if (_isTickTime) {
    if (_ticktime >= ticktime)
      return YES;
    else
      return NO;
  }
  else {
    return NO;
  }
}

// NOTE: this is an old version that is not right
- (id) XXgetNextInstruction
{
  Frame *frame;
  Instruction *instruction;

  frame = [self currentFrame];
  
  if (frame.ip < [frame.pat.instructions count]) {
    instruction = frame.pat.instructions[frame.ip];

    BOOL isStillAlive = [frame incrIP];
    if (isStillAlive == NO) {
      Frame *deadFrame = [self pop];
      (void) deadFrame;
    }
  }    
  else {
    instruction = nil;
  }

  return instruction;
}

- (id) getNextInstruction
{
  Frame *frame;
  Instruction *instruction;

  frame = [self currentFrame];
  
  if (frame != nil) {
    // IP starts off valid and is always valid before incrIP
    instruction = frame.pat.instructions[frame.ip];

    BOOL isStillAlive = [frame incrIP];
    if (isStillAlive == NO) {
      Frame *deadFrame = [self pop];
      (void) deadFrame;
    }
  }    
  else {
    instruction = nil;
  }

  return instruction;
}

- (void) interpret:(Scheduler*)scheduler ticktime:(long)ticktime
{
  // set current time
  _isTickTime = YES;
  _ticktime = ticktime;

  [self _doInterpret:scheduler];
}

- (void) interpret:(Scheduler*)scheduler sec:(unsigned)sec nsec:(unsigned)nsec {
  // set current time
  _isTickTime = NO;
  _sec = sec;
  _nsec = nsec;

  [self _doInterpret:scheduler];
}

- (NSString*) _getTime {
  if (_isTickTime == YES) {
    return [NSString stringWithFormat:@"%ld", _ticktime];
  }
  else {
    double real = _sec + (_nsec / 1000000000.0);
    return [NSString stringWithFormat:@"%5.2f", real];
  }
}

- (void) _doInterpret:(Scheduler*)scheduler {

  BOOL done = NO;
  while (done == NO) {

    Instruction *instruction = [self getNextInstruction];

    // for Debugging
    // NSLog(@"(%@)interpret: %@", [self _getTime], instruction);

    if (instruction == nil) {
      done = YES;
    }
    else {

      switch (instruction.kind) {
      case INSTRUCTION_KIND_NONE:
	break;

      case INSTRUCTION_KIND_SYNC:
	{
	  Sync *sync = (Sync*)instruction;
	  NSString *chan = sync.chan;

	  [scheduler syncOn:chan thread:self];
	  done = YES; // this thread is blocked
	}
	break;

      case INSTRUCTION_KIND_TICKS:
	{
	  Ticks *sleep = (Ticks*)instruction;
	  long ticks = sleep.ticks;
	  [scheduler sleepFor:ticks thread:self];
	  done = YES; // this thread is blocked
	}
	break;
	
      case INSTRUCTION_KIND_SECONDS:
	{
	  Seconds *sleep = (Seconds*)instruction;
	  unsigned tv_sec = sleep.sec;
	  unsigned tv_nsec = sleep.nsec;
	  [scheduler sleepFor:tv_sec nsec:tv_nsec thread:self];
	  done = YES; // this thread is blocked
	}
	break;
	
      case INSTRUCTION_KIND_THUNK:
	{
	  Thunk *thunk = (Thunk*)instruction;
	  thunk.thunkblock();
	}
	break;

      case INSTRUCTION_KIND_STBLOCK:
	// STBlock *block = (STBlock*)instruction;
	// id val = [block value:nil];
	break;

      case INSTRUCTION_KIND_PAT:
	{
	  Pattern *pat = (Pattern*)instruction;
	  [self push:pat];
	}
	break;

      default:
	NSLog(@"Unrecognized instruction:%@", instruction);
	exit(1);
      }
    }
  }
}

- (NSString*) description {
  if (_isTickTime == YES) {
    return [NSString stringWithFormat:@"<Thread:%lu tick:%ld>",
		     _threadId, _ticktime];
  }
  else {
    double real = _sec + (_nsec / 1000000000.0);
    return [NSString stringWithFormat:@"<Thread:%lu real:%5.2f>",
		     _threadId, real];
  }
} 
@end
  

@implementation Scheduler

- (id) init {
  if (self = [super init]) {
    _waiters = [[NSMutableDictionary alloc] init];
    _sleepers = [[NSMutableDictionary alloc] init];
    _launchSpec = [[NSMutableArray alloc] init];

    _sleepIdCntr = 0;
    _threadIdCntr = 0;

    _log = YES;

    _isTickTime = YES;
    _ticktime = -1;
    _sec = 0;
    _nsec = 0;
  }
  return self;
}

- (void) reset {
  _waiters = [[NSMutableDictionary alloc] init];
  _sleepers = [[NSMutableDictionary alloc] init];

  _isTickTime = YES;
  _ticktime = -1;
  _sec = 0;
  _nsec = 0;
}


- (void) addWaiter:(NSString*)chan obj:(Thread*)what
{
  NSMutableArray *waitlist = _waiters[chan];
  if (waitlist == nil) {
    waitlist = [[NSMutableArray alloc] init];
    [waitlist addObject:what];
    _waiters[chan] = waitlist;
  }
  else {
    [waitlist addObject:what];
  }
}

- (void) addSleeper:(NSNumber*)sleepId obj:(Thread*)what
{
  _sleepers[sleepId] = what;
}

- (NSMutableArray*) removeWaiters:(NSString*)chan ticktime:(unsigned)ticktime
{
  NSMutableArray *waitlist = _waiters[chan];

  // filter into two groups: those that are not yet at ticktime
  // and those that already are because of a simultaneous event at ticktime
  NSMutableArray *anxiousWaiters = [[NSMutableArray alloc] init];
  NSMutableArray *servicedWaiters = [[NSMutableArray alloc] init];

  for (Thread *t in waitlist) {
    if ([t hasSeenTick:ticktime]) {
      // NSLog(@"HAS SEEN SEVICED WAITER:%@", t);
      [servicedWaiters addObject:t];
    }
    else {
      [anxiousWaiters addObject:t];
    }
  }

  if ([servicedWaiters count] == 0) {
    // there are no waiters for this channel in the future
    [_waiters removeObjectForKey:chan];
  }
  else {
    _waiters[chan] = servicedWaiters;
  }

  return anxiousWaiters; // anxious to get interpreted!
}

- (void) wakeFor:(NSString*)chan ticktime:(unsigned)ticktime
{
  NSMutableArray *waiters = [self removeWaiters:chan ticktime:ticktime];
  if (waiters != nil) {
    for (Thread *t in waiters) {

      if (_log)
	[self logger:[self fmtTime] pat:[t currentPatName] msg:[NSString stringWithFormat:@"#%@", chan]];

      // execute each thread until their next sync/sleep
      _currentThreadId = t.threadId;
      [t interpret:self ticktime:ticktime];
    }
  }
}

// for a pattern to put itself to sleep
- (void) syncOn:(NSString*)chan thread:(Thread*)thread {
  [self addWaiter:chan obj:thread];
}

- (void) wakeSleeper:(long)sleepNum ticktime:(unsigned)ticktime {
  NSNumber *sleepId = [NSNumber numberWithLong:sleepNum];
  Thread *t = _sleepers[sleepId];
  if (t) {
    if (_log)
      [self logger:[self fmtTime] pat:[t currentPatName] msg:@"ticks"];

    [_sleepers removeObjectForKey:sleepId];
     _currentThreadId = t.threadId;
    [t interpret:self ticktime:ticktime];
  }
}
    

- (void) wakeSleeper:(long)sleepNum sec:(unsigned)sec nsec:(unsigned)nsec {
  NSNumber *sleepId = [NSNumber numberWithLong:sleepNum];
  Thread *t = _sleepers[sleepId];
  if (t) {
    if (_log)
      [self logger:[self fmtTime] pat:[t currentPatName] msg:@"seconds"];

    [_sleepers removeObjectForKey:sleepId];
    _currentThreadId = t.threadId;
    [t interpret:self sec:sec nsec:nsec];
  }
}
    

- (NSNumber*) _makeSleepId {
  NSNumber *sleepId = [NSNumber numberWithLong: _sleepIdCntr++];
  return sleepId;
}

// for a thread to put itself to sleep
- (void) sleepFor:(NSUInteger)ticks thread:(Thread*)thread {

  NSNumber *sleepId = [self _makeSleepId];
  // NSLog(@"SLEEPTICKS ID:%ld ticks:%ld", [sleepId longValue], ticks);
  [_metro scheduleUsr3Relative:ticks d0:[sleepId longValue] d1:0 d2:0];

  [self addSleeper:sleepId obj:thread];
}

// for a thread to put itself to sleep
- (void) sleepFor:(unsigned)sec nsec:(unsigned)nsec thread:(Thread*)thread {

  NSNumber *sleepId = [self _makeSleepId];
  // NSLog(@"SLEEPREAL ID:%ld secs:%u,%u", [sleepId longValue], sec, nsec);
  [_metro scheduleUsr4Relative:sec nsec:nsec d0:[sleepId longValue] d1:0 d2:0];

  [self addSleeper:sleepId obj:thread];
}

/*
 * Link this scheduler to the metronome for control and timing services.
 */
- (void) registerMetronome:(MSKMetronome*)metro {

  _metro = metro;

  [_metro onBeat:^(unsigned ticktime, int beat, int measure) {
      // NSLog(@"METRO ON BEAT");
      _isTickTime = YES;
      _ticktime = ticktime;
      _beat = beat;
      _measure = measure;
      if (beat == 0) {
	[self wakeFor:@"downbeat" ticktime:ticktime];
      }
      [self wakeFor:@"beat" ticktime:ticktime];
    }];

  [_metro onClock:^(unsigned ticktime, int clock, int beat, int measure) {
      // NSLog(@"METRO ON CLOCK");
      _isTickTime = YES;
      _ticktime = ticktime;
      _beat = beat;
      _measure = measure;
      [self wakeFor:@"clock" ticktime:ticktime];
    }];

  [_metro onUsr3:^(unsigned ticktime, uint32_t d0, uint32_t d1, uint32_t d2) {
      // NSLog(@"METRO USR3");
      _isTickTime = YES;
      _ticktime = ticktime;
      [self wakeSleeper:d0 ticktime:ticktime];
    }];

  [_metro onUsr4:^(int sec, int nsec, uint32_t d0, uint32_t d1, uint32_t d2) {
      // NSLog(@"METRO USR4 %d/%d", sec, nsec);
      _isTickTime = NO;
      _sec = sec;
      _nsec = nsec;
      [self wakeSleeper:d0 sec:sec nsec:nsec];
    }];

  [_metro onStart:^{
      // NSLog(@"METRO ON START");
      [self reset]; // clear wait tables
      [self launchAll]; // run each thread until it blocks
    }];
  
  [_metro onStop:^{
    }];
}

/*
 * Start all threads from the beginning and run each until their first block.
 */
- (void) launchAll {
  for (Pattern *p in _launchSpec) {
    NSLog(@"launch:%@", p);
    Thread *t = [[Thread alloc] initWithThreadId: _threadIdCntr++];
    [t push:p];
    _currentThreadId = t.threadId;
    [t interpret:self ticktime:-1]; // BEAT 0 is at 0
  }
}

/*
 * Add a pattern to the auto-launcher
 */
- (void) addLaunch:(Pattern*)pat {
  [_launchSpec addObject:pat];
}

- (NSString*) fmtTime {
  NSString *s;
  if (_isTickTime) {
    s = [NSString stringWithFormat:@"%7ld %4d.%1d", _ticktime, _measure, _beat];
  }
  else {
    // double real = _sec + (_nsec / 1000000000.0);
    int msec = _nsec / 1000000;
    s = [NSString stringWithFormat:@"%3d.%03d %4d.%1d", _sec, msec, _measure, _beat];
  }
  return s;
}

- (void) logger:(NSString*)fmtTime pat:(NSString*)patname msg:(NSString*)msg {
  NSLog(@"%@ %@ %@", fmtTime, patname, msg);
}


- (NSString*) description {

  NSMutableString *s = [NSMutableString stringWithFormat:@"SCHEDULER:(%@)\n",
					[self fmtTime]];
  [s appendString:[_waiters description]];
  [s appendString:@"\n"];
  [s appendString:[_sleepers description]];
  [s appendString:@"\n"];
  return s;

}


@end



