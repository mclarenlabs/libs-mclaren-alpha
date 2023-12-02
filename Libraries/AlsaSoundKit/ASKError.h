/** -*- mode:objc -*-
 *
 * Error codes and Error objects for Alsa Sound Kit
 *
 * (c) McLaren Labs 2022
 */

#import <Foundation/Foundation.h>

extern NSString *ASKAlsaErrorDomain; // errors from ALSA
extern NSString *ASKPcmErrorDomain;  // errors from ASK Pcm
extern NSString *ASKSeqErrorDomain;  // errors from ASK Seq

typedef NS_ENUM(NSInteger, ASKPcmErrorEnum) {
  kFoo = 1,
    kASKPcmErrorCannotOpenDevice,
    kASKPcmErrorCannotConfigureDevice,
    kASKPcmErrorIllegalState,
    kASKPcmErrorInternalConsistencyError,
    kASKPcmErrorThreadStartError,
};

typedef NS_ENUM(NSInteger, ASKSeqErrorEnum) {
  kSeqFoo = 1,
    kASKSeqErrorCannotOpenDevice,
    kASKSeqErrorCannotConfigureDevice,
    kASKSeqErrorIllegalState,
    kASKSeqErrorInternalConsistencyError
};

@interface NSError(ASKError)
+ (NSError*) errorWithASKAlsaError:(int)err; /* error from Alsa Error Num (negative) */
+ (NSError*) errorWithASKPcmError:(ASKPcmErrorEnum)err str:(NSString*)str; /* error from ASND enum */
+ (NSError*) errorWithASKPcmError:(ASKPcmErrorEnum)err str:(NSString*)str under:(NSError*)under;
+ (NSError*) errorWithASKSeqError:(ASKSeqErrorEnum)err str:(NSString*)str; /* error from ASND enum */
+ (NSError*) errorWithASKSeqError:(ASKSeqErrorEnum)err str:(NSString*)str under:(NSError*)under;
- (NSString*) mclarenDescription;
@end

void ASKError_linker_function(); // to force linkage of NSError category


