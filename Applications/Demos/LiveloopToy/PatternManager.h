/*
 * Managing the loading of samples and creating of patterns.
 *
 * McLaren Labs 2024
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

@class MSKScheduler;
@class MSKPattern;

@interface PatternManager : NSObject

@property (readwrite) MSKOscillatorModel *oscModel;
@property (readwrite) MSKEnvelopeModel *envModel;
@property (readwrite) MSKOscillatorModel *pdoscModel;
@property (readwrite) MSKModulationModel *pdmodModel;
@property (readonly) MSKContext *ctx;

@property (readonly) MSKScheduler *sched;

@property (readwrite) MSKSample *clap;
@property (readwrite) MSKSample *tom;
@property (readwrite) MSKSample *spat;
@property (readwrite) MSKSample *clack;

@property (readwrite) MSKSample *lowtom;
@property (readwrite) MSKSample *hitom;

// The patterns available
@property (readwrite) MSKPattern *pat1;
@property (readwrite) MSKPattern *pat2;
@property (readwrite) MSKPattern *pat3;
@property (readwrite) MSKPattern *pat4;
@property (readwrite) MSKPattern *pat5;
@property (readwrite) MSKPattern *pat6;

- (id) initWithCtx:(MSKContext*) ctx andSched:(MSKScheduler*)sched;

- (void) initialize;

@end
