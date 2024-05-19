/** -*- mode: objec -*-
 *
 * Synth80 Algorithm Engine
 *
 * for each algorithm defined, this class implements the noteOn and noteOff
 * behavior.  Generally each algorithm adds a new voice graph to the Context,
 * but the topology of the graph is determined by the algorithm type.
 *
 * McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/McLarenSynthKit.h"
#import "Synth80Model.h"
#import "Synth80AlgorithmModel.h"

@interface Synth80AlgorithmEngine : NSObject

- (BOOL) noteOn:(unsigned)note vel:(unsigned)vel ctx:(MSKContext*)ctx model:(Synth80Model*)model;

- (BOOL) noteOff:(unsigned)note vel:(unsigned)vel ctx:(MSKContext*)ctx model:(Synth80Model*)model;

@end
