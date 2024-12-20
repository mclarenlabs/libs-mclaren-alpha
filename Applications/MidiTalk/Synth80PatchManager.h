/** -*- mode:objc -*-
 *
 * Find patches in the system.
 *   {Library}/McLarenSynthKit/Samples/{name}.ext
 *   {Library}/Samples/{name}.ext
 *   {Bundle}/Resources/Samples/{name}.ext
 *
 * Note: heavily influenced by STScriptsManager
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>


@interface Synth80PatchManager : NSObject {
  NSArray *_patchesSearchPaths;
}

+ defaultManager;
+ knownFileTypes; // au, wav, oga, ogg, etc

- (NSArray*) patchesSearchPaths;
- (NSArray*) validPatchesSearchPaths;
- (NSString*) patchWithName:(NSString*)aString;

- (NSArray*) allPatches;

@end
