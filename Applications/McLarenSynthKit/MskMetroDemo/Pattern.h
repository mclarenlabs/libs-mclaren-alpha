/** -*- mode:objc -*-
 *
 * A Pattern is a sequence of instructions that are performed
 * at programmable times or by syncing with programmable events.
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

typedef NS_ENUM(NSInteger, InstructionKind) {
  INSTRUCTION_KIND_NONE,
    INSTRUCTION_KIND_SYNC,
    INSTRUCTION_KIND_TICKS,
    INSTRUCTION_KIND_SECONDS,
    INSTRUCTION_KIND_THUNK,
    INSTRUCTION_KIND_STBLOCK,
    INSTRUCTION_KIND_PAT,
};

// Each element in a Pattern is an Instruction
@interface Instruction : NSObject
@property (readonly) NSUInteger kind;
- (id) initWithKind:(InstructionKind)kind;
@end

@interface Sync : Instruction
@property NSString *chan;	// the wait channel
@end

@interface Ticks : Instruction
@property long ticks;		// MIDI ticks to sleep
@end

@interface Seconds : Instruction
@property unsigned sec;		// realtime sec/nsec to sleep
@property unsigned nsec;
@end

typedef void (^MLThunkBlock)();

@interface Thunk : Instruction
@property (readwrite, copy) MLThunkBlock thunkblock;
@end

/*
 * A pattern is a list of instructions executed in a pseudo-thread.  Some
 * instructions pause the thread or synchronize with an event,
 * other instructions simply execute code.  A pattern can also repeat.
 */

@interface Pattern : Instruction

@property (readonly) NSString *patname;
@property (readonly) NSMutableArray<Instruction*> *instructions;
@property (readonly) NSInteger introEndsAt;
@property (readonly) NSInteger repeatSpec; // -1 or num

- (id) init __attribute__((unavailable("This method is not available.  Please use initWithName:")));

- (id) initWithName:(NSString*)name;
- (void) sync:(NSString*)waitchan;		// sync with channel name
- (void) ticks:(long)ticks;			// sleep for MIDI ticks
- (void) seconds:(double)seconds;		// sleep for seconds
- (void) thunk:(MLThunkBlock)thunk;		// execute thunk
// - (void) play:(id)block;
- (void) pat:(Pattern*)pat;			// invoke sub-pattern
// - (void) spawn:(Pattern*)pat; // launch pat as a new thread
//- (void) repeat;
- (void) intro;					// mark end of intro section
- (void) repeat:(NSInteger)repeatSpec;

@end

/**
 * A stack frame records the current state of execution of a pattern.
 * Each thread maintains a stack of frames.
 */

@interface Frame : NSObject
@property (readonly) Pattern* pat; // pattern under execution
@property (readonly) NSInteger ip; // current instruction pointer
@property (readonly) NSInteger repeatCount;
@property (readonly) NSUInteger threadId;

- (id) init __attribute__((unavailable("This method is not available.  Please use initWithPat:andThreadId")));
- (id) initWithPat:(Pattern*)pat andThreadId:(NSUInteger)threadId;
@end

/**
 * The Scheduler responds to callbacks from the Metronome to move
 * execution forward for a number of threads.  Threads execute
 * Patterns.  When a Pattern reaches an instruction that blocks,
 * its current thread is suspended and the thread is added to one
 * of the suspension tables: either "waiters" or "sleepers".
 */

@class Thread;

@interface Scheduler : NSObject
@property (readonly) __weak MSKMetronome *metro;
@property (readonly) NSMutableDictionary *waiters;
@property (readonly) NSMutableDictionary *sleepers;
@property (readonly) long sleepIdCntr; // unique sleep id counter
@property (readonly) long threadIdCntr; // unique thread id counter

// keeping track of currently executing thread
@property (readonly) long currentThreadId;

// turn on or off logging
@property (readwrite) BOOL log;

// keeping track of current time
@property (readonly) BOOL isTickTime; // ticktime or realtime
@property (readonly) int measure;     // from metronome
@property (readonly) int beat;	      // from metronome
@property (readonly) long ticktime; // MIDI ticks, -1 is not yet
@property (readonly) unsigned sec; // seconds
@property (readonly) unsigned nsec; // nanosec

- (id) init;
- (void) reset;

// internal utilities for managing wait tables
- (void) addWaiter:(NSString*)chan obj:(Thread*)what;
- (void) addSleeper:(NSNumber*)sleepId obj:(Thread*)what;
- (NSMutableArray*) removeWaiters:(NSString*)chan ticktime:(unsigned)ticktime;

// what patterns use to suspend themselves
- (void) syncOn:(NSString*)chan thread:(Thread*)thread;
- (void) sleepFor:(NSUInteger)ticks thread:(Thread*)thread; // called by pat
- (void) sleepFor:(unsigned)sec nsec:(unsigned)nsec thread:(Thread*)thread;

// what the scheduler uses to resume threads
- (void) wakeFor:(NSString*)chan ticktime:(unsigned)ticktime; // on beat
- (void) wakeSleeper:(long)sleepNum ticktime:(unsigned)ticktime; // on USR3
- (void) wakeSleeper:(long)sleepNum sec:(unsigned)sec nsec:(unsigned)nsec; // USR4

// obtain start/stop and timing services
- (void) registerMetronome:(MSKMetronome*)metro;

// the launch list is what is started at Time 0
@property (readonly) NSMutableArray *launchSpec;
- (void) addLaunch:(Pattern*)pat;

// independent launching of a new thread
// - (void) launch:(Pattern*)pat;

// utility - current time of scheduler formatted for printing
- (NSString*) fmtTime;

// what the scheduler calls to log.  Can be overridden in subclass to redirect
- (void) logger:(NSString*)fmtTime pat:(NSString*)patname msg:(NSString*)msg;

@end

/*
 * A Thead executes a sequence of instructions in a Pattern.
 * The Thread keeps a stack of frames for nested Patterns.
 * Each thread sets its current time when it is awoken.
 *
 * The scheduler ensures that a thread is not executed more than
 * once for a given 'ticktime'.
 */

@interface Thread : NSObject
@property (readonly) NSUInteger threadId;
@property (readonly) NSMutableArray<Frame*> *stack;

// keeping track of time
@property (readonly) BOOL isTickTime; // ticktime or realtime
@property (readonly) long ticktime;   // MIDI ticks, -1 is not yet
@property (readonly) unsigned sec;    // seconds
@property (readonly) unsigned nsec;   // nanosec


- (id) initWithThreadId:(NSUInteger)threadId;
- (void) push:(Pattern*)pat;
- (Frame*) pop;
- (Frame*) currentFrame;
- (NSString*) currentPatName; // internal use

// if this thread has already awoken at ticktime
- (BOOL) hasSeenTick:(unsigned)ticktime;

 // evaluate instructions at current time until suspended
- (void) interpret:(Scheduler*)scheduler ticktime:(long)ticktime;
- (void) interpret:(Scheduler*)scheduler sec:(unsigned)sec nsec:(unsigned)nsec;

// internal use only
- (void) _doInterpret:(Scheduler*)scheduler;
@end



