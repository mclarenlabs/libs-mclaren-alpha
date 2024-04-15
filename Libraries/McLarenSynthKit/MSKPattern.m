/** -*- mode: objc -*-
 *
 * A Pattern mechanism to ease the specification and execution of musical
 * patterns.  Inspired by Smalltalk syntax.  An example pattern to play
 * four beats and repeat 2 times could be specified like this in StepTalk.
 *
 *   pat := MSKPattern alloc initWithName:'pat1'.
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

#import "MSKPattern.h"

@implementation MSKInstruction
- (id) initWithKind:(MSKInstructionKind)kind {
  if (self = [super init]) {
    _kind = kind;
  }
  return self;
}

- (BOOL) isTimeConsuming {
  [self doesNotRecognizeSelector: _cmd];
  return NO;
}

@end

@implementation MSKSync
- (id) init {
  if (self = [super initWithKind:MSK_INSTRUCTION_KIND_SYNC]) {
  }
  return self;
}

- (BOOL) isTimeConsuming {
  return YES;
}
@end

@implementation MSKTicks
- (id) init {
  if (self = [super initWithKind:MSK_INSTRUCTION_KIND_TICKS]) {
  }
  return self;
}

- (BOOL) isTimeConsuming {
  return YES;
}
@end

@implementation MSKSeconds
- (id) init {
  if (self = [super initWithKind:MSK_INSTRUCTION_KIND_SECONDS]) {
  }
  return self;
}

- (BOOL) isTimeConsuming {
  return YES;
}
@end

@implementation MSKThunk
- (id) init {
  if (self = [super initWithKind:MSK_INSTRUCTION_KIND_THUNK]) {
  }
  return self;
}

- (BOOL) isTimeConsuming {
  return NO;
}
@end

@implementation MSKFrame
- (id) initWithPat:(MSKPattern*)pat andThreadId:(NSUInteger)threadId {
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

@implementation MSKPattern

- (id) initWithName:(NSString*)name {
  if (self = [super initWithKind:MSK_INSTRUCTION_KIND_PAT]) {

    _patname = name;
    _instructions = [[NSMutableArray alloc] init];
				// _repeatSpec = -1; // plays through once
    _repeatSpec = 1;		// plays through once
    _introEndsAt = 0;		// where the intro section ends
  }
  return self;
}

- (void) sync:(NSString*)waitchan {
  MSKSync *s = [[MSKSync alloc] init];
  s.chan = waitchan;
  [_instructions addObject:s];
}

- (void) ticks:(long)ticks {
  MSKTicks *t = [[MSKTicks alloc] init];
  t.ticks = ticks;
  [_instructions addObject:t];
}

- (void) seconds:(double)sec {
  unsigned tv_sec = trunc(sec);
  unsigned tv_nsec = (sec - tv_sec) * 1000000000;
  MSKSeconds *s = [[MSKSeconds alloc] init];
  s.sec = tv_sec;
  s.nsec = tv_nsec;
  [_instructions addObject:s];
}

- (void) thunk:(MSKThunkBlock)thunk {
  MSKThunk *t = [[MSKThunk alloc] init];
  t.thunkblock = thunk;
  [_instructions addObject:t];
}

- (void) pat:(MSKPattern*)pat {
  [_instructions addObject:pat];
}

- (void) repeat:(NSInteger)repeatSpec {
  _repeatSpec = repeatSpec;
}

- (void) intro {
  _introEndsAt = [_instructions count]; // mark current position as end of intro
}

// a pattern is time-consuming if any of its instructions is time-consuming
- (BOOL) isTimeConsuming {
  BOOL res = NO;
  for (MSKPattern *p in _instructions) {
    if ([p isTimeConsuming] == YES) {
	res = YES;
      }
  }
  return res;
}

- (NSString*)description {
  NSMutableString *s = [NSMutableString stringWithFormat:@"pat:%@<%ld>\n", _patname, _repeatSpec];
  [s appendString:[_instructions description]];
  return s;
}

@end

@implementation MSKThread

- (id) initWithThreadId:(NSUInteger)threadId {
  if (self = [super init]) {
    _threadId = threadId;
    _stack = [[NSMutableArray alloc] init];

    _isTickTime = YES;
    _ticktime = -1;

    // liveloop
    _isLiveloop = NO;
  }
  return self;
}

- (id) initLiveloopWithThreadId:(NSUInteger)threadId andName:(NSString*)name {
  if (self = [super init]) {
    _threadId = threadId;
    _stack = [[NSMutableArray alloc] init];

    _isTickTime = YES;
    _ticktime = -1;

    // liveloop
    _isLiveloop = YES;
    _liveloopName = name;
  }
  return self;
}

- (void) push:(MSKPattern*)pat {
  MSKFrame *frame = [[MSKFrame alloc] initWithPat:pat andThreadId:_threadId];
  [_stack addObject:frame];
}

- (MSKFrame*) pop {
  MSKFrame *frame = [_stack lastObject];
  [_stack removeLastObject];
  return frame;
}

- (MSKFrame*) currentFrame {
  return [_stack lastObject];
}

- (NSString*) currentPatName {
  MSKFrame *frame = [self currentFrame];
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
  MSKFrame *frame;
  MSKInstruction *instruction;

  frame = [self currentFrame];
  
  if (frame.ip < [frame.pat.instructions count]) {
    instruction = frame.pat.instructions[frame.ip];

    BOOL isStillAlive = [frame incrIP];
    if (isStillAlive == NO) {
      MSKFrame *deadFrame = [self pop];
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
  MSKFrame *frame;
  MSKInstruction *instruction;

  frame = [self currentFrame];
  
  if (frame != nil) {
    // IP starts off valid and is always valid before incrIP
    instruction = frame.pat.instructions[frame.ip];

    BOOL isStillAlive = [frame incrIP];
    if (isStillAlive == NO) {
      MSKFrame *deadFrame = [self pop];
      (void) deadFrame;
    }
  }    
  else {
    instruction = nil;
  }

  return instruction;
}

- (void) interpret:(MSKScheduler*)scheduler ticktime:(long)ticktime
{
  // set current time
  _isTickTime = YES;
  _ticktime = ticktime;

  BOOL res = [self _doInterpret:scheduler];
  if (res == NO) {
    if (_isLiveloop == NO) {
      NSLog(@"thread exited");
    }
    else {
      // replenish the thread with the pat if there is one
      if (scheduler.log) {
	NSLog(@"looping:%@", _liveloopName);
      }
      // MSKPattern *p = scheduler.liveloopSpec[_liveloopName];
      MSKLiveloop *loop = scheduler.liveloopSpec[_liveloopName];
      MSKPattern *p = [loop replenishOrStop];
      if (p != nil) {
	[self push:p];
	[self interpret:scheduler ticktime:ticktime];
      }
    }
  }
}

- (void) interpret:(MSKScheduler*)scheduler sec:(unsigned)sec nsec:(unsigned)nsec {
  // set current time
  _isTickTime = NO;
  _sec = sec;
  _nsec = nsec;

  BOOL res = [self _doInterpret:scheduler];
  if (res == NO) {
    if (_isLiveloop == NO) {
      NSLog(@"thread exited");
    }
    else {
      // replenish the thread with the pat if there is one
      NSLog(@"looping:%@", _liveloopName);
      // MSKPattern *p = scheduler.liveloopSpec[_liveloopName];
      MSKLiveloop *loop = scheduler.liveloopSpec[_liveloopName];
      MSKPattern *p = [loop replenishOrStop];
      if (p != nil) {
	[self push:p];
	[self interpret:scheduler sec:sec nsec:nsec];
      }
    }
  }
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

- (BOOL) _doInterpret:(MSKScheduler*)scheduler {

  BOOL done = NO;
  while (done == NO) {

    MSKInstruction *instruction = [self getNextInstruction];

    // for Debugging
    // NSLog(@"(%@)interpret: %@", [self _getTime], instruction);

    if (instruction == nil) {
      // done = YES;
      return NO; // thread exited
    }
    else {

      switch (instruction.kind) {
      case MSK_INSTRUCTION_KIND_NONE:
	break;

      case MSK_INSTRUCTION_KIND_SYNC:
	{
	  MSKSync *sync = (MSKSync*)instruction;
	  NSString *chan = sync.chan;

	  [scheduler syncOn:chan thread:self];
	  done = YES; // this thread is blocked
	}
	break;

      case MSK_INSTRUCTION_KIND_TICKS:
	{
	  MSKTicks *sleep = (MSKTicks*)instruction;
	  long ticks = sleep.ticks;
	  [scheduler sleepFor:ticks thread:self];
	  done = YES; // this thread is blocked
	}
	break;
	
      case MSK_INSTRUCTION_KIND_SECONDS:
	{
	  MSKSeconds *sleep = (MSKSeconds*)instruction;
	  unsigned tv_sec = sleep.sec;
	  unsigned tv_nsec = sleep.nsec;
	  [scheduler sleepFor:tv_sec nsec:tv_nsec thread:self];
	  done = YES; // this thread is blocked
	}
	break;
	
      case MSK_INSTRUCTION_KIND_THUNK:
	{
	  MSKThunk *thunk = (MSKThunk*)instruction;
	  thunk.thunkblock();
	}
	break;

      case MSK_INSTRUCTION_KIND_STBLOCK:
	// STBlock *block = (STBlock*)instruction;
	// id val = [block value:nil];
	break;

      case MSK_INSTRUCTION_KIND_PAT:
	{
	  MSKPattern *pat = (MSKPattern*)instruction;
	  [self push:pat];
	}
	break;

      default:
	NSLog(@"Unrecognized instruction:%@", instruction);
	exit(1);
      }
    }
  }
  return YES; // thread is not dead
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
  

@implementation MSKScheduler

- (id) init {
  if (self = [super init]) {
    _waiters = [[NSMutableDictionary alloc] init];
    _sleepers = [[NSMutableDictionary alloc] init];
    _launchSpec = [[NSMutableArray alloc] init];
    _liveloopSpec = [[NSMutableDictionary alloc] init];

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


- (void) addWaiter:(NSString*)chan obj:(MSKThread*)what
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

- (void) addSleeper:(NSNumber*)sleepId obj:(MSKThread*)what
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

  for (MSKThread *t in waitlist) {
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
    for (MSKThread *t in waiters) {

      if (_log)
	[self logger:[self fmtTime] pat:[t currentPatName] msg:[NSString stringWithFormat:@"#%@", chan]];

      // execute each thread until their next sync/sleep
      _currentThreadId = t.threadId;
      [t interpret:self ticktime:ticktime];
    }
  }
}

// for a pattern to put itself to sleep
- (void) syncOn:(NSString*)chan thread:(MSKThread*)thread {
  [self addWaiter:chan obj:thread];
}

- (void) wakeSleeper:(long)sleepNum ticktime:(unsigned)ticktime {
  NSNumber *sleepId = [NSNumber numberWithLong:sleepNum];
  MSKThread *t = _sleepers[sleepId];
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
  MSKThread *t = _sleepers[sleepId];
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
- (void) sleepFor:(NSUInteger)ticks thread:(MSKThread*)thread {

  NSNumber *sleepId = [self _makeSleepId];
  // NSLog(@"SLEEPTICKS ID:%ld ticks:%ld", [sleepId longValue], ticks);
  [_metro scheduleUsr3Relative:ticks d0:[sleepId longValue] d1:0 d2:0];

  [self addSleeper:sleepId obj:thread];
}

// for a thread to put itself to sleep
- (void) sleepFor:(unsigned)sec nsec:(unsigned)nsec thread:(MSKThread*)thread {

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

  // launch plain patterns
  for (MSKPattern *p in _launchSpec) {
    NSLog(@"launch:%@", p);
    MSKThread *t = [[MSKThread alloc] initWithThreadId: _threadIdCntr++];
    [t push:p];
    _currentThreadId = t.threadId;
    [t interpret:self ticktime:-1]; // BEAT 0 is at 0
  }

  // launch liveloops
  for (NSString *name in _liveloopSpec) {
    // MSKPattern *p = _liveloopSpec[name];
    MSKLiveloop *loop = _liveloopSpec[name];
    loop.isRunning = YES;
    MSKPattern *p = loop.pat;
    MSKThread *t = [[MSKThread alloc] initLiveloopWithThreadId: _threadIdCntr++ andName:name];
    [t push:p];
    _currentThreadId = t.threadId;
    [t interpret:self ticktime:-1]; // BEAT 0 is at 0
  }
}

/*
 * Add a pattern to the auto-launcher
 */
- (void) addLaunch:(MSKPattern*)pat {
  [_launchSpec addObject:pat];
}

/*
 * Helper for launch - performed serially in Scheduler queue
 */

- (void) _launchHelper:(MSKPattern*)pat {
  MSKThread *t = [[MSKThread alloc] initWithThreadId: _threadIdCntr++];
  [t push:pat];
  _currentThreadId = t.threadId;

  // start interpreting at "current" time
  if (_isTickTime == YES) {
    NSLog(@"launching at ticktime:%ld", _ticktime);
    [t interpret:self ticktime:_ticktime];
  }
  else {
    NSLog(@"launching at sec:%d nsec:%d", _sec, _nsec);
    [t interpret:self sec:_sec nsec:_nsec];
  }
}
  
  
/*
 * Launch a pattern in a new thread ASAP
 */
- (void) launch:(MSKPattern*)pat {
  NSLog(@"launch:%@", pat);
  [self dispatchAsync:^{
      [self _launchHelper:pat];
    }];
}

/*
 * Set or replace named pattern in the liveloop dict
 */
- (void) setLiveloop:(NSString*)name pat:(MSKPattern*)pat
{
  if ([pat isTimeConsuming] == NO) {
    NSLog(@"Liveloop with pat:%@ will creat infinite loop since it is not time-consuming", pat.patname);
    exit(1);
  }
  
  MSKLiveloop *loop = _liveloopSpec[name];
  if (loop == nil) {
    MSKLiveloop *loop = [[MSKLiveloop alloc] initWithPattern:pat];
    [_liveloopSpec setObject:loop forKey:name];
  }
  else {
    loop.pat = pat;
  }
}

/*
 * Enable or Disable a liveloop
 */
- (BOOL) disableLiveloop:(NSString*)name {
  MSKLiveloop *loop = _liveloopSpec[name];
  if (loop != nil) {
    loop.isEnabled = NO; // will not be replenished
    return YES;
  }
  else {
    return NO;
  }
}

// internal helper - run on metronome queue
- (void) dispatchAsync:(void(^)())block {
  [_metro.seq dispatchAsync:block];
}

// internal helper - launch liveloop if needed
// performed on metro queue to avoid race condition

- (void) _launchIfNeeded:(NSString*)name liveloop:(MSKLiveloop*)loop {
  if (loop.isRunning == YES) {
    NSLog(@"loop is still running");
  }
  else {
    loop.isRunning = YES;
    MSKPattern *p = loop.pat;
    MSKThread *t = [[MSKThread alloc] initLiveloopWithThreadId: _threadIdCntr++ andName:name];
    [t push:p];
    _currentThreadId = t.threadId;

    // start interpreting at "current" time
    if (_isTickTime == YES) {
      NSLog(@"launching at ticktime:%ld", _ticktime);
      [t interpret:self ticktime:_ticktime];
    }
    else {
      NSLog(@"launching at sec:%d nsec:%d", _sec, _nsec);
      [t interpret:self sec:_sec nsec:_nsec];
    }
  }
}

- (BOOL) enableLiveloop:(NSString*)name {
  MSKLiveloop *loop = _liveloopSpec[name];
  if (loop != nil) {
    loop.isEnabled = YES;
    [self dispatchAsync:^{
	[self _launchIfNeeded:name liveloop:loop];
      }];
    return YES;
  }
  else {
    return NO;
  }
}

- (void) XXXsetLiveloopIsEnabled:(NSString*)name val:(BOOL)val {
  MSKLiveloop *loop = _liveloopSpec[name];
  if (loop) {
    if (loop.isRunning) {
      loop.isEnabled = val;
    }
    else {
      loop.isEnabled = val;
      if (val == YES) {
	// then we have to launch it in a new thread
	loop.isRunning = YES;
	MSKPattern *p = loop.pat;
	MSKThread *t = [[MSKThread alloc] initLiveloopWithThreadId: _threadIdCntr++ andName:name];
	[t push:p];
	_currentThreadId = t.threadId;

	// TOM: not clear this is the right way to launch pat
	dispatch_async([ASKSeq sharedQueue], ^{
	    [t interpret:self ticktime:-1]; // BEAT 0 is at 0
	  });
      }
    }
  }
  else {
    NSLog(@"Liveloop %@ is not found.", name);
  }
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

@implementation MSKLiveloop

- (id) initWithPattern:(MSKPattern*)pat {
  if (self = [super init]) {
    _pat = pat;
    _isEnabled = YES;
    _isRunning = NO;
  }
  return self;
}

- (MSKPattern*) replenishOrStop {
  if (_isEnabled) {
    return _pat;
  }
  else {
    _isRunning = NO;
    return nil;
  }
}

@end
