/*
 * Obtain information about the Audio System - it's hardware and virtual devices.
 *
 *   - list cards, devices, get info 
 *   - open/close audio devices
 *   - manage audio threads and callbacks
 *
 */

#include <alsa/asoundlib.h>
#include <pthread.h>
#include <dispatch/dispatch.h>

#import <Foundation/Foundation.h>

/** -*- mode:objc -*-
 *
 * Wrap a SND CTL Card Info
 *
 * (c) McLaren Labs 2022
 */

@interface ASKCtlCardInfo : NSObject 

@property (readwrite) snd_ctl_card_info_t *card_info;

// from alsa/control.h
@property (readonly, getter=getCard) int card;
@property (readonly, getter=getId) NSString *id;
@property (readonly, getter=getDriver) NSString *driver;
@property (readonly, getter=getName) NSString *name;
@property (readonly, getter=getLongname) NSString *longname;
@property (readonly, getter=getMixername) NSString *mixername;
@property (readonly, getter=getComponents) NSString *components;

+ (NSArray*) getCards; // list of the cards in the system

@end


/*
 * Wrap a PCM info so that we can put it in lists and print it.
 */

@interface ASKPcmInfo : NSObject

@property (readwrite) snd_pcm_info_t *pcm_info;

@property (readwrite, getter=getDevice, setter=setDevice:) unsigned int device;
@property (readwrite, getter=getSubdevice, setter=setSubdevice:) unsigned int subdevice;
@property (readwrite, getter=getStream, setter=setStream:) snd_pcm_stream_t stream;
@property (readonly, getter=getCard) int card;
@property (readonly, getter=getId) NSString *id;
@property (readonly, getter=getName) NSString *name;
@property (readonly, getter=getSubdeviceName) NSString *subdeviceName;
@property (readonly, getter=getClass) snd_pcm_class_t klass;
@property (readonly, getter=getSubclass) snd_pcm_subclass_t subclass;
@property (readonly, getter=getSubdevicesCount) unsigned int subdevicesCount;
@property (readonly, getter=getSubdevicesAvail) unsigned int subdevicesAvail;
@property (readonly, getter=getSync) snd_pcm_sync_id_t sync;

// utilities for converting PCM details
+ (NSString*) typeToString:(snd_pcm_type_t)type;
+ (NSString*) streamToString:(snd_pcm_stream_t)stream;
+ (NSString*) accessToString:(snd_pcm_access_t)access;
+ (NSString*) formatToString:(snd_pcm_format_t)format;
+ (NSString*) formatDescription:(snd_pcm_format_t)format;
+ (NSString*) subformatToString:(snd_pcm_subformat_t)format;
+ (NSString*) subformatDescription:(snd_pcm_subformat_t)format;
+ (snd_pcm_format_t) formatFromString:(NSString*)formatValue;
+ (NSString*) tstampModeToString:(snd_pcm_tstamp_t)mode;
+ (NSString*) stateToString:(snd_pcm_state_t)state;                                               

+ (NSString*) classToString:(snd_pcm_class_t)klass;
+ (NSString*) subclassToString:(snd_pcm_subclass_t)subclass;

// system level methods
+ (NSArray*) getPCMDevices:(ASKCtlCardInfo*)card stream:(snd_pcm_stream_t)stream andSubdevices:(BOOL)andsubs;
+ (NSArray*) getPCMDevicesHints:(snd_pcm_stream_t)stream;

@end

/*
 * A PCM Alias is stored in the HINTS section.
 * These methods help looking them up.
 * Card=-1 is special for system/software pcms.
 */

@interface ASKPcmAlias : NSObject

@property (readwrite) NSString *name;
@property (readwrite) NSString *desc;
@property (readwrite) NSString *ioid;

+ (NSArray*) getAliasesForCard:(int)card;

@end

