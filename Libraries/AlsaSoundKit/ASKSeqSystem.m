/** -*- mode:objc -*-
 *
 * Objects to hold information about the sequencer clients and ports in the system.
 */

#import "AlsaSoundKit/ASKSeqSystem.h"

static int SEQINFODEBUG = 1;

@implementation ASKSeqClientInfo

- (id) init {
  if (self = [super init]) {
    int err = snd_seq_client_info_malloc(&(_client_info));
    if (err < 0) {
      if (SEQINFODEBUG) {
        fprintf(stderr, "snd_seq_client_info_malloc error (%s)\n",
                snd_strerror(err));
      }
    }
  }
  return self;
}


- (void) dealloc {
  if (_client_info != NULL) {
    snd_seq_client_info_free(_client_info);
  }
  _client_info = NULL;
}

- (int) getClient {
  return snd_seq_client_info_get_client(_client_info);
}

- (snd_seq_client_type_t) getType {
  return snd_seq_client_info_get_type(_client_info);
}

- (NSString*) getName {
  const char *s = snd_seq_client_info_get_name(_client_info);
  return [NSString stringWithCString:s];
}

- (int) getBroadcastFilter {
  return snd_seq_client_info_get_broadcast_filter(_client_info);
}

- (int) getErrorBounce {
  return snd_seq_client_info_get_error_bounce(_client_info);
}

- (BOOL) filterCheck:(int)eventType {
  return snd_seq_client_info_event_filter_check(_client_info, eventType);
}

// Override
- (ASKSeqClientInfo*) shallowcopy {
  // ASKSeqClientInfo *c = [self copy];
  // snd_seq_client_info_copy(_client_info, c.client_info);
  // return c;
  ASKSeqClientInfo *c = [[ASKSeqClientInfo alloc] init];
  snd_seq_client_info_copy(c.client_info, _client_info);
  return c;
}

- (NSString*) description {
  NSString *s1 = [NSString stringWithFormat:@"CLIENT:%d Name:%@ Type:%d",
                           self.client, self.name, self.type];
  NSArray *arr = @[s1];
  return [arr componentsJoinedByString:@" "];
}

// construct a client info with client=-1
+ none {
  ASKSeqClientInfo *info = [[ASKSeqClientInfo alloc] init];
  snd_seq_client_info_set_client(info.client_info, -1);
  return info;
}
  
@end

@implementation ASKSeqPortInfo

- (id) init {
  if (self = [super init]) {
    int err = snd_seq_port_info_malloc(&(_port_info));
    if (err < 0) {
      if (SEQINFODEBUG) {
        fprintf(stderr, "snd_seq_port_info_malloc error (%s)\n",
                snd_strerror(err));
      }
    }
  }
  return self;
}

- (void) dealloc {
  if (_port_info != NULL) {
    snd_seq_port_info_free(_port_info);
  }
  _port_info = NULL;
}

- (int) getClient {
  return snd_seq_port_info_get_client(_port_info);
}

- (int) getPort {
  return snd_seq_port_info_get_port(_port_info);
}

- (NSString*) getName {
  const char *s = snd_seq_port_info_get_name(_port_info);
  return [NSString stringWithCString:s];
}

- (unsigned int) getCapability {
  return snd_seq_port_info_get_type(_port_info);
}

- (unsigned int) getType {
  return snd_seq_port_info_get_type(_port_info);
}

- (int) getMidiChannels {
  return snd_seq_port_info_get_midi_channels(_port_info);
}

- (int) getMidiVoices {
  return snd_seq_port_info_get_midi_voices(_port_info);
}

- (int) getSynthVoices {
  return snd_seq_port_info_get_synth_voices(_port_info);
}

- (int) getReadUse {
  return snd_seq_port_info_get_read_use(_port_info);
}

- (int) getWriteUse {
  return snd_seq_port_info_get_write_use(_port_info);
}

- (ASKSeqPortInfo*) shallowcopy {
  // ASKSeqPortInfo *c = [self copy];
  // snd_seq_port_info_copy(_port_info, c.port_info);
  // return c;
  ASKSeqPortInfo *p = [[ASKSeqPortInfo alloc] init];
  snd_seq_port_info_copy(p.port_info, _port_info);
  return p;
}

- (NSString*) description {
  NSString *s1 = [NSString stringWithFormat:@"PORT Client:%d Port:%d Name:%@ cap:%u type:%u R:%d W:%d",
                           self.client, self.port, self.name, self.capability, self.type, self.readUse, self.writeUse];
  NSArray *arr = @[s1];
  return [arr componentsJoinedByString:@" "];
}

// construct a client info with client=-1
+ none:(int)client {
  ASKSeqPortInfo *info = [[ASKSeqPortInfo alloc] init];
  snd_seq_port_info_set_client(info.port_info, client);
  snd_seq_port_info_set_port(info.port_info, -1);
  return info;
}



@end
