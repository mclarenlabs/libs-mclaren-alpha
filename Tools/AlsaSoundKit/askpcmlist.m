/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * A very tiny example of using the lower-level ASK PCM interface to list
 * PCMs in the system.
 *
 */

#import <Foundation/Foundation.h>
#import "AlsaSoundKit/AlsaSoundKit.h"

int main(int argc, char *argv[]) {

  ASKError_linker_function(); // cause NSError category to be linked
  
  ASKPcmList *list = [[ASKPcmList alloc] initWithStream:SND_PCM_STREAM_PLAYBACK];
  for (ASKPcmListItem *item in list.pcmitems) {
    NSLog(@"device-name:%@ display-name:%@", 
            item.pcmDeviceName,
            item.pcmDisplayName);
  }
}
