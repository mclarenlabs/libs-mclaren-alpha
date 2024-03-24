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
#import "McLarenSynthKit/sample/MSKSampleManager.h"

static MSKSampleManager *sharedSampleManager = nil;

@implementation MSKSampleManager

+ defaultManager {
  if (!sharedSampleManager) {
    sharedSampleManager = [[MSKSampleManager alloc] init];
  }
  return sharedSampleManager;
}

/* Sets samples search paths to defaults. Default paths are (in this order): 
 *   <gnustep library paths>/McLarenSynthKit/Samples/
 *   <gnustep library paths>/Samples/
 *  paths to Resource/Samples in all loaded bundles including the main bundle.
 */

- (void) setSampleSearchPathsToDefaults
{
    NSMutableArray *samplePaths = [NSMutableArray array];
    NSEnumerator   *enumerator;
    NSString       *path;
    NSArray        *paths;
    NSBundle       *bundle;
      
    paths = NSStandardLibraryPaths();

    enumerator = [paths objectEnumerator];

    while( (path = [enumerator nextObject]) )
    {
        path = [path stringByAppendingPathComponent:@"McLarenSynthKit"];
        path = [path stringByAppendingPathComponent:@"Samples"];
        [samplePaths addObject:path];
    }

    /* Add same, but without McLarenSynthKit (only Library/Samples) */
    enumerator = [paths objectEnumerator];

    while( (path = [enumerator nextObject]) ) {
        path = [path stringByAppendingPathComponent:@"Samples"];
        [samplePaths addObject:path];
    }
    
    enumerator = [[NSBundle allBundles] objectEnumerator];

    while( (bundle = [enumerator nextObject]) ) {
        path = [bundle resourcePath];
        path = [path stringByAppendingPathComponent:@"Samples"];
        [samplePaths addObject:path];
    }

    _sampleSearchPaths = [[NSArray alloc] initWithArray:samplePaths];
}

/**
    Retrun an array of sample search paths. Samples are searched 
    in Library/McLarenSynthKit/Samples/, 
    Library/Samples and in all loaded bundles in 
    <var>bundlePath</var>/Resources/Samples.
*/

- (NSArray *)sampleSearchPaths
{
    if(!_sampleSearchPaths) {
        [self setSampleSearchPathsToDefaults];
    }
    
    return _sampleSearchPaths;
}


/*
 * Return sample search paths that are valid.
 * That means that path exists and is a directory.
 */
- (NSArray *)validSampleSearchPaths
{
    NSMutableArray *scriptPaths = [NSMutableArray array];
    NSFileManager  *manager = [NSFileManager defaultManager];
    NSEnumerator   *enumerator;
    NSString       *path;
    NSArray        *paths;
    BOOL            isDir;
 
    paths = [self sampleSearchPaths];
    
    enumerator = [paths objectEnumerator];

    while( (path = [enumerator nextObject]) )
    {
        if( [manager fileExistsAtPath:path isDirectory:&isDir] && isDir )
        {
            NSLog(@"VALID %@", path);
            [scriptPaths addObject:path];
        }
    }

    return [NSArray arrayWithArray:scriptPaths];
}


/*
 *   Get a sample with name <var>aString</var>
 */

- (NSString*)sampleWithName:(NSString*)aString
{
  NSFileManager *manager = [NSFileManager defaultManager];
  NSEnumerator  *pEnumerator;
  NSEnumerator  *sEnumerator;
  NSString      *path;
  NSString      *file;
  NSString      *str;
  NSArray       *paths;

  paths = [self validSampleSearchPaths];

  pEnumerator = [paths objectEnumerator];

  while( (path = [pEnumerator nextObject]) ) {
    // NSLog(@"IN %@", path);
    sEnumerator = [[manager directoryContentsAtPath:path] objectEnumerator];
        
    while( (file = [sEnumerator nextObject]) ) {

      // NSDebugLLog(@"MSKSample", @"Sample %@", file);
      NSLog(@"Sample %@", file);

      str = [file lastPathComponent];
      str = [str stringByDeletingPathExtension];

      if([str isEqualToString:aString]) {
	return [path stringByAppendingPathComponent:file];
      }
    }
  }
  return nil;
}

+ (NSArray*) knownFileTypes {
  // this is a partial list of what libsndfile can support.  These are common.

  return @[
	   @"au", @"wav", @"oga", @"ogg",
	    @"aiff", @"snd", @"iff", @"sf", @"flac"
	   ];
}

- (NSArray *)_samplesAtPath:(NSString *)path
{
    NSMutableArray    *samples = [NSMutableArray array];
    NSFileManager     *manager = [NSFileManager defaultManager];
    NSEnumerator  *enumerator;
    NSSet	*types;
    NSString      *file;
    NSString      *ext;
    
    types = [NSSet setWithArray:[MSKSampleManager knownFileTypes]];

    enumerator = [[manager directoryContentsAtPath:path] objectEnumerator];

    while( (file = [enumerator nextObject]) )
    {

        ext = [file pathExtension];
        if( [types containsObject:ext] )
        {
            NSString *sample;
            NSLog(@"Found sample %@", file);

            sample = [path stringByAppendingPathComponent:file];
            [samples addObject:sample];
        }
    }

    return [NSArray arrayWithArray:samples];
}

/*
 * Return list of all samples
 */

- (NSArray *)allSamples
{
    NSMutableArray *scripts = [NSMutableArray array];
    NSEnumerator   *enumerator;
    NSString       *path;

    enumerator = [[self validSampleSearchPaths] objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
        [scripts addObjectsFromArray:[self _samplesAtPath:path]];
    }
    
    return [NSArray arrayWithArray:scripts];
}


@end

