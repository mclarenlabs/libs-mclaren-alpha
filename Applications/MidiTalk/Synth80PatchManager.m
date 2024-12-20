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
#import "Synth80PatchManager.h"

static Synth80PatchManager *sharedPatchManager = nil;

@implementation Synth80PatchManager

+ defaultManager {
  if (!sharedPatchManager) {
    sharedPatchManager = [[Synth80PatchManager alloc] init];
  }
  return sharedPatchManager;
}

/* Sets patches search paths to defaults. Default paths are (in this order): 
 *   <gnustep library paths>/McLarenSynthKit/Patches/
 *   <gnustep library paths>/Patches/
 *  paths to Resource/Patches in all loaded bundles including the main bundle.
 */

- (void) setPatchesSearchPathsToDefaults
{
    NSMutableArray *patchPaths = [NSMutableArray array];
    NSEnumerator   *enumerator;
    NSString       *path;
    NSArray        *paths;
    NSBundle       *bundle;
      
    paths = NSStandardLibraryPaths();

    enumerator = [paths objectEnumerator];

    while( (path = [enumerator nextObject]) )
    {
        path = [path stringByAppendingPathComponent:@"McLarenSynthKit"];
        path = [path stringByAppendingPathComponent:@"Patches"];
        [patchPaths addObject:path];
    }

    /* Add same, but without McLarenSynthKit (only Library/Patches) */
    enumerator = [paths objectEnumerator];

    while( (path = [enumerator nextObject]) ) {
        path = [path stringByAppendingPathComponent:@"Patches"];
        [patchPaths addObject:path];
    }
    
    enumerator = [[NSBundle allBundles] objectEnumerator];

    while( (bundle = [enumerator nextObject]) ) {
        path = [bundle resourcePath];
        path = [path stringByAppendingPathComponent:@"Patches"];
        [patchPaths addObject:path];
    }

    _patchesSearchPaths = [[NSArray alloc] initWithArray:patchPaths];

    NSLog(@"PATCHES PATHS:");
    for (NSString *path in _patchesSearchPaths) {
      NSLog(@"    %@", path);
    }
}

/**
    Retrun an array of patch search paths. Patches are searched 
    in Library/McLarenSynthKit/Patches/, 
    Library/Patches and in all loaded bundles in 
    <var>bundlePath</var>/Resources/Patches.
*/

- (NSArray *)patchesSearchPaths
{
    if(!_patchesSearchPaths) {
        [self setPatchesSearchPathsToDefaults];
    }
    
    return _patchesSearchPaths;
}


/*
 * Return patch search paths that are valid.
 * That means that path exists and is a directory.
 */
- (NSArray *)validPatchesSearchPaths
{
    NSMutableArray *scriptPaths = [NSMutableArray array];
    NSFileManager  *manager = [NSFileManager defaultManager];
    NSEnumerator   *enumerator;
    NSString       *path;
    NSArray        *paths;
    BOOL            isDir;
 
    paths = [self patchesSearchPaths];
    
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
 *   Get a patch with name <var>aString</var>
 */

- (NSString*)patchWithName:(NSString*)aString
{
  NSFileManager *manager = [NSFileManager defaultManager];
  NSEnumerator  *pEnumerator;
  NSEnumerator  *sEnumerator;
  NSString      *path;
  NSString      *file;
  NSString      *str;
  NSArray       *paths;

  paths = [self validPatchesSearchPaths];

  pEnumerator = [paths objectEnumerator];

  while( (path = [pEnumerator nextObject]) ) {
    // NSLog(@"IN %@", path);
    sEnumerator = [[manager directoryContentsAtPath:path] objectEnumerator];
        
    while( (file = [sEnumerator nextObject]) ) {

      // NSDebugLLog(@"MSKPatch", @"Patch %@", file);
      NSLog(@"Patch %@", file);

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
  return @[ @"synth80" ];
}

- (NSArray *)_patchesAtPath:(NSString *)path
{
    NSMutableArray    *patches = [NSMutableArray array];
    NSFileManager     *manager = [NSFileManager defaultManager];
    NSEnumerator  *enumerator;
    NSSet	*types;
    NSString      *file;
    NSString      *ext;
    
    types = [NSSet setWithArray:[Synth80PatchManager knownFileTypes]];

    enumerator = [[manager directoryContentsAtPath:path] objectEnumerator];

    while( (file = [enumerator nextObject]) )
    {

        ext = [file pathExtension];
        if( [types containsObject:ext] )
        {
            NSString *patch;
            NSLog(@"Found patch %@", file);

            patch = [path stringByAppendingPathComponent:file];
            [patches addObject:patch];
        }
    }

    return [NSArray arrayWithArray:patches];
}

/*
 * Return list of all patches
 */

- (NSArray *)allPatches
{
    NSMutableArray *scripts = [NSMutableArray array];
    NSEnumerator   *enumerator;
    NSString       *path;

    enumerator = [[self validPatchesSearchPaths] objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
        [scripts addObjectsFromArray:[self _patchesAtPath:path]];
    }
    
    return [NSArray arrayWithArray:scripts];
}


@end

