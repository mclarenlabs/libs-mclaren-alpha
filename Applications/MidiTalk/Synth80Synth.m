/**
 * Play Synth80 patches in MidiTalk.
 * One instance of this class plays one patch or sound.
 *
 * McLaren Labs 2024
 *
 */

#import "Synth80Synth.h"

#import "Synth80PatchManager.h"
#import "Synth80Model.h"
#import "Synth80AlgorithmEngine.h"

@interface Synth80Synth()
@property (readwrite) MSKContext *ctx;
@property (readwrite) Synth80Model *model;
@property (readwrite) Synth80AlgorithmEngine *engine;
@end

@implementation Synth80Synth

- (id) init {
  [NSException raise:@"invalid init method" format:@"please call initWithCtx: for %@",
               NSStringFromClass([self class])];
  return nil;
}

- (id) initWithCtx:(MSKContext*)ctx {
  if (self = [super init]) {
    _ctx = ctx;
    _model = nil;
    _engine = [[Synth80AlgorithmEngine alloc] init];
  }
  return self;
}
    

- (NSString*) loadPatch:(NSString*)name {

  Synth80PatchManager *mgr = [Synth80PatchManager defaultManager];

  NSString *filepath = [mgr patchWithName:name];
  if (filepath == nil) {
    return nil;
  }

  NSFileManager *fileMgr = [NSFileManager defaultManager];
  NSData *data = [fileMgr contentsAtPath: filepath];
  _model = [NSKeyedUnarchiver unarchiveObjectWithData: data];
  return filepath;
 }

- (void) checkModel {
  if (_model == nil) {
    [NSException raise:@"Synth80Synth:no model loaded"
		format:@"please load a patch"];
  }
}

- (BOOL) noteOn:(unsigned)note vel:(unsigned)vel {
  [self checkModel];
  return [_engine noteOn:note vel:vel ctx:_ctx model:_model];
}

- (BOOL) noteOff:(unsigned)note vel:(unsigned)vel {
  [self checkModel];
  return [_engine noteOff:note vel:vel ctx:_ctx model:_model];
}


@end
