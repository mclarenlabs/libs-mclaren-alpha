/** -*- mode:objc -*-
 *
 * A model manages settings for drawbar oscillators.
 * This model will contain a superset of all possible oscillator parameters.
 *
 * Copyright (c) McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/model/MSKOscillatorModel.h"

#define MSK_DRAWBAR_OSCILLATOR_MAXTONES 10		// for organ overtones

@interface MSKDrawbarModel : NSObject < NSCoding > {
  @public
    // for reading in the audio loop
  int _organ;			// YES,NO
  int _overtones;		// how many drawbar overtones
  int _numerators[MSK_DRAWBAR_OSCILLATOR_MAXTONES];
  int _denominators[MSK_DRAWBAR_OSCILLATOR_MAXTONES];

  // continuous updates
  double _amplitudes[MSK_DRAWBAR_OSCILLATOR_MAXTONES];
}

@property (nonatomic, readwrite) int organ;
@property (nonatomic, readwrite) int overtones;

// the drawbar values - range [0..8]
@property (nonatomic, readwrite, getter=getAmp0, setter=setAmp0:) double amp0;
@property (nonatomic, readwrite, getter=getAmp1, setter=setAmp1:) double amp1;
@property (nonatomic, readwrite, getter=getAmp2, setter=setAmp2:) double amp2;
@property (nonatomic, readwrite, getter=getAmp3, setter=setAmp3:) double amp3;
@property (nonatomic, readwrite, getter=getAmp4, setter=setAmp4:) double amp4;
@property (nonatomic, readwrite, getter=getAmp5, setter=setAmp5:) double amp5;
@property (nonatomic, readwrite, getter=getAmp6, setter=setAmp6:) double amp6;
@property (nonatomic, readwrite, getter=getAmp7, setter=setAmp7:) double amp7;
@property (nonatomic, readwrite, getter=getAmp8, setter=setAmp8:) double amp8;


@end
