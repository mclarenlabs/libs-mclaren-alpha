/** *-* mode; objc *-*
 *
 * Controller to hold MLSampleView and Capture Button
 *
 * McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "MLExpressiveButton.h"
#import "MLSampleView.h"

@interface MLSampleController : NSBox

// AppKit components
@property MLExpressiveButton *captureButton;
@property MLSampleView *sampleView;
@property NSMenu *contextMenu;

// MSK Audio components
@property (nonatomic, retain, strong) MSKContext *rec;

@property (nonatomic, retain, strong) MSKSample *recsample;
@property (nonatomic, retain, strong) MSKSampleRecorder *recorder;

// @property (nonatomic, retain, strong) MSKSample *playsample;

- (void) bindToModel:(MSKSampleModel*) sampleModel;

@end



