/** -*- mode:objc -*-
 *
 * Objects to hold information about the sequencer clients and ports in the system.
 *
 * (c) McLaren Labs 2022
 *
 */

#include <alsa/asoundlib.h>

#import <Foundation/Foundation.h>

/*
 * This object holds a reference to the snd_seq_client_info_t opaque type.
 * ALSA creates and returns pointers to the opaque type.  The property
 * getters give convenient ObjC access to the field accessors.
 */

@interface ASKSeqClientInfo : NSObject

@property (readonly) snd_seq_client_info_t *client_info; // the underlying object

// from alsa/seq.h
@property (readonly, getter=getClient) int client;
@property (readonly, getter=getType) snd_seq_client_type_t type;
@property (readonly, getter=getName) NSString *name;
@property (readonly, getter=getBroadcastFilter) int broadcastFilter;
@property (readonly, getter=getErrorBounce) int errorBounce;
@property (readonly, getter=getEventFilter) NSData *eventFilter;

@property (readonly, getter=getNumPorts) int numPorts;
@property (readonly, getter=getEventLost) int eventLost;

// filter
- (BOOL) filterCheck:(int)eventType;

// construct a client info with client=-1.  Used with iterators.
+ none;

// make a copy of an info using the ALSA copy fun
- (ASKSeqClientInfo*) shallowcopy;

@end


/*
 * This object holds a reference to the snd_seq_port_info_t opaque type.
 * ALSA creates and returns pointers to the opaque type.  The property
 * getters give convenient ObjC access to the field accessors.
 */

@interface ASKSeqPortInfo : NSObject

@property (readonly) snd_seq_port_info_t *port_info; // the underlying object

@property (readonly, getter=getClient) int client;
@property (readonly, getter=getPort) int port;
//@property (readonly, getter=getAddr) AMIDIAddr *addr;
@property (readonly, getter=getName) NSString *name;
@property (readonly, getter=getCapability) unsigned int capability;
@property (readonly, getter=getType) unsigned int type;
@property (readonly, getter=getMidiChannels) int midiChannels;
@property (readonly, getter=getMidiVoices) int midiVoices;
@property (readonly, getter=getSynthVoices) int synthVoices;
@property (readonly, getter=getReadUse) int readUse;
@property (readonly, getter=getWriteUse) int writeUse;
// @property (readonly, getter=getPortSpecified) int portSpecified;
// @property (readonly, getter=getTimestamping) int timestamping;
// @property (readonly, getter=getTimestampReal) int timestampReal;
// @property (readonly, getter=getTimestampQueue) int timestampQueue;


// construct a client info with client=-1.  Used with iterators.
+ none:(int)client;

// make a copy of an info using the ALSA copy fun
- (ASKSeqPortInfo*) shallowcopy;


@end

