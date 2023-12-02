/*
 * This class exists to query the Alsa sound system for SEQ devices,
 * and provide them as a ASNDPortInfo array called 'portinfos'.
 */

#import "AlsaSoundKit/ASKSeqList.h"

static int SEQLISTDEBUG = 0;

@implementation ASKSeqList

- (id) init {
  if (self = [super init]) {
    _clientinfos = [[NSMutableArray alloc] init];
    _portinfos = [[NSMutableArray alloc] init];
  }
  return self;
}

- (id) initWithSeq:(ASKSeq*) seq {
  if (self = [super init]) {
    _seq = seq;
    _clientinfos =  [[NSMutableArray alloc] init];
    _portinfos = [[NSMutableArray alloc] init];
    [self refresh];
    [self registerCallback];
  }
  return self;
}

- (void) refresh {
  ASKSeqClientInfo *citer = [ASKSeqClientInfo none];
  while ([_seq nextClient:citer] >= 0) {
    if (SEQLISTDEBUG) {
      NSLog(@"GotClient:%@", citer);
    }
    ASKSeqClientInfo *clientinfo = [citer shallowcopy];
    [_clientinfos addObject:clientinfo];

    ASKSeqPortInfo *piter = [ASKSeqPortInfo none:citer.client];
    while ([_seq nextPort:piter] >= 0) {
      if (SEQLISTDEBUG) {
	NSLog(@"   GotPort:%@", piter);
      }
      // if (piter.type == SND_SEQ_USER_CLIENT && piter.readUse ==1) {
      ASKSeqPortInfo *portInfo = [piter shallowcopy];
      [_portinfos addObject:portInfo];
      //}
    }
  }
}

- (void) addClientInfo:(ASKSeqClientInfo*)info {
  [_clientinfos addObject:info];
  if (_clientAddedBlock) {
    _clientAddedBlock(info);
  }
}

- (void) addPortInfo:(ASKSeqPortInfo*)info {
  [_portinfos addObject:info];
  if (_portAddedBlock) {
    _portAddedBlock(info);
  }
}

- (void) delClientInfo:(int)client {
  ASKSeqClientInfo *clientDeleted = nil;
  int theindex = -1;
  int i = 0;
  for (ASKSeqClientInfo *c in _clientinfos) {
    if (c.client == client) {
      clientDeleted = c;
      theindex = i;
      break;
    }
    i++;
  }
  if (theindex != -1) {
    if (_clientDeletedBlock) {
      _clientDeletedBlock(clientDeleted);
    }
    [_clientinfos removeObjectAtIndex:theindex];
  }
}

- (void) delPortInfo:(int)port forClient:(int)client {
  ASKSeqPortInfo *portDeleted = nil;
  int theindex = -1;
  int i = 0;
  for (ASKSeqPortInfo *p in _portinfos) {
    if (p.client == client && p.port == port) {
      portDeleted = p;
      theindex = i;
      break;
    }
    i++;
  }
  if (theindex != -1) {
    if (_portDeletedBlock) {
      _portDeletedBlock(portDeleted);
    }
    [_portinfos removeObjectAtIndex:theindex];
  }
}

- (void) registerCallback {
  // __block ASKSeqList *bself = self;
  // 2018-02-09: weak seemed to work on Ubuntu16 but not RPi3Stretch
  // __weak ASKSeqList *bself = self;
  // RASPBERRYPI
  ASKSeqList *bself = self;

  _listener = ^(NSArray *events) {
    for (ASKSeqEvent *e in events) {
      // NSLog(@"ASEQLIST: %@", e);
      if ((e -> _ev.type) == SND_SEQ_EVENT_CLIENT_START) {
	int client = e -> _ev.data.addr.client;
	ASKSeqClientInfo *info = [bself.seq clientInfo:client];
	if (SEQLISTDEBUG) {
	  NSLog(@"ClientInfo:%@", info);
	}
	if (info != nil) {
	  [bself addClientInfo:info];
	}
      }
      if ((e -> _ev.type) == SND_SEQ_EVENT_CLIENT_EXIT) {
	int client = e -> _ev.data.addr.client;
	[bself delClientInfo:client];
      }
      if ((e -> _ev.type) == SND_SEQ_EVENT_PORT_START) {
	int client = e -> _ev.data.addr.client;
	int port = e -> _ev.data.addr.port;
	ASKSeqPortInfo *info = [bself.seq portInfo:port forClient:client];
	if (SEQLISTDEBUG) {
	  NSLog(@"PortInfo:%@", info);
	}
	if (info != nil) {
	  [bself addPortInfo:info];
	}
      }
      if ((e -> _ev.type) == SND_SEQ_EVENT_PORT_EXIT) {
	int client = e -> _ev.data.addr.client;
	int port = e -> _ev.data.addr.port;
	[bself delPortInfo:port forClient:client];
      }
    }
  };

  // make sure our seq is listening for system announcements
  BOOL ok;
  NSError *error;
  ok = [_seq connectFrom:SND_SEQ_CLIENT_SYSTEM port:SND_SEQ_PORT_SYSTEM_ANNOUNCE error:&error];
  [_seq addListener:_listener];
  (void) ok; // not used
}

- (void) deregisterCallback {
  [_seq delListener:_listener];
  _listener = nil;
}

- (void) dealloc {
  if (SEQLISTDEBUG) {
    NSLog(@"ASKSeqList dealloc");
  }
  [self deregisterCallback];
}

- (NSString*) portDisplayName:(ASKSeqPortInfo*)info {
  int client =  info.client;
  NSString *cname = @"?";
  NSString *pname = info.name;

  // find client name
  for (ASKSeqClientInfo* cinfo in _clientinfos) {
    if (client == cinfo.client) {
      cname = cinfo.name;
      break;
    }
  }

  return [NSString stringWithFormat:@"%@:%@", cname, pname];
}

- (void) onClientAdded:(ASKSeqListClientCallbackBlock)block {
  _clientAddedBlock = block;
}

- (void) onClientDeleted:(ASKSeqListClientCallbackBlock)block {
  _clientDeletedBlock = block;
}

- (void) onPortAdded:(ASKSeqListPortCallbackBlock)block {
  _portAddedBlock = block;
}

- (void) onPortDeleted:(ASKSeqListPortCallbackBlock)block {
  _portDeletedBlock = block;
}

@end
