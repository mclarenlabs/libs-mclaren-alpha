/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * A very tiny example of using the lower-level ASKSeqList class to list
 * the clients and ports in the system.
 *
 */

#include <math.h>

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/AlsaSoundKit.h"

int main(int argc, char *argv[])
{
    ASKError_linker_function(); // cause NSError category to be linked

    ASKSeqOptions *options = [[ASKSeqOptions alloc] init];
    options->_sequencer_name = "askseqdump";

    NSError *error;
    ASKSeq *seq = [[ASKSeq alloc] initWithOptions:options error:&error];

    ASKSeqList *list = [[ASKSeqList alloc] initWithSeq:seq];
    for (ASKSeqClientInfo *c in list.clientinfos) {
        NSLog(@"Client:%@", c);
    }

    for (ASKSeqPortInfo *p in list.portinfos) {
        NSLog(@"Port:%@", p);
    }

    [list onClientAdded:^(ASKSeqClientInfo* c) {
        NSLog(@"Client Added - %@", c);
    }];

    [list onClientDeleted:^(ASKSeqClientInfo* c) {
        NSLog(@"Client Deleted - %@", c);
    }];

    [list onPortAdded:^(ASKSeqPortInfo* p) {
        NSLog(@"Port Added - %@", p);
    }];

    [list onPortDeleted:^(ASKSeqPortInfo* p) {
        NSLog(@"Port Deleted - %@", p);
    }];

    [[NSRunLoop mainRunLoop] run];
}
