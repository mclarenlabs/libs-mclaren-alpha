/** -*- mode:objc -*-
 *
 * A Pattern is a sequence of instructions that are performed
 * at programmable times or by syncing with programmable events.
 *
 * A Liveloop is a pattern that is started over, potentially forever.
 *
 * This header file includes declarations that are used internally by
 * the Pattern package, as well as declarations that are intended to
 * be used by the user.  To aid in understanding the intent, we have
 * marked classes and methods as INTERNAL or USER.
 *
 * Properties are generally intended for internal use.
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

typedef NS_ENUM(NSInteger, MSKInstructionKind) {
  MSK_INSTRUCTION_KIND_NONE,
    MSK_INSTRUCTION_KIND_SYNC,
    MSK_INSTRUCTION_KIND_TICKS,
    MSK_INSTRUCTION_KIND_SECONDS,
    MSK_INSTRUCTION_KIND_THUNK,
    MSK_INSTRUCTION_KIND_STBLOCK,
    MSK_INSTRUCTION_KIND_PAT,
};

/*
 * INTERNAL: Instruction, Sync, Ticks, Seconds, Thunk
 *
 * Each element in a Pattern is an Instruction
 */

@interface MSKInstruction : NSObject
@property (readonly) NSUInteger kind;
- (id) initWithKind:(MSKInstructionKind)kind;

- (BOOL) isTimeConsuming; // YES if instruction can BLOCK in the scheduler
@end

@interface MSKSync : MSKInstruction
@property NSString *chan;	// the wait channel
@end

@interface MSKTicks : MSKInstruction
@property long ticks;		// MIDI ticks to sleep
@end

@interface MSKSeconds : MSKInstruction
@property unsigned sec;		// realtime sec/nsec to sleep
@property unsigned nsec;
@end

typedef void (^MSKThunkBlock)();

@interface MSKThunk : MSKInstruction
@property (readwrite, copy) MSKThunkBlock thunkblock;
@end

/*
 * USER: Pattern
 *
 * A pattern is a list of instructions executed in a pseudo-thread.  Some
 * instructions pause the thread or synchronize with an event,
 * other instructions simply execute code.  A pattern can also repeat.
 */

@interface MSKPattern : MSKInstruction

@property (readonly) NSString *patname;
@property (readonly) NSMutableArray<MSKInstruction*> *instructions;
@property (readonly) NSInteger introEndsAt;
@property (readonly) NSInteger repeatSpec; // -1 or num

- (id) init __attribute__((unavailable("This method is not available.  Please use initWithName:")));

- (id) initWithName:(NSString*)name;
- (void) sync:(NSString*)waitchan;		// sync with channel name
- (void) ticks:(long)ticks;			// sleep for MIDI ticks
- (void) seconds:(double)seconds;		// sleep for seconds
- (void) thunk:(MSKThunkBlock)thunk;		// execute thunk
// - (void) play:(id)block;			// execute STBlock
- (void) pat:(MSKPattern*)pat;			// invoke sub-pattern
- (void) intro;					// mark end of intro section
- (void) repeat:(NSInteger)repeatSpec;

@end

/*
 * INTERNAL: Frame
 *
 * A stack frame records the current state of execution of a pattern.
 * Each thread maintains a stack of frames.
 */

@interface MSKFrame : NSObject
@property (readonly) MSKPattern* pat; // pattern under execution
@property (readonly) NSInteger ip; // current instruction pointer
@property (readonly) NSInteger repeatCount;
@property (readonly) NSUInteger threadId;

- (id) init __attribute__((unavailable("This method is not available.  Please use initWithPat:andThreadId")));
- (id) initWithPat:(MSKPattern*)pat andThreadId:(NSUInteger)threadId;
@end

/*
 * USER: Scheduler
 *
 * The Scheduler responds to callbacks from the Metronome to move
 * execution forward for a number of threads.  Threads execute
 * Patterns.  When a Pattern reaches an instruction that blocks,
 * its current thread is suspended and the thread is added to one
 * of the suspension tables: either "waiters" or "sleepers".
 */

@class MSKThread;
@class MSKLiveloop;

@interface MSKScheduler : NSObject
@property (readonly) __weak MSKMetronome *metro;
@property (readonly) NSMutableDictionary *waiters;
@property (readonly) NSMutableDictionary *sleepers;
@property (readonly) long sleepIdCntr; // unique sleep id counter
@property (readonly) long threadIdCntr; // unique thread id counter

// keeping track of currently executing thread
@property (readonly) long currentThreadId;

// user: turn on or off logging
@property (readwrite) BOOL log;

// keeping track of current time
@property (readonly) BOOL isTickTime; // ticktime or realtime
@property (readonly) long ticktime;   // MIDI ticks, -1 is not yet
@property (readonly) unsigned sec;    // seconds
@property (readonly) unsigned nsec;   // nanosec

@property (readonly) int measure;     // from metronome
@property (readonly) int beat;	      // from metronome

- (id) init;
- (void) reset;

// internal: utilities for managing wait tables
- (void) addWaiter:(NSString*)chan obj:(MSKThread*)what;
- (void) addSleeper:(NSNumber*)sleepId obj:(MSKThread*)what;
- (NSMutableArray*) removeWaiters:(NSString*)chan ticktime:(unsigned)ticktime;

// internal: what patterns use to suspend themselves
- (void) syncOn:(NSString*)chan thread:(MSKThread*)thread;
- (void) sleepFor:(NSUInteger)ticks thread:(MSKThread*)thread; // called by pat
- (void) sleepFor:(unsigned)sec nsec:(unsigned)nsec thread:(MSKThread*)thread;

// internal: what the scheduler uses to resume threads
- (void) wakeFor:(NSString*)chan ticktime:(unsigned)ticktime; // on beat
- (void) wakeSleeper:(long)sleepNum ticktime:(unsigned)ticktime; // on USR3
- (void) wakeSleeper:(long)sleepNum sec:(unsigned)sec nsec:(unsigned)nsec; // USR4

// user: obtain start/stop and timing services
- (void) registerMetronome:(MSKMetronome*)metro;

/*
 * Methods for managing the launching of patterns
 */
@property (readonly) NSMutableArray<MSKPattern*> *launchSpec;

// user: select a pattern for starting when the metronome starts
- (void) addLaunch:(MSKPattern*)pat;

// user: independently launch a pattern in a new thread
- (void) launch:(MSKPattern*)pat;

/*
 * Methods for managing Liveloops
 */
@property (readonly) NSMutableDictionary<NSString*, MSKLiveloop*> *liveloopSpec;

// user: set or reset the pattern in a named liveloop
- (void) setLiveloop:(NSString*)name pat:(MSKPattern*)pat;

// user: disable a running liveloop
- (BOOL) disableLiveloop:(NSString*)name;

// user: reenable a liveloop and get it running if need be
- (BOOL) enableLiveloop:(NSString*)name;

/*
 * Utilities for logging and printing
 */

// utility - current time of scheduler formatted for printing
- (NSString*) fmtTime;

// what the scheduler calls to log.  Can be overridden in subclass to redirect
- (void) logger:(NSString*)fmtTime pat:(NSString*)patname msg:(NSString*)msg;

@end

/*
 * INTERNAL: Thread
 *
 * A Thead executes a sequence of instructions in a Pattern.
 * The Thread keeps a stack of frames for nested Patterns.
 * Each thread sets its current time when it is awoken.
 *
 * The scheduler ensures that a thread is not executed more than
 * once for a given 'ticktime'.
 */

@interface MSKThread : NSObject
@property (readonly) NSUInteger threadId;
@property (readonly) NSMutableArray<MSKFrame*> *stack;

// keeping track of time
@property (readonly) BOOL isTickTime; // ticktime or realtime
@property (readonly) long ticktime;   // MIDI ticks, -1 is not yet
@property (readonly) unsigned sec;    // seconds
@property (readonly) unsigned nsec;   // nanosec

// live loops
@property (readonly) BOOL isLiveloop; // if this thread repeats
@property (readonly) NSString *liveloopName; // name it looks up its replenishment


- (id) initWithThreadId:(NSUInteger)threadId;
- (id) initLiveloopWithThreadId:(NSUInteger)threadId andName:(NSString*)name;
- (void) push:(MSKPattern*)pat;
- (MSKFrame*) pop;
- (MSKFrame*) currentFrame;
- (NSString*) currentPatName; // internal use

// if this thread has already awoken at ticktime
- (BOOL) hasSeenTick:(unsigned)ticktime;

 // evaluate instructions at current time until suspended
- (void) interpret:(MSKScheduler*)scheduler ticktime:(long)ticktime;
- (void) interpret:(MSKScheduler*)scheduler sec:(unsigned)sec nsec:(unsigned)nsec;

// internal use only
- (BOOL) _doInterpret:(MSKScheduler*)scheduler;
@end


/*
 * INTERNAL: Livelooop
 *
 * A Liveloop is a Pattern that is automatically restarted when it ends.
 *
 * When a Thread is executing a Pattern from a Liveloop, when the Pattern exits
 * the Thread looks to see if the Pattern should be restarted.  This is called
 * "replenishing" the thread.
 */

@interface MSKLiveloop : NSObject
@property (readwrite) MSKPattern *pat;
@property (readwrite) BOOL isEnabled;
@property (readwrite) BOOL isRunning;

- (id) init __attribute__((unavailable("This method is not available.  Please use initWithPattern:")));

- (id) initWithPattern:(MSKPattern*)pat;

- (MSKPattern*) replenishOrStop;

@end

