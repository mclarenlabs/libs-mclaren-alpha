/** -*- mode:objc -*-
 *
 * ASKSeqEvent - ALSA Sequencer Events (alsa/seq_event.h)
 * 
 * (c) McLaren Labs 2022
 *
 */

#include <alsa/asoundlib.h>

#import <Foundation/Foundation.h>

/*
 * Sequencer Address
 */

@interface ASKSeqAddr : NSObject {
@public
  snd_seq_addr_t _addr;
}

@property (readwrite, getter=getClient, setter=setClient:) unsigned char client;
@property (readwrite, getter=getPort, setter=setPort:) unsigned char port;

- (NSString*) description; // pretty description

@end

/*
 * Sequencer Connection (subscription)
 */

@interface ASKSeqConnect : NSObject {
@public
  snd_seq_connect_t _connect;
}

@property (readwrite, getter=getSender, setter=setSender:) ASKSeqAddr *sender;
@property (readwrite, getter=getDest, setter=setDest:) ASKSeqAddr *dest;

- (NSString*) description; // pretty description

@end

/*
 * Sequencer Time Stamp
 */

@interface ASKSeqTimestamp : NSObject {
@public
  snd_seq_timestamp_t _timestamp;
}

@end

/*
 * Sequencer Event
 *
 * When initialized with a snd_seq_event_t, the struct is copied to the holder.
 * In addition, ext bytes are copied to an NSData which may be conveniently get
 * and set through a property.
 */

@interface ASKSeqEvent : NSObject {
  NSData *_data; // backing store for ext (sysex) data
@public
  snd_seq_event_t _ev;
}

@property (nonatomic, readwrite, getter=getExt, setter=setExt:) NSData *ext; // get and set ext data

- (id) initWithEvent:(snd_seq_event_t*)ev;
- (NSString*) description; // pretty description

@end

