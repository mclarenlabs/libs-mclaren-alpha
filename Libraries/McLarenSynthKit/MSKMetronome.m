/**  -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * ALSA Metronome
 *
 * Jan 2019
 */

#include <dispatch/dispatch.h>

#import "AlsaSoundKit/ASKError.h"
#import "McLarenSynthKit/MSKMetronome.h"

@implementation MSKMetronome

- (id) initWithSeq:(ASKSeq*)seq error:(NSError**)error {

  if (self = [super init]) {

    // standard time
    _num = 4;
    _den = 4;
    _measure = -1;
    
    _seq = seq;

    if (*error != nil) {
      NSLog(@"MSKMetronome ASKSeq init error:%@", *error);
      goto END;
    }

    _seq_handle = [_seq getHandle];
    _seq_queue = [_seq getQueue];

    _cport = snd_seq_create_simple_port(_seq_handle,
					"control",
					SND_SEQ_PORT_CAP_WRITE | SND_SEQ_PORT_CAP_SUBS_WRITE,
					SND_SEQ_PORT_TYPE_APPLICATION | SND_SEQ_PORT_TYPE_MIDI_GENERIC);
    if (_cport < 0) {
      NSLog(@"Error creating control port (%s)\n", snd_strerror(_cport));
      *error = [NSError errorWithASKAlsaError:_cport];
      goto END;
    }

    _queue_resolution = [_seq getResolution]; // TOM: TBD

    /*
     * The callback decodes the MIDI events sent on the control port.
     * The weak self breaks a retain loop.  Make sure not to destruct the
     * metronome before the seq.
     */
    MSKMetronome *wself = self;

    [_seq addListener:^(NSArray* events) {

        for (ASKSeqEvent *ev in events) {
          unsigned ticktime;
          unsigned sec;
          unsigned nsec;
          
          uint32_t beat;
          uint32_t clock;

          uint32_t d0, d1, d2;

          // NSLog(@"METRO event:%@", ev);
	  
          switch (ev->_ev.type) {
          case SND_SEQ_EVENT_USR1:
            ticktime = ev->_ev.time.tick;
            beat = ev->_ev.data.raw32.d[0];
            [wself scheduleBeat:beat ticktime:ticktime];
            break;
          case SND_SEQ_EVENT_USR2:
            ticktime = ev->_ev.time.tick;
            beat = ev->_ev.data.raw32.d[0];
            clock = ev->_ev.data.raw32.d[1];
            [wself emitClockCallback:clock beat:beat ticktime:ticktime];
            break;
          case SND_SEQ_EVENT_USR3:
            ticktime = ev->_ev.time.tick;
            d0 = ev->_ev.data.raw32.d[0];
            d1 = ev->_ev.data.raw32.d[1];
            d2 = ev->_ev.data.raw32.d[2];
            [wself emitUsr3Callback:d0 d1:d1 d2:d2 ticktime:ticktime];
            break;
          case SND_SEQ_EVENT_USR4:
            sec = ev->_ev.time.time.tv_sec;
            nsec = ev->_ev.time.time.tv_nsec;
            d0 = ev->_ev.data.raw32.d[0];
            d1 = ev->_ev.data.raw32.d[1];
            d2 = ev->_ev.data.raw32.d[2];
            [wself emitUsr4Callback:d0 d1:d1 d2:d2 sec:sec nsec:nsec];
            break;
          case SND_SEQ_EVENT_START:
            ticktime = ev->_ev.time.tick;
            _measure = 0;
            [wself start];
            [wself scheduleBeat:0 ticktime:ticktime];
            break;
          case SND_SEQ_EVENT_CONTINUE:
            [wself kontinue];
            break;
          case SND_SEQ_EVENT_STOP:
            [wself stop];
            break;
          }
        }
      }];

  }

  //  NSLog(@"port:%d cport:%d num:%d den:%d tempo:%d res:%d meas:%d",
  //	_seq_port, _cport, _num, _den, _queue_tempo, _queue_resolution, _measure);
  //
  //  NSLog(@"handle:%x queue:%d", _seq_handle, _seq_queue);

 END:
  return self;
}

- (void) scheduleBeat:(int)beat ticktime:(unsigned)ticktime {

  int tick;
  int duration;
  int end;

  // schedule midi clock events
  tick = 0;
  duration = _queue_resolution / 24;
  end = _queue_resolution * (4.0 / _den);

  int clock = 0;
  for (tick = 0; tick < end; tick += duration) {
    [self makeClock:tick clock:clock beat:beat];
    clock++;
  }

  if (beat == 0)
    _measure++;

  // signal the beat
  [self emitBeatCallback:beat measure:_measure ticktime:ticktime];

  // schedule the echo at a time in the future
  duration = _queue_resolution * (4.0 / _den);

  // have we sounded an entire measure?
  if (beat >= _num - 1) {
    [self makeEcho:0 ticks:duration];
    // _measure++;
  }
  else {
    [self makeEcho:beat+1 ticks:duration];
  }
}

/*
 * Emit a MIDI clock event on the output port
 *   tick: the amt to delay from the current time
 *   clock: the clock number
 *   beat: the beat number
 */

- (void) makeClock:(int)tick clock:(int)clock beat:(int)beat {

  // Schedule the MIDI clock itself
  snd_seq_event_t ev;
  snd_seq_ev_clear(&ev);
  ev.type = SND_SEQ_EVENT_CLOCK;
  snd_seq_ev_schedule_tick(&ev, _seq_queue, 1, tick);
  snd_seq_ev_set_source(&ev, _seq_port);
  snd_seq_ev_set_subs(&ev);
  snd_seq_event_output_direct(_seq_handle, &ev);  

  // Schedule the USR2 callback with (beat,tick) payload
  snd_seq_event_t evclk;
  snd_seq_ev_clear(&evclk);
  evclk.type = SND_SEQ_EVENT_USR2;
  evclk.data.raw32.d[0] = beat;
  evclk.data.raw32.d[1] = clock;
  snd_seq_ev_schedule_tick(&evclk, _seq_queue, 1, tick);
  snd_seq_ev_set_dest(&evclk, snd_seq_client_id(_seq_handle), _cport);
  snd_seq_event_output_direct(_seq_handle, &evclk);

}

/*
 * Sound or flash a note for the beat marker given.
 */

- (void) emitBeatCallback:(int)beat measure:(int)measure ticktime:(unsigned)ticktime {
  // NSLog(@"Beat:%d Measure:%d", beat, _measure);
  if (_beatBlock) {
    _beatBlock(ticktime, beat, measure);
  }
}

/*
 * Emit the callback that coincides with the MIDI CLOCK
 */
- (void) emitClockCallback:(int)clock beat:(int)beat ticktime:(unsigned)ticktime {
  if (_clockBlock) {
    _clockBlock(ticktime, clock, beat, _measure);
  }
}

/*
 * Emit the usr3 callback
 */
- (void) emitUsr3Callback:(uint32_t)d0 d1:(uint32_t)d1 d2:(uint32_t)d2 ticktime:(unsigned)ticktime {
  if (_usr3Block) {
    _usr3Block(ticktime, d0, d1, d2);
  }
}

/*
 * Emit the usr4 callback
 */
- (void) emitUsr4Callback:(uint32_t)d0 d1:(uint32_t)d1 d2:(uint32_t)d2 sec:(int)sec nsec:(int)nsec {
  if (_usr4Block) {
    _usr4Block(sec, nsec, d0, d1, d2);
  }
}

/*
 * The echo will be for a single beat.  It will include the beat count as a uint32 int
 * ev.data.raw32.d[0].  (The size of this fixed array is d[3].)
 */

- (void) makeEcho:(int)beat ticks:(int)ticks {
  snd_seq_event_t ev;

  snd_seq_ev_clear(&ev);
  ev.type = SND_SEQ_EVENT_USR1;
  ev.data.raw32.d[0] = beat;

  snd_seq_ev_schedule_tick(&ev, _seq_queue, 1, ticks);
  snd_seq_ev_set_dest(&ev, snd_seq_client_id(_seq_handle), _cport);
  snd_seq_event_output_direct(_seq_handle, &ev);
}

/*
 * Start the metronome running
 */

- (void) start {

  /*
   * Starting a queue has the side effect of clearing it.  We want to
   * be able to add events to the queue in the startBlock(), so this
   * technique restarts the queue at zero and halts it ... ready to
   * schedule events.  After startBlock() the queue resumes.
   */

  snd_seq_start_queue(_seq_handle, _seq_queue, NULL);
  snd_seq_drain_output(_seq_handle);
  
  snd_seq_stop_queue(_seq_handle, _seq_queue, NULL);
  snd_seq_drain_output(_seq_handle);

  if (_startBlock) {
    _startBlock();
  }

  snd_seq_continue_queue(_seq_handle, _seq_queue, NULL);
  snd_seq_drain_output(_seq_handle);
  
  [self scheduleBeat:0 ticktime:0];
}

/*
 * Stop the metronome
 */

- (void) stop {

  if (_stopBlock) {
    _stopBlock();
  }

  snd_seq_stop_queue(_seq_handle, _seq_queue, NULL);
  snd_seq_drain_output(_seq_handle);
}

/*
 * Continue a stopped metronome
 */

- (void) kontinue {

  if (_continueBlock) {
    _continueBlock();
  }
  
  snd_seq_continue_queue(_seq_handle, _seq_queue, NULL);
  snd_seq_drain_output(_seq_handle);
}

- (void) setTempo:(int)tempo error:(NSError**)error {
  [_seq setTempo:tempo error:error];
}

- (void) setTimesig:(int)num den:(int)den {
  _num = num;
  _den = den;
}

/*
 * Register the callback handler
 */

- (void) onBeat:(MSKMetronomeBeatListener)block {
  _beatBlock = block;
}
					   
- (void) onClock:(MSKMetronomeClockListener)block {
  _clockBlock = block;
}
					   
- (void) onStart:(MSKMetronomeStartListener)block {
  _startBlock = block;
}

- (void) onStop:(MSKMetronomeStopListener)block {
  _stopBlock = block;
}
					   
- (void) onContinue:(MSKMetronomeContinueListener)block {
  _continueBlock = block;
}

- (void) scheduleUsr3Relative:(int)ticks d0:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2 {
  // Schedule the USR3 callback relative in ticks
  snd_seq_event_t ev;

  snd_seq_ev_clear(&ev);
  ev.type = SND_SEQ_EVENT_USR3;
  ev.data.raw32.d[0] = d0;
  ev.data.raw32.d[1] = d1;
  ev.data.raw32.d[2] = d2;

  snd_seq_ev_schedule_tick(&ev, _seq_queue, 1, ticks);
  snd_seq_ev_set_dest(&ev, snd_seq_client_id(_seq_handle), _cport);
  snd_seq_event_output_direct(_seq_handle, &ev);
}

- (void) onUsr3:(MSKMetronomeUsr3Listener)block {
  _usr3Block = block;
}

- (void) scheduleUsr4Relative:(int)sec nsec:(int)nsec d0:(unsigned)d0 d1:(unsigned)d1 d2:(unsigned)d2 {

  // Schedule a USR4 callback relative in realtime
  snd_seq_event_t ev;
  snd_seq_real_time_t t;
  t.tv_sec = sec;
  t.tv_nsec = nsec;

  snd_seq_ev_clear(&ev);
  ev.type = SND_SEQ_EVENT_USR4;
  ev.data.raw32.d[0] = d0;
  ev.data.raw32.d[1] = d1;
  ev.data.raw32.d[2] = d2;

  snd_seq_ev_schedule_real(&ev, _seq_queue, 1, &t);
  snd_seq_ev_set_dest(&ev, snd_seq_client_id(_seq_handle), _cport);
  snd_seq_event_output_direct(_seq_handle, &ev);

}

- (void) onUsr4:(MSKMetronomeUsr4Listener)block {
  _usr4Block = block;
}

					   
- (void) dealloc {
  [self stop];
}

@end
