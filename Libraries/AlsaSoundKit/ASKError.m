/** -*- mode:objc -*-
 *
 * Error codes and Error objects for Alsa Sound Kit
 *
 * $copyright$
 */

#include <alsa/asoundlib.h>
#import "AlsaSoundKit/ASKError.h"



NSString *ASKAlsaErrorDomain = @"ASKAlsa";
NSString *ASKPcmErrorDomain = @"ASKPcm";
NSString *ASKSeqErrorDomain = @"ASKPcm";

@implementation NSError(ASKError)

+ (NSError*) errorWithASKAlsaError:(int)err {

  NSString *str = [NSString stringWithCString:snd_strerror(err)]; 
  NSError *nserr = [NSError errorWithDomain:ASKAlsaErrorDomain
                                       code:err
                                   userInfo:@{ NSLocalizedDescriptionKey: str }];
  return nserr;
}

+ (NSError*) errorWithASKPcmError:(ASKPcmErrorEnum)err str:(NSString*)str {

  NSError *nserr = [NSError errorWithDomain:ASKPcmErrorDomain
                                       code:err
                                   userInfo:@{ NSLocalizedDescriptionKey: str }];
  return nserr;
}


+ (NSError*) errorWithASKPcmError:(ASKPcmErrorEnum)err str:(NSString*)str under:(NSError*)under {

  NSError *nserr = [NSError errorWithDomain:ASKPcmErrorDomain
                                       code:err
                                   userInfo:@{ NSLocalizedDescriptionKey: str,
                                               NSUnderlyingErrorKey: under }
                    ];
  return nserr;
}

+ (NSError*) errorWithASKSeqError:(ASKSeqErrorEnum)err str:(NSString*)str {

  NSError *nserr = [NSError errorWithDomain:ASKSeqErrorDomain
                                       code:err
                                   userInfo:@{ NSLocalizedDescriptionKey: str }];
  return nserr;
}


+ (NSError*) errorWithASKSeqError:(ASKSeqErrorEnum)err str:(NSString*)str under:(NSError*)under {

  NSError *nserr = [NSError errorWithDomain:ASKSeqErrorDomain
                                       code:err
                                   userInfo:@{ NSLocalizedDescriptionKey: str,
                                               NSUnderlyingErrorKey: under }
                    ];
  return nserr;
}

- (NSString*) mclarenDescription {

  NSError *under;
  NSError *underunder;

  NSString *s = [NSString stringWithFormat:@"%@(%d) %@",
                          [self domain], [self code], [self localizedDescription]];

  under = [self userInfo][NSUnderlyingErrorKey];
  if (under != nil) {
    NSString *su = [NSString stringWithFormat:@"%@(%d) %@",
                          [under domain], [under code], [under localizedDescription]];
    s = [NSString stringWithFormat:@"%@\n  %@", s, su];
    
    underunder = [under userInfo][NSUnderlyingErrorKey];
    if (underunder != nil) {
      NSString *suu = [NSString stringWithFormat:@"%@(%d) %@",
                          [underunder domain], [underunder code], [underunder localizedDescription]];
      s = [NSString stringWithFormat:@"%@\n    %@", s, suu];
    
    }
  }
  return s;
}

@end

void ASKError_linker_function() {
}
