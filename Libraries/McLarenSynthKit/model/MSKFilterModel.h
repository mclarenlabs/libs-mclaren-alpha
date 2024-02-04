/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * Model for general filter
 *
 * Copyright (c) McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/model/MSKModelBase.h"
#import "McLarenSynthKit/model/MSKModelProtocol.h"

typedef enum msk_filter_type  {
  MSK_FILTER_NONE,
  MSK_FILTER_BIQUAD_TYPE_LOWPASS,
  MSK_FILTER_BIQUAD_TYPE_HIGHPASS,
  MSK_FILTER_BIQUAD_TYPE_BANDPASS,
  MSK_FILTER_BIQUAD_TYPE_NOTCH,
  MSK_FILTER_BIQUAD_TYPE_PEAK,
  MSK_FILTER_BIQUAD_TYPE_LOWSHELF,
  MSK_FILTER_BIQUAD_TYPE_HIGHSHELF,
  MSK_FILTER_MOOG,
  MSK_FILTER_MOOG_TANH
} msk_filter_type_enum;

@interface MSKFilterTypeValueTransformer : NSValueTransformer
  // translates from ENUM to STRING for GUI elements
@end

@interface MSKFilterModel : MSKModelBase<MSKModelProtocol> {
  @public
  msk_filter_type_enum _filtertype; // for reading in the audio loop
  double _fc;                   // cutoff 80 Hz - 18KHz
  double _q;                    // Q value [1..10]
  double _fcmod;                // +/- semis
}

// the properties of the model
@property (nonatomic, readwrite) msk_filter_type_enum filtertype;
@property (nonatomic, readwrite) double fc;
@property (nonatomic, readwrite) double q;
@property (nonatomic, readwrite) double fcmod;

- (id) initWithName:(NSString*)name;

@end

