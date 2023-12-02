/** -*- mode:objc -*-
 *
 * This class exists to query the Alsa sound system for SEQ devices,
 * and provide them as a ASNDPortInfo array called 'portinfos'.
 *
 * (c) McLaren Labs 2022
 *
 */

#import "ASKSeq.h"

typedef void (^ASKSeqListClientCallbackBlock)(ASKSeqClientInfo*);
typedef void (^ASKSeqListPortCallbackBlock)(ASKSeqPortInfo*);

@interface ASKSeqList : NSObject

@property (readonly) NSMutableArray *clientinfos; // midi clients in the system
@property (readonly) NSMutableArray *portinfos; // midi ports in the system
@property (readonly) ASKSeq* seq;
@property (readonly) ASKSeqListener listener;

- (id) initWithSeq:(ASKSeq*)seq;

// private
// - (void) addClientInfo:(ASKSeqClientInfo*)info;
// - (void) addPortInfo:(ASKSeqPortInfo*)info;
// - (void) delClientInfo:(int)client;
// - (void) delPortInfo:(int)port forClient:(int)client;
// + (void) registerCallback:(ASKSeqList*)seqlist forSeq:(ASKSeq*)seq;

// convenience function
- (NSString*) portDisplayName:(ASKSeqPortInfo*)info;

- (void) onClientAdded:(ASKSeqListClientCallbackBlock)block;
- (void) onClientDeleted:(ASKSeqListClientCallbackBlock)block;
- (void) onPortAdded:(ASKSeqListPortCallbackBlock)block;
- (void) onPortDeleted:(ASKSeqListPortCallbackBlock)block;

// private properties
@property (readwrite, copy) ASKSeqListClientCallbackBlock clientAddedBlock;
@property (readwrite, copy) ASKSeqListClientCallbackBlock clientDeletedBlock;
@property (readwrite, copy) ASKSeqListPortCallbackBlock portAddedBlock;
@property (readwrite, copy) ASKSeqListPortCallbackBlock portDeletedBlock;

@end
