/** -*- mode:objc -*-
 *
 * This class exists to query the Alsa sound system for PCM devices,
 * and provide them as a ASKPcmListItem array called 'pcmitems'.  For
 * each of these, it implements logic for displaying the ASKPcmListItem to a
 * user, and for selecting a PCMListItem as an input device.
 *
 * (c) McLaren Labs 2022
 *
 */

#import "ASKPcmSystem.h"

@interface ASKPcmListItem : NSObject

@property (readwrite) ASKCtlCardInfo *cardinfo;
@property (readwrite) ASKPcmInfo *pcminfo;

- (NSString*) pcmDeviceName; // what to pass to snd_pcm_open
- (NSString*) pcmDisplayName; // what to display to a person
@end

@interface ASKPcmList : NSObject

@property (readonly) NSArray<ASKPcmListItem*> *pcmitems; // the list of the pcmitems in the system

- (id) initWithStream:(snd_pcm_stream_t)stream;
- (void) refresh; // refresh the list of objects
+ (NSString*) pcmDeviceName:(ASKPcmInfo*) info;
+ (NSString*) pcmDisplayName:(ASKPcmInfo*) info;

@end
