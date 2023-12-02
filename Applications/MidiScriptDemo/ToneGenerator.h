/**
 * Generate Tones on a PCM device
 *
 * McLaren Labs 2023
 */

#import "AlsaSoundKit/AlsaSoundKit.h"

// The ToneGenerator can exercise either the FLOAT_LE or S32_LE formats.
// We put in this flag to validate the two formats against the ASKPcm implementation.

#define TONEGEN_USE_FLOAT_LE 1

typedef NS_ENUM(NSUInteger, NoteState) {
  NOTE_OFF,
    NOTE_ATTACK,
    NOTE_DECAY,
    NOTE_SUSTAIN,
    NOTE_RELEASE
};


@interface Note : NSObject

@property (readwrite) int midiNote;          // which note to play
@property (readwrite) double sampleRate;     // samples per second

@property (readwrite) double attackSamples;  // number of samples in Attack
@property (readwrite) double sustainLevel;   // level at which to Decay to
@property (readwrite) double releaseSamples; // number of samples in Release

@property (readonly) NoteState state;        // current state of the envelope

- (void) attack; // begin noteOn
- (void) releaseIt; // begin noteOff
- (BOOL) noteIsOff; // state == OFF

#if TONEGEN_USE_FLOAT_LE
- (void) render:(float*)wav n:(int)n;
#else
- (void) render:(int32_t*)wav n:(int)n;
#endif

@end

@interface ToneGenerator : NSObject

- (void) openPcm:(NSString*)pcmname;
- (void) start;
- (void) stop;

// trigger note On/Off
- (void) noteOn:(unsigned)note vel:(unsigned)vel;
- (void) noteOff:(unsigned)note vel:(unsigned)vel;

// set the envelope
- (double) attackTime;
- (void) setAttackTime:(double)val;
- (double) sustainLevel;
- (void) setSustainLevel:(double)val;
- (double) releaseTime;
- (void) setReleaseTime:(double)val;

@end

