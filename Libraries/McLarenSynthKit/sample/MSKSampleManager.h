/** -*- mode:objc -*-
 *
 * Find samples in the system.
 *   {Library}/McLarenSynthKit/Samples/{name}.ext
 *   {Library}/Samples/{name}.ext
 *   {Bundle}/Resources/Samples/{name}.ext
 *
 * Note: heavily influenced by STScriptsManager
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>


@interface MSKSampleManager : NSObject {
  NSArray *_sampleSearchPaths;
}

+ defaultManager;
+ knownFileTypes; // au, wav, oga, ogg, etc

- (NSArray*) sampleSearchPaths;
- (NSArray*) validSampleSearchPaths;
- (NSString*) sampleWithName:(NSString*)aString;

- (NSArray*) allSamples;

@end
