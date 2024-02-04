/** -*- mode:objc -*-
 *
 * A model manages settings for oscillators.
 * This model will contain a superset of all possible oscillator parameters.
 *
 * Copyright (c) McLaren Labs 2024
 */

#import <Foundation/Foundation.h>

#import "McLarenSynthKit/model/MSKModelBase.h"
#import "McLarenSynthKit/model/MSKModelProtocol.h"

typedef enum msk_oscillator_type {
  MSK_OSCILLATOR_TYPE_SIN,
  MSK_OSCILLATOR_TYPE_SAW,
  MSK_OSCILLATOR_TYPE_SQUARE,
  MSK_OSCILLATOR_TYPE_TRIANGLE,
  MSK_OSCILLATOR_TYPE_REVSAW,
  MSK_OSCILLATOR_TYPE_NONE
} msk_oscillator_type_enum;

@interface MSKOscillatorTypeValueTransformer : NSValueTransformer
// translates from ENUM to STRING for GUI elements
@end

@interface MSKOscillatorModel : MSKModelBase<MSKModelProtocol> {

  @public
  // for reading in the audio loop
  msk_oscillator_type_enum _osctype;
  int _octave;
  int _transpose;
  int _cents;
  int _bendwidth;
  double _pitchbend;
  int _pw;			// 5..95
  int _noise;                   // 0..100
  double _cutoff;               // freq

  // int _pitchbendsw;

  // for FM Synth
  double _harmonic;
  double _subharmonic;

}

			     
// the properties of the model
@property (nonatomic, readwrite) msk_oscillator_type_enum osctype;
@property (nonatomic, readwrite) int octave;
@property (nonatomic, readwrite) int transpose;
@property (nonatomic, readwrite) int cents;
@property (nonatomic, readwrite) int bendwidth;
// @property (nonatomic, readwrite) int pitchbendsw;
@property (nonatomic, readwrite) double pitchbend;
@property (nonatomic, readwrite) int pw;
@property (nonatomic, readwrite) int noise;
@property (nonatomic, readwrite) double cutoff;

@property (nonatomic, readwrite) double harmonic;
@property (nonatomic, readwrite) double subharmonic;

- (id) initWithName:(NSString*)name; // for save/restore

@end
