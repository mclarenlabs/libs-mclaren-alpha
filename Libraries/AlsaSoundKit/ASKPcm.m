/* -*- mode:objc -*-
 *
 * Manage an Alsa PCM device.
 *
 * $copyright$
 */

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/ASKError.h"
#import "AlsaSoundKit/ASKPcmSystem.h"
#import "AlsaSoundKit/ASKPcm.h"

static int PCMDEBUG = 1;


/*
 * Error Handling
 */

char *ASKPcmThreadErrorExit = "ASK Pcm Pthread Error Exit";

/*
 * SND PCM STATUS
 */

@implementation ASKPcmStatus

- (id) init {

  if (self = [super init]) {

    _pcm_status =  NULL;
    int err = snd_pcm_status_malloc(&(_pcm_status));
    if (err < 0) {
      NSLog(@"snd_pcm_status_malloc error (%s)", snd_strerror(err));
    }
  }

  return self;
}

- (void) dealloc {
  if (_pcm_status != NULL) {
    snd_pcm_status_free(_pcm_status);
  }
  _pcm_status = NULL;
}

- (snd_pcm_state_t) getState {
  return snd_pcm_status_get_state(_pcm_status);
}

- (NSString*) getStateName {
  snd_pcm_state_t state = [self getState];
  return [ASKPcmInfo stateToString:state];
}

- (snd_pcm_sframes_t) getDelay {
  return snd_pcm_status_get_delay(_pcm_status);
}

- (snd_pcm_uframes_t) getAvail {
  return snd_pcm_status_get_avail(_pcm_status);
}

- (snd_pcm_uframes_t) getAvailMax {
  return snd_pcm_status_get_avail_max(_pcm_status);
}

- (snd_pcm_uframes_t) getOverrange {
  return snd_pcm_status_get_overrange(_pcm_status);
}

- (NSString*) description {
  NSString *s1 = [NSString stringWithFormat:@"STATUS State:%@ delay:%ld avail:%lu max:%lu overrage:%lu",
                           [self getStateName], [self getDelay], [self getAvail], [self getAvailMax], [self getOverrange]];
  return s1;
}

@end

/*
 * SND PCM HW PARAMS
 */

@implementation ASKPcmHwParams

- (id) init {

  if (self = [super init]) {

    _hw_params =  NULL;
    int err = snd_pcm_hw_params_malloc(&(_hw_params));
    if (err < 0) {
      NSLog(@"snd_pcm_hw_params_malloc error (%s)",
              snd_strerror(err));
    }
  }

  return self;
}

- (void) dealloc {
  if (_hw_params != NULL) {
    snd_pcm_hw_params_free(_hw_params);
  }
  _hw_params = NULL;
}

- (BOOL) getAccess:(snd_pcm_access_t*)access error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_access(_hw_params, access);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}


- (NSString*) getAccessDescription {
  int err;
  snd_pcm_access_t access;
  NSString *s;
  err = snd_pcm_hw_params_get_access(_hw_params, &access);
  if (err < 0) {
    s = @"<U>";
  }
  else {
    const char *cs = snd_pcm_access_name(access);
    s = [NSString stringWithCString:cs];
  }
  return s;
}

- (BOOL) getFormat:(snd_pcm_format_t*)format error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_format(_hw_params, format);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (NSString*) getFormatDescription {
  int err;
  snd_pcm_format_t format;
  NSString *s;
  err = snd_pcm_hw_params_get_format(_hw_params, &format);
  if (err < 0) {
    s = @"<U>";
  }
  else {
    const char *cs = snd_pcm_format_name(format);
    s = [NSString stringWithCString:cs];
  }
  return s;
}

- (BOOL) getChannels:(unsigned int*)channels error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_channels(_hw_params, channels);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getChannelsMin:(unsigned int*)channels error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_channels_min(_hw_params, channels);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getChannelsMax:(unsigned int*)channels error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_channels_max(_hw_params, channels);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}


- (BOOL) getRate:(unsigned int*)rate error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_rate(_hw_params, rate, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getRateMin:(unsigned int*)rate error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_rate_min(_hw_params, rate, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getRateMax:(unsigned int*)rate error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_rate_max(_hw_params, rate, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriodTime:(unsigned int*)period error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_period_time(_hw_params, period, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriodTimeMin:(unsigned int*)period error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_period_time_min(_hw_params, period, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriodTimeMax:(unsigned int*)period error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_period_time_max(_hw_params, period, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriodSize:(snd_pcm_uframes_t*)period error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_period_size(_hw_params, period, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriodSizeMin:(snd_pcm_uframes_t*)period error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_period_size_min(_hw_params, period, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriodSizeMax:(snd_pcm_uframes_t*)period error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_period_size_max(_hw_params, period, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriods:(unsigned int*)periods error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_periods(_hw_params, periods, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriodsMin:(unsigned int*)periods error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_periods_min(_hw_params, periods, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriodsMax:(unsigned int*)periods error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_periods_max(_hw_params, periods, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getBufferTime:(unsigned int*)buffertime error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_buffer_time(_hw_params, buffertime, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getBufferTimeMin:(unsigned int*)buffertime error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_buffer_time_min(_hw_params, buffertime, NULL);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getBufferTimeMax:(unsigned int*)buffertime error:(NSError**)error {
  BOOL ok = YES;
  int err;
  err = snd_pcm_hw_params_get_buffer_time_max(_hw_params, buffertime, NULL);
  return err;
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getBufferSize:(snd_pcm_uframes_t*)size error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_buffer_size(_hw_params, size);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getBufferSizeMin:(snd_pcm_uframes_t*)size error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_buffer_size_min(_hw_params, size);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getBufferSizeMax:(snd_pcm_uframes_t*)size error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_get_buffer_size_max(_hw_params, size);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (NSString*) description {
  int err;
  unsigned int channels, channels_min, channels_max;
  NSString *schannels, *schannels_min, *schannels_max;
  unsigned int rate, rate_min, rate_max;
  NSString *srate, *srate_min, *srate_max;
  snd_pcm_uframes_t periodsize, periodsize_min, periodsize_max;
  NSString *speriodsize, *speriodsize_min, *speriodsize_max;
  unsigned int periods, periods_min, periods_max;
  NSString *speriods, *speriods_min, *speriods_max;
  snd_pcm_uframes_t buffersize, buffersize_min, buffersize_max;
  NSString *sbuffersize, *sbuffersize_min, *sbuffersize_max;
  unsigned int buffertime, buffertime_min, buffertime_max;
  NSString *sbuffertime, *sbuffertime_min, *sbuffertime_max;

  // channels

  err = snd_pcm_hw_params_get_channels(_hw_params, &channels);
  if (err < 0) {
    schannels = @"U";           // unknown
  }
  else {
    schannels = [NSString stringWithFormat:@"%u", channels];
  }

  err = snd_pcm_hw_params_get_channels_min(_hw_params, &channels_min);
  if (err < 0) {
    schannels_min = @"U";       // unknown
  }
  else {
    schannels_min = [NSString stringWithFormat:@"%u", channels_min];
  }
  
  err = snd_pcm_hw_params_get_channels_max(_hw_params, &channels_max);
  if (err < 0) {
    schannels_max = @"U";       // unknown
  }
  else {
    schannels_max = [NSString stringWithFormat:@"%u", channels_max];
  }

  // rate

  err = snd_pcm_hw_params_get_rate(_hw_params, &rate, NULL);
  if (err < 0) {
    srate = @"U";               // unknown
  }
  else {
    srate = [NSString stringWithFormat:@"%u", rate];
  }

  err = snd_pcm_hw_params_get_rate_min(_hw_params, &rate_min, NULL);
  if (err < 0) {
    srate_min = @"U";           // unknown
  }
  else {
    srate_min = [NSString stringWithFormat:@"%u", rate_min];
  }

  err = snd_pcm_hw_params_get_rate_max(_hw_params, &rate_max, NULL);
  if (err < 0) {
    srate_max = @"U";           // unknown
  }
  else {
    srate_max = [NSString stringWithFormat:@"%u", rate_max];
  }

  // period size

  err = snd_pcm_hw_params_get_period_size(_hw_params, &periodsize, NULL);
  if (err < 0) {
    speriodsize = [NSString stringWithFormat:@"U"];
  }
  else {
    speriodsize = [NSString stringWithFormat:@"%lu", periodsize];
  }

  err = snd_pcm_hw_params_get_period_size_min(_hw_params, &periodsize_min, NULL);
  if (err < 0) {
    speriodsize_min = [NSString stringWithFormat:@"U"];
  }
  else {
    speriodsize_min = [NSString stringWithFormat:@"%lu", periodsize_min];
  }

  err = snd_pcm_hw_params_get_period_size_max(_hw_params, &periodsize_max, NULL);
  if (err < 0) {
    speriodsize_max = [NSString stringWithFormat:@"U"];
  }
  else {
    speriodsize_max = [NSString stringWithFormat:@"%lu", periodsize_max];
  }

  // periods

  err = snd_pcm_hw_params_get_periods(_hw_params, &periods, NULL);
  if (err < 0) {
    speriods = [NSString stringWithFormat:@"U"];
  }
  else {
    speriods = [NSString stringWithFormat:@"%u", periods];
  }

  err = snd_pcm_hw_params_get_periods_min(_hw_params, &periods_min, NULL);
  if (err < 0) {
    speriods_min = [NSString stringWithFormat:@"U"];
  }
  else {
    speriods_min = [NSString stringWithFormat:@"%u", periods_min];
  }

  err = snd_pcm_hw_params_get_periods_max(_hw_params, &periods_max, NULL);
  if (err < 0) {
    speriods_max = [NSString stringWithFormat:@"U"];
  }
  else {
    speriods_max = [NSString stringWithFormat:@"%u", periods_max];
  }

  // buffer size

  err = snd_pcm_hw_params_get_buffer_size(_hw_params, &buffersize);
  if (err < 0) {
    sbuffersize = [NSString stringWithFormat:@"U"];
  }
  else {
    sbuffersize = [NSString stringWithFormat:@"%lu", buffersize];
  }

  err = snd_pcm_hw_params_get_buffer_size_min(_hw_params, &buffersize_min);
  if (err < 0) {
    sbuffersize_min = [NSString stringWithFormat:@"U"];
  }
  else {
    sbuffersize_min = [NSString stringWithFormat:@"%lu", buffersize_min];
  }

  err = snd_pcm_hw_params_get_buffer_size_max(_hw_params, &buffersize_max);
  if (err < 0) {
    sbuffersize_max = [NSString stringWithFormat:@"U"];
  }
  else {
    sbuffersize_max = [NSString stringWithFormat:@"%lu", buffersize_max];
  }

  // buffer time

  err = snd_pcm_hw_params_get_buffer_time(_hw_params, &buffertime, 0);
  if (err < 0) {
    sbuffertime = @"U";
  }
  else {
    sbuffertime = [NSString stringWithFormat:@"%u", buffertime];
  }

  err = snd_pcm_hw_params_get_buffer_time_min(_hw_params, &buffertime_min, 0);
  if (err < 0) {
    sbuffertime_min = @"U";
  }
  else {
    sbuffertime_min = [NSString stringWithFormat:@"%u", buffertime_min];
  }

  err = snd_pcm_hw_params_get_buffer_time_max(_hw_params, &buffertime_max, 0);
  if (err < 0) {
    sbuffertime_max = @"U";
  }
  else {
    sbuffertime_max = [NSString stringWithFormat:@"%u", buffertime_max];
  }

  NSString *s1 = [NSString stringWithFormat:@"ALSA-HWPARAMS chan:%@(%@,%@) rate:%@(%@,%@), period:%@(%@,%@), periods:%@(%@,%@), bufsize:%@(%@,%@) buftime:%@(%@,%@) access:%@:%@ format:%@:%@",
                           schannels, schannels_min, schannels_max,
                           srate, srate_min, srate_max, 
                           speriodsize, speriodsize_min, speriodsize_max,
                           speriods, speriods_min, speriods_max,
                           sbuffersize, sbuffersize_min, sbuffersize_max,
                           sbuffertime, sbuffertime_min, sbuffertime_max,
                           [self getAccessDescription], [self accessDescriptions],
                           [self getFormatDescription], [self fmaskDescriptions]
                  ];
  return s1;

}


- (NSArray*) accessDescriptions {

  int err;
  snd_pcm_access_mask_t *amask;
  snd_pcm_access_mask_alloca(&amask);

  NSMutableArray *arr = [[NSMutableArray alloc] init];

  err = snd_pcm_hw_params_get_access_mask(_hw_params, amask);
  if (err < 0) {
    NSLog(@"snd_pcm_hw_params_get_access_mask error (%s)",
            snd_strerror(err));
    goto end;
  }

  for (int access = 0; access <= SND_PCM_ACCESS_LAST; ++access) {
    if (snd_pcm_access_mask_test(amask, (snd_pcm_access_t) access)) {
      const char *s = snd_pcm_access_name((snd_pcm_access_t) access);
      NSString *ns = [NSString stringWithCString:s];
      [arr addObject:ns];
    }
  }

 end:
  return arr;
}


- (NSArray*) fmaskDescriptions {

  snd_pcm_format_mask_t *fmask;
  snd_pcm_format_mask_alloca(&fmask);

  NSMutableArray *arr = [[NSMutableArray alloc] init];

  snd_pcm_hw_params_get_format_mask(_hw_params, fmask);

  for (int fmt = 0; fmt <= SND_PCM_FORMAT_LAST; ++fmt) {
    if (snd_pcm_format_mask_test(fmask, (snd_pcm_format_t) fmt)) {
      const char *s = snd_pcm_format_name((snd_pcm_format_t) fmt);
      NSString *ns = [NSString stringWithCString:s];
      [arr addObject:ns];
    }
  }

  return arr;
}

@end // SND PCM HW PARAMS

/*
 * SND PCM SW PARAMS
 */

@implementation ASKPcmSwParams

- (id) init {

  if (self = [super init]) {

    _sw_params =  NULL;
    int err = snd_pcm_sw_params_malloc(&(_sw_params));
    if (err < 0) {
      NSLog(@"snd_pcm_sw_params_malloc error (%s)",
              snd_strerror(err));
    }
  }

  return self;
}

- (void) dealloc {
  if (_sw_params != NULL) {
    snd_pcm_sw_params_free(_sw_params);
  }
  _sw_params = NULL;
}

- (BOOL) getTstampMode:(snd_pcm_tstamp_t*)mode error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_get_tstamp_mode(_sw_params, mode);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (NSString*) getTstampModeDescription {
  snd_pcm_tstamp_t tstamp;
  NSString *s;
  int err = snd_pcm_sw_params_get_tstamp_mode(_sw_params, &tstamp);
  if (err < 0) {
    s = [NSString stringWithFormat:@"<unknown>"];
  }
  else {
    s = [NSString stringWithCString:snd_pcm_tstamp_mode_name(tstamp)];
  }
  return s;
}

- (BOOL) getAvailMin:(snd_pcm_uframes_t*)avail error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_get_avail_min(_sw_params, avail);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getPeriodEvent:(int*)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_get_period_event(_sw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}
  
- (BOOL) getStartThreshold:(snd_pcm_uframes_t*)threshold error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_get_start_threshold(_sw_params, threshold);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getStopThreshold:(snd_pcm_uframes_t*)threshold error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_get_stop_threshold(_sw_params, threshold);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) getSilenceThreshold:(snd_pcm_uframes_t*)threshold error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_get_silence_threshold(_sw_params, threshold);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL)getSilenceSize:(snd_pcm_uframes_t*)size error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_get_silence_size(_sw_params, size);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (NSString*) description {
  int err;

  snd_pcm_uframes_t avail_min;
  NSString *savail_min;

  int period;
  NSString *speriod;

  snd_pcm_uframes_t start_threshold, stop_threshold, silence_threshold, silence_size;
  NSString *sstart_threshold, *sstop_threshold, *ssilence_threshold, *ssilence_size;

  err = snd_pcm_sw_params_get_avail_min(_sw_params, &avail_min);
  if (err < 0) {
    savail_min = @"<U>";
  }
  else {
    savail_min = [NSString stringWithFormat:@"%lu", avail_min];
  }

  err = snd_pcm_sw_params_get_period_event(_sw_params, &period);
  if (err < 0) {
    speriod = @"<U>";
  }
  else {
    speriod = [NSString stringWithFormat:@"%d", period];
  }

  err = snd_pcm_sw_params_get_start_threshold(_sw_params, &start_threshold);
  if (err < 0) {
    sstart_threshold = @"<U>";
  }
  else {
    sstart_threshold = [NSString stringWithFormat:@"%lu", start_threshold];
  }

  err = snd_pcm_sw_params_get_stop_threshold(_sw_params, &stop_threshold);
  if (err < 0) {
    sstop_threshold = @"<U>";
  }
  else {
    sstop_threshold = [NSString stringWithFormat:@"%lu", stop_threshold];
  }

  err = snd_pcm_sw_params_get_silence_threshold(_sw_params, &silence_threshold);
  if (err < 0) {
    ssilence_threshold = @"<U>";
  }
  else {
    ssilence_threshold = [NSString stringWithFormat:@"%lu", silence_threshold];
  }

  err = snd_pcm_sw_params_get_silence_size(_sw_params, &silence_size);
  if (err < 0) {
    ssilence_size = @"<U>";
  }
  else {
    ssilence_size = [NSString stringWithFormat:@"%lu", silence_size];
  }

  NSString *s1 = [NSString stringWithFormat:@"ALSA-SWPARAMS tstampmode:%@ amin:%@ per:%@ start:%@ stop:%@ sil:%@ size:%@",
                           [self getTstampModeDescription], savail_min, speriod,
                           sstart_threshold, sstop_threshold, ssilence_threshold, ssilence_size
                  ];
  return s1;
}


@end // SND PCM SW PARAMS

/*
 * SND PCM implementation
 */

@implementation ASKPcm


- (id) initWithName:(NSString*)name stream:(snd_pcm_stream_t)stream error:(NSError**)error {

  int err;
  int mode = 0; // default is blocking

  ASKError_linker_function();

  if (self = [super init]) {

    _name = name;
    _stream = stream;
    _threadname = [NSString stringWithFormat:@"%@(%@)",
                            _name,
                            _stream == SND_PCM_STREAM_PLAYBACK ? @"play" : @"capt"];
    _pth = 0;
    _running = 0;
    _alive = 0;
    _waiterror = 0;
    _xruncnt = 0;

    const char *cname = [name cStringUsingEncoding:NSASCIIStringEncoding];

    err = snd_pcm_open(&(_pcm_handle), cname, stream, mode);
    if (err < 0) {
      if (PCMDEBUG)
        NSLog(@"cannot open pcm name:%s (%s)", cname, snd_strerror(err));
      NSError *alsaerror = [NSError errorWithASKAlsaError:err];
      NSError *asnderror = [NSError errorWithASKPcmError:kASKPcmErrorCannotOpenDevice
                                                     str:[NSString stringWithFormat:@"cannot open pcm name:%s", cname]
                                                   under:alsaerror];
      *error = asnderror;
      goto end;
    }

    err = snd_pcm_nonblock(_pcm_handle, 0);
    if (err < 0) {
      if (PCMDEBUG)
        NSLog(@"cannot set pcm to blocking:%s (%s)", cname, snd_strerror(err));
      NSError *alsaerror = [NSError errorWithASKAlsaError:err];
      NSError *asnderror = [NSError errorWithASKPcmError:kASKPcmErrorCannotConfigureDevice
                                                     str:[NSString stringWithFormat:@"cannot set pcm to blocking:%s", cname]
                                                   under:alsaerror];
      *error = asnderror;
      goto end;
    }
  }
  
 end:
  return self;
}

- (ASKPcmInfo*) getInfo:(NSError**)error {

  if (_pcm_handle == NULL) {
    return nil;
  }

  ASKPcmInfo *info = [[ASKPcmInfo alloc] init];

  int err = snd_pcm_info(_pcm_handle, info.pcm_info);

  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
  }
  return info;
}

- (ASKPcmStatus*) getStatus:(NSError**)error {

  if (_pcm_handle == NULL) {
    *error = [NSError errorWithASKPcmError:kASKPcmErrorIllegalState str:@"Null pcm handle"];
    return nil;
  }

  ASKPcmStatus *status = [[ASKPcmStatus alloc] init];

  int err = snd_pcm_status(_pcm_handle, status.pcm_status);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
  }
  return status;
}

- (ASKPcmHwParams*) getHwParams:(NSError**)error {

  if (_pcm_handle == NULL) {
    *error = [NSError errorWithASKPcmError:kASKPcmErrorIllegalState str:@"Null pcm handle"];
    return nil;
  }

  ASKPcmHwParams *hwparams = [[ASKPcmHwParams alloc] init];

  int err = snd_pcm_hw_params_any(_pcm_handle, hwparams.hw_params);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
  }
  return hwparams;
}

// Set the hardware params for the PCM and cache the key format values

- (BOOL) setHwParams:(ASKPcmHwParams*)hwparams error:(NSError**)error {
  BOOL ok = YES;

  int err = snd_pcm_hw_params(_pcm_handle, hwparams.hw_params);

  if (err != 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  else {
    // then cache format and calc formatsize
    int err2;
    err2 = snd_pcm_hw_params_get_access(hwparams.hw_params, &_access);
    if (err2 < 0) {
      if (PCMDEBUG)
        NSLog(@"snd_pcm_hw_params_get_access error (%s)", snd_strerror(err2));
      *error = [NSError errorWithASKAlsaError:err2];
      ok = NO;
      goto end;
    }
    err2 = snd_pcm_hw_params_get_format(hwparams.hw_params, &_format);
    if (err2 < 0) {
      // NSLog(@"snd_pcm_hw_params_get_format error (%s)", snd_strerror(err2));
      // err = err2;
      *error = [NSError errorWithASKAlsaError:err2];
      ok = NO;
      goto end;
    }
    err2 = snd_pcm_hw_params_get_period_size(hwparams.hw_params, &_persize, NULL);
    if (err2 < 0) {
      if (PCMDEBUG)
        NSLog(@"snd_pcm_hw_params_get_persize error (%s)", snd_strerror(err2));
      *error = [NSError errorWithASKAlsaError:err2];
      ok = NO;
      goto end;
    }

    // if we made it here also store the size of the format
    if (err2 == 0) {
      if (_format == SND_PCM_FORMAT_S32_LE) {
        _formatsize = sizeof(int32_t);
      }
      else if (_format == SND_PCM_FORMAT_S16_LE) {
        _formatsize = sizeof(int16_t);
      }
      else if (_format == SND_PCM_FORMAT_FLOAT_LE) {
        _formatsize = sizeof(float);
      }
      else {
        if (PCMDEBUG)
          NSLog(@"setHwParams: pcm unknown formatsize");
        *error = [NSError errorWithASKPcmError:kASKPcmErrorInternalConsistencyError
                                           str:@"setHwParams - pcm unknown format size"];
        ok = NO;                          
      }
    }
  }

 end:
  return ok;
}


- (ASKPcmSwParams*) getSwParams {

  if (_pcm_handle == NULL) {
    return nil;
  }

  ASKPcmSwParams *swparams = [[ASKPcmSwParams alloc] init];

  int err = snd_pcm_sw_params_current(_pcm_handle, swparams.sw_params);
  if (err < 0) {
    NSLog(@"snd_pcm_sw_params_current error (%s)",
          snd_strerror(err));
  }
  return swparams;
}

- (BOOL) setSwParams:(ASKPcmSwParams*)swparams error:(NSError**)error {

  BOOL ok = YES;

  int err = snd_pcm_sw_params(_pcm_handle, swparams.sw_params);

  if (err != 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

////////////////////////////////////////////////////////////////
//
// HW Params

- (BOOL) setAccess:(ASKPcmHwParams*)params val:(snd_pcm_access_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_access(_pcm_handle, params.hw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setFormat:(ASKPcmHwParams*)params val:(snd_pcm_format_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_format(_pcm_handle, params.hw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setSubFormat:(ASKPcmHwParams*)params val:(snd_pcm_subformat_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_subformat(_pcm_handle, params.hw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setChannels:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_channels(_pcm_handle, params.hw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setChannelsNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_channels_near(_pcm_handle, params.hw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setRate:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_rate(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setRateNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_rate_near(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setPeriodTime:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_period_time(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setPeriodTimeNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_period_time_near(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}
  
- (BOOL) setPeriodSize:(ASKPcmHwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_period_size(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setPeriodSizeNear:(ASKPcmHwParams*)params val:(snd_pcm_uframes_t*)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_period_size_near(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setPeriods:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_periods(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setPeriodsNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_periods_near(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setBufferTime:(ASKPcmHwParams*)params val:(unsigned int)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_buffer_time(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setBufferTimeNear:(ASKPcmHwParams*)params val:(unsigned int*)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_buffer_time_near(_pcm_handle, params.hw_params, val, 0);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setBufferSize:(ASKPcmHwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_buffer_size(_pcm_handle, params.hw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setBufferSizeNear:(ASKPcmHwParams*)params val:(snd_pcm_uframes_t*)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_hw_params_set_buffer_size_near(_pcm_handle, params.hw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}




////////////////////////////////////////////////////////////////
//
// SW Params

- (BOOL) setTstampMode:(ASKPcmSwParams*)params val:(snd_pcm_tstamp_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_set_tstamp_mode(_pcm_handle, params.sw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setAvailMin:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_set_avail_min(_pcm_handle, params.sw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setPeriodEvent:(ASKPcmSwParams*)params val:(int)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_set_period_event(_pcm_handle, params.sw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setStartThreshold:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_set_start_threshold(_pcm_handle, params.sw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setStopThreshold:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_set_stop_threshold(_pcm_handle, params.sw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setSilenceThreshold:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_set_silence_threshold(_pcm_handle, params.sw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}

- (BOOL) setSilenceSize:(ASKPcmSwParams*)params val:(snd_pcm_uframes_t)val error:(NSError**)error {
  BOOL ok = YES;
  int err = snd_pcm_sw_params_set_silence_size(_pcm_handle, params.sw_params, val);
  if (err < 0) {
    *error = [NSError errorWithASKAlsaError:err];
    ok = NO;
  }
  return ok;
}


////////////////////////////////////////////////////////////////
//
// PTHREAD
//

// general thread start service
static bool startPThread(pthread_t *pth, void *(*thread_fn)(void*), void *arg,
                         bool schedfifo, char priodec, bool create_detached, const char *name)
{
  pthread_attr_t attr;
  int chk;
  bool outcome = false;
  bool retry = true;
  while (retry) {
    if (!(chk = pthread_attr_init(&attr))) {
      if (create_detached) {
        chk = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
      }
      if (!chk) {
        if (schedfifo) {
          if ((chk = pthread_attr_setschedpolicy(&attr, SCHED_FIFO))) {
            NSLog(@"Failed to set SCHED_FIFO policy in thread attribute %s (%d)",
                  strerror(errno), chk);
            schedfifo = false;
            continue;
          }
          if ((chk = pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED))) {
            NSLog(@"Failed to set inherit scheduler thread attribute %s (%d)",
                  strerror(errno), chk);
            schedfifo = false;
            continue;
          }
          /* TOM: from pthread.h */
          struct sched_param prio_params;
          /* TOM: make constant */
          // int prio = rtprio - priodec;
          int prio = 40 - 1;
          if (prio < 1)
            prio = 1;

          if (PCMDEBUG)
            NSLog(@"ASKPcm thread:%s priority is %d", name, prio);

          prio_params.sched_priority = prio;
          if ((chk = pthread_attr_setschedparam(&attr, &prio_params))) {
            NSLog(@"Failed to set thread priority attribute (%d)", chk);
            schedfifo = false;
            continue;
          }
        }
        if (!(chk = pthread_create(pth, &attr, thread_fn, arg))) {
          outcome = true;
          break;
        }
        else if (schedfifo) {
          schedfifo = false;
          continue;
        }
        outcome = false;
        break;
      }
      else
        NSLog(@"Failed to set thread detach state (%d)", chk);
      pthread_attr_destroy(&attr);
    }
    else
      NSLog(@"Failed to initialise thread attributes (%d)", chk);

    if (schedfifo) {
      NSLog(@"Failed to start thread (sched_fifo) %d %s", chk, strerror(errno));
      schedfifo = false;
      continue;
    }
    NSLog(@"Failed to start thread (sched_other) %d %s", chk, strerror(errno));
    outcome = false;
    break;
  }
  return outcome;
}

void *CFASKPcmCaptureLoop(__unsafe_unretained ASKPcm *self) {

  if (PCMDEBUG)
    NSLog(@"Starting Capture Pcm");

  int err;

  err = snd_pcm_start(self->_pcm_handle);
  if (err < 0) {
    if (PCMDEBUG)
      NSLog(@"snd_pcm_start failed (%s)", snd_strerror(err));
    if (self->_capturethreaderrorblock)
      self->_capturethreaderrorblock(err);
    return (void*) ASKPcmThreadErrorExit;
  }

  while (self->_running) {

    void *buf = self->_capturebufferblock();
    snd_pcm_sframes_t nframes = self->_persize;
    err = snd_pcm_readi(self->_pcm_handle, buf, nframes);
    self->_alive = 1;
      
    if (err < 0) {
      if (PCMDEBUG)
        NSLog(@"read/write error %d (%s)", err, snd_strerror(err));
      err = snd_pcm_recover(self->_pcm_handle, err, 0);
      self->_xruncnt++;
      if (err < 0) {
        if (self->_capturethreaderrorblock)
          self->_capturethreaderrorblock(err);
        return (void*) ASKPcmThreadErrorExit;
      }
        
      snd_pcm_start(self->_pcm_handle);
      continue;         // TOM:??
    }

    if (self->_captureblock) {
      self->_captureblock(nframes);
    }

  }
  return NULL;
}

void *CFASKPcmPlaybackLoop(__unsafe_unretained ASKPcm *self) {

  if (PCMDEBUG)
    NSLog(@"Starting Playback Pcm");

  int err;

  int waiterrorcnt = 12;        // how many times to check for liveness using snd_pcm_wait

  err = snd_pcm_start(self->_pcm_handle);
  if (err < 0) {
    if (PCMDEBUG)
      NSLog(@"snd_pcm_start failed (%s)", snd_strerror(err));
    // do not abort ... this is normal
  }

  while (self->_running) {

    // playblock must deliever nframes or NULL buf
    snd_pcm_sframes_t nframes = self->_persize;

    // call the playblock to get the frames
    if (self->_playblock) {
      void *buf = self->_playblock(nframes);

      if (buf == NULL) {
        continue;               // nothing to play!
      }

      while (nframes > 0) {

#if 1
        if (waiterrorcnt > 0) {
          waiterrorcnt--;

          /* This block of code detects a bad ALSA handle but may cause problems on RPi
           * according to a note on the email thread.  TOM: I think this might be better
           * just done ONCE at the beginning as an infant mortality check - and maybe with 
           * proper closing if it is not a good FD.
           */
          int status = snd_pcm_wait(self->_pcm_handle, 1000);
          if (status == 0) {
            if (PCMDEBUG)
              NSLog(@"snd_pcm_wait - ALSA timeout on playback device");
            if (self->_playthreaderrorblock)
              self->_playthreaderrorblock(-EBADFD);
            self->_waiterror = 1;
            self->_running = 0;
            return (void*) ASKPcmThreadErrorExit;
          }
        }
#endif
        
        int wrote = snd_pcm_writei(self->_pcm_handle, buf, nframes);
        if (wrote >= 0) {
          if (wrote < nframes) {
            if (PCMDEBUG) {
              NSLog(@"playback callback failed: %d/%ld", wrote, nframes);
            }
            snd_pcm_prepare(self->_pcm_handle);
          }
          if (wrote > 0) {
            self->_alive = 1;
            nframes -= wrote;
            buf += (wrote * self->_formatsize);
          }
        }
        else {
          switch(wrote) {
          case -EBADFD:
            if (PCMDEBUG)
              NSLog(@"snd_pcm_writei: EBADFD - alsa audio not fit for writing");
            if (self->_playthreaderrorblock)
              self->_playthreaderrorblock(-EBADFD);
            self->_running = 0;
            return (void*) ASKPcmThreadErrorExit;

          case -EINTR: // interrupted system call
            snd_pcm_recover(self->_pcm_handle, -EINTR, /*silent*/ 1);
            self->_xruncnt++;
            break;

          case -EPIPE:
            snd_pcm_recover(self->_pcm_handle, -EPIPE, /*silent*/ 1);
            self->_xruncnt++;
            break;

          case -ESTRPIPE:
            snd_pcm_recover(self->_pcm_handle, -ESTRPIPE, /*silent*/ 1);
            self->_xruncnt++;
            break;

          case -EAGAIN:
            break;

          default:
            if (PCMDEBUG)
              NSLog(@"snd_pcm_writei: unknown code %d (%s)", wrote, snd_strerror(wrote));
            if (self->_playthreaderrorblock)
              self->_playthreaderrorblock(wrote);
            self->_running = 0;
            return (void*) ASKPcmThreadErrorExit;
          }
          wrote = 0;
        }
      }
    }

    // if our client has defined a post-playback block call that too
    if (self->_playcleanupblock) {
      self->_playcleanupblock();
    }

  }
  return NULL;
}


/*
 * Start the audio thread running for this PCM
 */

bool CFASKPcmStart(__unsafe_unretained ASKPcm *self, const char *threadname) {
  self->_running = 1;
  bool ok = 0;

  // NOTE: (void*(*)(void*)) is a cast to the type of a pthread startup routine

  if (self->_stream == SND_PCM_STREAM_PLAYBACK) {
   ok = startPThread(&(self->_pth),
                     (void*(*)(void*))CFASKPcmPlaybackLoop,
                     (__bridge void*) self,
                     true, 0, false, threadname);
  }
  else if (self->_stream == SND_PCM_STREAM_CAPTURE) {
   ok = startPThread(&(self->_pth),
                     (void*(*)(void*))CFASKPcmCaptureLoop,
                     (__bridge void*) self,
                     true, 0, false, threadname);
  }
  else {
    NSLog(@"Unknown stream value");
  }
  
  return ok;
}

/*
 * Stop the audio thread for this PCM
 */

void CFASKPcmStop(__unsafe_unretained ASKPcm *self) {

  void *ret = NULL;
  
  if (self->_pth != 0) {
    self->_running = 0;
    if (self->_alive != 0) {
      pthread_join(self->_pth, &ret);
      if (ret != NULL) {
        // NSLog(@"CFASKPcmStop - non-null thread exit");
      }
    }
    
    self->_pth = 0;
  }
}

- (BOOL) startThreadWithError:(NSError**)error {
  if (PCMDEBUG)
    NSLog(@"ASKPcm initThread: %@", _threadname);
  BOOL ok = CFASKPcmStart(self, [_threadname cStringUsingEncoding:NSASCIIStringEncoding]);

  if (ok == NO) {
    *error = [NSError errorWithASKPcmError:kASKPcmErrorThreadStartError
                                     str:@"ASKPcm cannot start thread"];
  }
  return ok;
}

- (void) onPlayback:(ASKPcmPlaybackBlock)block {
  _playblock = block;
}

- (void) onPlaybackCleanup:(ASKPcmPlaybackCleanupBlock)block {
  _playcleanupblock = block;
}

- (void) onPlaybackThreadError:(ASKPcmPlaybackThreadErrorBlock)block {
  _playthreaderrorblock = block;
}

- (void) onCaptureBuffer:(ASKPcmCaptureBufferBlock)block {
  _capturebufferblock = block;
}

- (void) onCapture:(ASKPcmCaptureBlock)block {
  _captureblock = block;
}

- (void) onCaptureThreadError:(ASKPcmCaptureThreadErrorBlock)block {
  _capturethreaderrorblock = block;
}




- (BOOL) stopAndClose {
  if (PCMDEBUG)
    NSLog(@"ASKPcm close: %@", _name);

  CFASKPcmStop(self);

  if (PCMDEBUG)
    NSLog(@"ASKPcm close/stopped: %@", _name);

  if (_pcm_handle != NULL) {    // is null if it never opened
    if (_stream == SND_PCM_STREAM_PLAYBACK) {
      if (_waiterror == 0)
        // if we errored out while waiting, then draining will not work either
        snd_pcm_drain(_pcm_handle);
    }
    int err = snd_pcm_close(_pcm_handle);
    if (err < 0) {
      if (PCMDEBUG) {
        NSLog(@"snd_pcm_close error:%d (%s)", err, snd_strerror(err));
      }
    }
    _pcm_handle = NULL;         // TOM: 2019-08-14
  }

  if (PCMDEBUG)
    NSLog(@"ASKPcm closed: %@", _name);
  return YES;
}

- (void) dealloc {
  if (PCMDEBUG)
    NSLog(@"ASKPcm dealloc");
}

@end
