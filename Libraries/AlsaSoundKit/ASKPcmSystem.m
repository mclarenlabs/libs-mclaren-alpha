/*
 * ASND System Implementation
 *
 */

#import "AlsaSoundKit/ASKPcmSystem.h"

static int CARDDEBUG = 1;
static int PCMDEBUG = 0;

/*
 * SND CTL CARD INFO
 */

@implementation ASKCtlCardInfo

- (id) init {
  if (self = [super init]) {
    _card_info = NULL;
    if (snd_ctl_card_info_malloc(&(_card_info)) < 0) {
      if (CARDDEBUG) {
        NSLog(@"snd_ctl_card_info_malloc error");
      }
    }
  }
  return self;
}

- (void) dealloc {
  if (_card_info != NULL) {
    snd_ctl_card_info_free(_card_info);
  }
  _card_info = NULL;
}

- (int) getCard {
  return snd_ctl_card_info_get_card(_card_info);
}

- (NSString*) getId {
  const char *s = snd_ctl_card_info_get_id(_card_info);
  return [NSString stringWithCString:s];
}

- (NSString*) getDriver {
  const char *s = snd_ctl_card_info_get_driver(_card_info);
  return [NSString stringWithCString:s];
}

- (NSString*) getName {
  const char *s = snd_ctl_card_info_get_name(_card_info);
  return [NSString stringWithCString:s];
}

- (NSString*) getLongname {
  const char *s = snd_ctl_card_info_get_longname(_card_info);
  return [NSString stringWithCString:s];
}

- (NSString*) getMixername {
  const char *s = snd_ctl_card_info_get_mixername(_card_info);
  return [NSString stringWithCString:s];
}

- (NSString*) getComponents {
  const char *s = snd_ctl_card_info_get_components(_card_info);
  return [NSString stringWithCString:s];
}
  
- (NSString*) description {

  NSString *s1 = [NSString stringWithFormat:@"CARD:%d, ID:%@, Name:%@.",
                           self.card, self.id, self.name];
  NSString *s2 = [NSString stringWithFormat:@"Driver:%@, longname:%@, mixername:%@, components:%@.",
                           self.driver, self.longname, self.mixername, self.components];
  NSArray *arr = @[s1, s2];
  return [arr componentsJoinedByString:@" "];
}

+ (NSArray*) getCards {

  snd_ctl_t *handle;
  int err;
  ASKCtlCardInfo *cardinfo = nil;
  NSMutableArray *cardinfos = [[NSMutableArray alloc] init];
  int card = -1;
  char name[32];

  if (snd_card_next(&card) < 0 || card < 0) {
    if (CARDDEBUG) {
      NSLog(@"no soundcards found...");
      goto end;
    }
  }

  while (card >= 0) {
    sprintf(name, "hw:%d", card);
    if ((err = snd_ctl_open(&handle, name, 0)) < 0) {
      if (CARDDEBUG) {
        NSLog(@"control open card=%i (%s)", card, snd_strerror(err));
      }
      goto end;
    }
    else {
      cardinfo = [[ASKCtlCardInfo alloc] init];
      if ((err = snd_ctl_card_info(handle, (cardinfo.card_info))) < 0) {
        if (CARDDEBUG) {
          NSLog(@"control hardware info (%i): %s", card, snd_strerror(err));
          snd_ctl_close(handle);
        }
        goto end;
      }
      [cardinfos addObject:cardinfo];
    }

    if (snd_card_next(&card) < 0) {
      goto end;
    }
  }

 end:
  return cardinfos;
}

@end

/*
 * SND PCM INFO
 */

@implementation ASKPcmInfo

- (id) init {
  if (self = [super init]) {
    _pcm_info = NULL;
    if (snd_pcm_info_malloc(&(_pcm_info)) < 0) {
      if (PCMDEBUG) {
        NSLog(@"snd_pcm_info_malloc error");
      }
    }
  }
  return self;
}

- (void) dealloc {
  if (_pcm_info != NULL) {
    snd_pcm_info_free(_pcm_info);
  }
  _pcm_info = NULL;
}

- (unsigned int) getDevice {
  return snd_pcm_info_get_device(_pcm_info);
}

- (void) setDevice:(unsigned int) device {
  snd_pcm_info_set_device(_pcm_info, device);
}

- (unsigned int) getSubdevice {
  return snd_pcm_info_get_subdevice(_pcm_info);
}

- (void) setSubdevice:(unsigned int) subdevice {
  snd_pcm_info_set_subdevice(_pcm_info, subdevice);
}

- (snd_pcm_stream_t) getStream {
  return snd_pcm_info_get_stream(_pcm_info);
}

- (void) setStream:(snd_pcm_stream_t) stream {
  snd_pcm_info_set_stream(_pcm_info, stream);
}

- (int) getCard {
  return snd_pcm_info_get_card(_pcm_info);
}

- (NSString*) getId {
  const char *s = snd_pcm_info_get_id(_pcm_info);
  return [NSString stringWithCString:s];
}

- (NSString*) getName {
  const char *s = snd_pcm_info_get_name(_pcm_info);
  return [NSString stringWithCString:s];
}

- (NSString*) getSubdeviceName {
  const char *s = snd_pcm_info_get_subdevice_name(_pcm_info);
  return [NSString stringWithCString:s];
}

- (snd_pcm_class_t) getClass {
  return snd_pcm_info_get_class(_pcm_info);
}

- (snd_pcm_subclass_t) getSubclass {
  return snd_pcm_info_get_subclass(_pcm_info);
}

- (unsigned int) getSubdevicesCount {
  return snd_pcm_info_get_subdevices_count(_pcm_info);
}

- (unsigned int) getSubdevicesAvail {
  return snd_pcm_info_get_subdevices_avail(_pcm_info);
}

- (snd_pcm_sync_id_t) getSync {
  return snd_pcm_info_get_sync(_pcm_info);
}

- (NSString*) description {

  NSString *s1 = [NSString stringWithFormat:@"PCMINFO Device:%u subdevice:%u stream:%@",
                           self.device, self.subdevice, [ASKPcmInfo streamToString:self.stream]];
  NSString *s2 = [NSString stringWithFormat:@"card:%d id:%@ name:%@ subdeviceName:%@",
                           self.card, self.id, self.name, self.subdeviceName];
  NSString *s3 = [NSString stringWithFormat:@"class:%@ subclass:%@",
                           [ASKPcmInfo classToString:self.klass], [ASKPcmInfo subclassToString:self.subclass]];
  NSString *s4 = [NSString stringWithFormat:@"count:%u avail:%u",
                           self.subdevicesCount, self.subdevicesAvail];
  NSArray *arr = @[s1, s2, s3, s4];
  return [arr componentsJoinedByString:@" "];
}

+ (NSString*) typeToString:(snd_pcm_type_t)type {
  const char *s = snd_pcm_type_name(type);
  return [NSString stringWithCString:s];
}


+ (NSString*) streamToString:(snd_pcm_stream_t)stream {
  const char *s = snd_pcm_stream_name(stream);
  return [NSString stringWithCString:s];
}

+ (NSString*) accessToString:(snd_pcm_access_t)access {
  const char *s = snd_pcm_access_name(access);
  return [NSString stringWithCString:s];
}

+ (NSString*) formatToString:(snd_pcm_format_t)format {
  const char *s = snd_pcm_format_name(format);
  return [NSString stringWithCString:s];
}

+ (NSString*) formatDescription:(snd_pcm_format_t)format {
  const char *s = snd_pcm_format_description(format);
  return [NSString stringWithCString:s];
}

+ (NSString*) subformatToString:(snd_pcm_subformat_t)subformat {
  const char *s = snd_pcm_subformat_name(subformat);
  return [NSString stringWithCString:s];
}

+ (NSString*) subformatDescription:(snd_pcm_subformat_t)subformat {
  const char *s = snd_pcm_subformat_description(subformat);
  return [NSString stringWithCString:s];
}

+ (snd_pcm_format_t) formatFromString:(NSString*)formatValue {
  const char *s = [formatValue cStringUsingEncoding:NSASCIIStringEncoding];
  return snd_pcm_format_value(s);
}

+ (NSString*) tstampModeToString:(snd_pcm_tstamp_t)mode {
  const char *s = snd_pcm_tstamp_mode_name(mode);
  return [NSString stringWithCString:s];
}

+ (NSString*) stateToString:(snd_pcm_state_t)state {
  const char *s = snd_pcm_state_name(state);
  return [NSString stringWithCString:s];
}


+ (NSString*) classToString:(snd_pcm_class_t)class {
  switch (class) {
  case SND_PCM_CLASS_GENERIC:
    return @"SND_PCM_CLASS_GENERIC";
  case SND_PCM_CLASS_MULTI:
    return @"SND_PCM_CLASS_MULTI";
  case SND_PCM_CLASS_MODEM:
    return @"SND_PCM_CLASS_MODEM";
  case SND_PCM_CLASS_DIGITIZER:
    return @"SND_PCM_CLASS_DIGITIZER";
  default:
    return @"SND_PCM_CLASS_UNKNOWN";
  }
}

+ (NSString*) subclassToString:(snd_pcm_subclass_t)subclass {
  switch (subclass) {
  case SND_PCM_SUBCLASS_GENERIC_MIX:
    return @"SND_PCM_SUBCLASS_GENERIC_MIX";
  case SND_PCM_SUBCLASS_MULTI_MIX:
    return @"SND_PCM_SUBCLASS_MULTI_MIX";
  default:
    return @"SND_PCM_SUBCLASS_UNKNOWN";
  }
}

+ (NSArray*) getPCMDevices:(ASKCtlCardInfo*)card stream:(snd_pcm_stream_t)stream andSubdevices:(BOOL)andsubs {

  snd_ctl_t *handle;
  int err;
  ASKPcmInfo *deviceinfo = nil;
  ASKPcmInfo *pcminfo = nil;
  NSMutableArray *pcminfos = [[NSMutableArray alloc] init];
  char name[32];

  snprintf(name, 32, "hw:%d", card.card);
  if ((err = snd_ctl_open(&handle, name, 0)) < 0) {
    if (PCMDEBUG) {
      NSLog(@"control open card=%i (%s)", card.card, snd_strerror(err));
    }
    goto end;
  }

  int device = -1;
  while (1) {

    if((err= snd_ctl_pcm_next_device(handle, &device)) < 0 ) {
      if (PCMDEBUG) {
        NSLog(@"snd_ctl_pcm_next_device device=%d (%s)", device, snd_strerror(err));
      }
      break;
    }

    if (device == -1) {
      break;
    }

    deviceinfo = [[ASKPcmInfo alloc] init];
    deviceinfo.device = device;
    deviceinfo.subdevice = 0;
    deviceinfo.stream = stream;

    // query the pcm devices
    err = snd_ctl_pcm_info(handle, deviceinfo.pcm_info);
    if (err < 0) {
      if (PCMDEBUG) {
        NSLog(@"snd_ctl_pcm_info device=%d (%s)", device, snd_strerror(err));
      }
      break;
    }

    [pcminfos addObject:deviceinfo];
  
    // get the count of subdevices
    int count = deviceinfo.subdevicesCount;
    // int avail = deviceinfo.subdevicesAvail;

    if (andsubs) {
      for (int i = 1; i < count; i++) {
        pcminfo = [[ASKPcmInfo alloc] init];
        // pcminfo.device = card.card;
        pcminfo.device = device;
        pcminfo.subdevice = i;
        pcminfo.stream = stream;

        // query the pcm devices
        err = snd_ctl_pcm_info(handle, pcminfo.pcm_info);

        if (err < 0) {
          if (PCMDEBUG) {
            NSLog(@"snd_ctl_pcm_info device=%d sub=%d (%s)", device, i, snd_strerror(err));
          }
          break;
        }

        [pcminfos addObject:pcminfo];
      }
    }
  }

 end:
  snd_ctl_close(handle);
  return pcminfos;
}


+ (NSArray*) getPCMDevicesHints:(snd_pcm_stream_t)stream {


  snd_pcm_t *handle;
  int err;
  void **hints, **n = NULL;
  const char *filter = (stream == SND_PCM_STREAM_CAPTURE) ? "Input" : "Output";
  ASKPcmInfo *pcminfo = nil;
  NSMutableArray *pcminfos = [[NSMutableArray alloc] init];

  if (snd_device_name_hint(-1, "pcm", &hints) < 0) {
    hints = NULL;
    goto end;
  }

  n = hints;
  while (*n != NULL) {
    const char *name = snd_device_name_get_hint(*n, "NAME");
    const char *desc = snd_device_name_get_hint(*n, "DESC");
    const char *ioid = snd_device_name_get_hint(*n, "IOID"); // "Input" or "Output"

    NSString *sname = [NSString stringWithCString:name];
    NSString *sdesc = (desc == NULL) ? @"" : [NSString stringWithCString:desc];
    NSString *sioid = (ioid == NULL) ? @"" : [NSString stringWithCString:ioid];
 
    if ((ioid != NULL) && (strcmp(filter, ioid) != 0)) {
      // skip it if it has IOID and it doesn't match
      goto nexthint;
    }

    // TOM: for learning
    if (PCMDEBUG) {
      NSLog(@"Found PCM Hint:%@", @[sname, sdesc, sioid]);
    }

    if ((err = snd_pcm_open(&handle, name, stream, 0)) < 0) {
      if (PCMDEBUG) {
        NSLog(@"snd_pcm_open (name:%s): %s", name, snd_strerror(err));
      }
      goto nexthint;
    }

    pcminfo = [[ASKPcmInfo alloc] init];

    // query the pcm devices
    err = snd_pcm_info(handle, pcminfo.pcm_info);
    if (err < 0) {
      if (PCMDEBUG) {
        NSLog(@"snd_pcm_info name:%s (%s)", name, snd_strerror(err));
      }
      goto nextpcm;
    }

    // keep only requested stream
    if (pcminfo.stream == stream) {
      [pcminfos addObject:pcminfo];
    }
    
  nextpcm:
    err = snd_pcm_close(handle);
    if (err < 0) {
      if (PCMDEBUG) {
        NSLog(@"snd_pcm_close error device:%s (%s)", name, snd_strerror(err));
      }
      break;
    }

  nexthint:
    n++;
  }
  
 end:
  if (hints != NULL) {
    snd_device_name_free_hint(hints);
    hints = NULL;
  }
  return pcminfos;
}

@end

/*
 * SND PCM ALIAS
 */
@implementation ASKPcmAlias

+ (NSArray*) getAliasesForCard:(int)card {

  int err;
  void **hints, **n = NULL;

  if ((err = snd_device_name_hint(card, "pcm", &hints)) < 0) {
    NSLog(@"getAlisesForCard:%d (%s)", err, snd_strerror(err));
    return nil;
  }

  NSMutableArray *aliases = [[NSMutableArray alloc] init];
  n = hints;
  while (*n != NULL) {
    const char *name = snd_device_name_get_hint(*n, "NAME");
    const char *desc = snd_device_name_get_hint(*n, "DESC");
    const char *ioid = snd_device_name_get_hint(*n, "IOID");

    NSString *sname = [NSString stringWithCString:name];
    NSString *sdesc = (desc == NULL) ? @"" : [NSString stringWithCString:desc];
    NSString *sioid = (ioid == NULL) ? @"" : [NSString stringWithCString:ioid];

    ASKPcmAlias *alias = [[ASKPcmAlias alloc] init];
    alias.name = sname;
    alias.desc = sdesc;
    alias.ioid = sioid;

    [aliases addObject:alias];

  nexthint:
    n++;
  }
  
  if (hints != NULL) {
    snd_device_name_free_hint(hints);
    hints = NULL;
  }
  return aliases;
}

- (NSString*) description {
  return [NSString stringWithFormat:@"Alias name:'%@' desc:'%@' ioid:'%@'",
                   self.name, self.desc, self.ioid];
}

@end

