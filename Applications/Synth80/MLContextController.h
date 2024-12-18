/** -*- mode: objc -*-
 *
 * Controller and visualizer for Context volume and RMS.
 *
 */

#import <AppKit/AppKit.h>
#import "McLarenSynthKit/model/MSKModulationModel.h"
#import "NSScrollSlider.h"
#import "MLVUMeterView.h"

@interface MLContextController : NSBox

- (id) initWithTitle:(NSString*)title;

@property NSTextField *volumeValue;
@property NSScrollSlider *volumeSlider;
@property MLVUMeterView *vuMeterView;

- (void) bindToContext:(MSKContext*)ctx;


@end
