/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * ALSA Metronome
 *
 * The metronome widget provides a time base.  It uses the ALSA
 * Sequencer interface to generate high resolution events.  It accepts
 * control via methods, and also start/stop/continue events via its
 * ALSA control port.
 * 
 * The metronome references an ASKSeq with a first port for sending note
 * events and receiving MIDI start/stop/continue events.  It allocates a
 * second port for sending itself internal timing events.
 *
 * (c) McLaren Labs 2019
 *
 */

#import "AlsaSoundKit/ASKSeq.h"

typedef void (^MSKMetronomeBeatListener)(unsigned ticktime, int beat, int measure);
typedef void (^MSKMetronomeClockListener)(unsigned ticktime, int clock, int beat, int measure); // 0..23
typedef void (^MSKMetronomeStartListener)();
typedef void (^MSKMetronomeStopListener)();
typedef void (^MSKMetronomeContinueListener)();
typedef void (^MSKMetronomeUsr3Listener)(unsigned ticktime, uint32_t d0, uint32_t d1, uint32_t d2);
typedef void (^MSKMetronomeUsr4Listener)(int sec, int nsec, uint32_t d0, uint32_t d1, uint32_t d2);

@interface MSKMetronome : NSObject

@property (readonly) ASKSeq *seq;	    // the sequencer object
@property (readonly) snd_seq_t *seq_handle; // sequencer handle
@property (readonly) int seq_queue;	    // sequencer queue
@property (readonly) int seq_port;	    // sequencer default port
@property (readonly) int queue_resolution;  // ticks per beat from Seq
@property (readonly) int cport;		    // metronome control port
@property (readonly) int num;		    // time signature numerator
@property (readonly) int den;		    // time signature denominator
@property (readonly) int measure;	    // measure count

// private - signal callback
@property (readonly, copy) MSKMetronomeBeatListener beatBlock;
@property (readonly, copy) MSKMetronomeClockListener clockBlock;
@property (readonly, copy) MSKMetronomeStartListener startBlock;
@property (readonly, copy) MSKMetronomeStopListener stopBlock;
@property (readonly, copy) MSKMetronomeContinueListener continueBlock;
@property (readonly, copy) MSKMetronomeUsr3Listener usr3Block;
@property (readonly, copy) MSKMetronomeUsr4Listener usr4Block;

- (id) initWithSeq:(ASKSeq*) seq error:(NSError**)error;

// control the running of the metronome
- (void) start;
- (void) stop;
- (void) kontinue;

// set the tempo, set the time signature
- (void) setTempo:(int)tempo error:(NSError**)error;
- (void) setTimesig:(int)num den:(int)den;

// to register a signal handler
- (void) onBeat:(MSKMetronomeBeatListener)block;
- (void) onClock:(MSKMetronomeClockListener)block;
- (void) onStart:(MSKMetronomeStartListener)block;
- (void) onStop:(MSKMetronomeStopListener)block;
- (void) onContinue:(MSKMetronomeContinueListener)block;

// request a usr3 callback in relative ticks
- (void) scheduleUsr3Relative:(int)ticks d0:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2;
- (void) onUsr3:(MSKMetronomeUsr3Listener)block;

// request a usr4 callback in relative realtime
- (void) scheduleUsr4Relative:(int)sec nsec:(int)nsec d0:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2;
- (void) onUsr4:(MSKMetronomeUsr4Listener)block;
@end
