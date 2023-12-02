/*
 * This class exists to query the Alsa sound system for PCM devices,
 * and provide them as a ASKPcmListItem array called 'pcmitems'.  For
 * each of these, it implements logic for displaying the ASKPcmListItem to a
 * user, and for selecting a ASKPcmListItem as an input device.
 */

#import "AlsaSoundKit/ASKPcmSystem.h"
#import "AlsaSoundKit/ASKPcmList.h"
#import <Foundation/Foundation.h>

@implementation ASKPcmListItem

- (NSString*) pcmDeviceName {
  if (self.cardinfo == nil) {
    // if it is a software PCM, it has no card
    return self.pcminfo.name;
  }
  else {
    // if it is a hardware PCM, refer to it by its (card,device)
    NSString *name = [NSString stringWithFormat:@"hw:%d,%d", self.pcminfo.card, self.pcminfo.device];
    return name;
  }
}

- (NSString*) pcmDisplayName {

  // we display the same thing for HW and SW PCMs, for now

  if (self.cardinfo == nil) {
    return self.pcminfo.name;
  }
  else {
    return self.pcminfo.name;
  }
}

/*
 * The description of a PCMListItem prints out almost all of the interesting
 * things we know about it.
 */

- (NSString*) description {

  if (self.cardinfo == nil) {
    return self.pcminfo.name;
  }
  else {
    return [NSString stringWithFormat:@"(card:%d,%@,%@,%@)(pcm:%@,%@,%d)", self.cardinfo.card, self.cardinfo.id, self.cardinfo.name, self.cardinfo.longname, self.pcminfo.id, self.pcminfo.name, self.pcminfo.device];
  }
}

@end

@interface ASKPcmList()
@property (readwrite) snd_pcm_stream_t stream;
@end

@implementation ASKPcmList

- (id) initWithStream:(snd_pcm_stream_t)stream {
  if (self = [super init]) {
    _stream = stream;
    [self refresh];
  }
  return self;
}

- (void) refresh {
  NSMutableArray *allpcmitems = [[NSMutableArray alloc] init];


  NSArray *cards = [ASKCtlCardInfo getCards];
  for (ASKCtlCardInfo *card in cards) {
    NSArray *pcminfos = [ASKPcmInfo getPCMDevices:card stream:_stream andSubdevices:NO];
    for (ASKPcmInfo *pcminfo in pcminfos) {
      ASKPcmListItem *item = [[ASKPcmListItem alloc] init];
      item.cardinfo = card;
      item.pcminfo = pcminfo;
      [allpcmitems addObject:item];
    }
  }

  NSArray *hints = [ASKPcmInfo getPCMDevicesHints:_stream];
  for (ASKPcmInfo *pcminfo in hints) {
    if (pcminfo.card != -1) {
      break;
    }
    ASKPcmListItem *item = [[ASKPcmListItem alloc] init];
    item.pcminfo = pcminfo;
    [allpcmitems addObject:item];
  }

  _pcmitems = allpcmitems;
}
    
+ (NSString*) pcmDeviceName:(ASKPcmInfo*) pcminfo {
  if (pcminfo.card == -1) {
    return pcminfo.name;
  }
  else {
    NSString *name = [NSString stringWithFormat:@"hw:%d,%d", pcminfo.card, pcminfo.device];
    return name;
  }
}
    
+ (NSString*) pcmDisplayName:(ASKPcmInfo*) pcminfo {
  return pcminfo.name;
}

@end
