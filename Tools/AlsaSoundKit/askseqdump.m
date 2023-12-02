/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * A very tiny example of using the lower-level ASKSeq class to
 * construct a command-line MIDI monitor.
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

    ASKSeqAddr *addr = [seq parseAddress:@"Launch:0" error:&error];
    [seq connectFrom:addr.client port:addr.port error:&error];

    [seq addListener:^(NSArray<ASKSeqEvent*> *events) {
        for (ASKSeqEvent* e in events) {
            NSLog(@"%@", e);
        }
    }];

    [[NSRunLoop mainRunLoop] run];
}
