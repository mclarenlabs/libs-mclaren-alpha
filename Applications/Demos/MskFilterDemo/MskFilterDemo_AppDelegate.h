/*
 * ButtonSynth has three buttons that play sounds
 *
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "McLarenSynthKit/McLarenSynthKit.h"

#include "./GSTable-MLdecls.h"

@interface AppDelegate : NSObject<NSApplicationDelegate>

@property (nonatomic, retain, strong) NSMenu *mainMenu;
@property (nonatomic, retain, strong) NSWindow *win;
@property (nonatomic, retain, strong) NSSlider *filtertypeSlider;
@property (nonatomic, retain, strong) NSSlider *fcSlider;
@property (nonatomic, retain, strong) NSSlider *fcmodSlider;
@property (nonatomic, retain, strong) NSTextView *textview;

@property (nonatomic, retain, strong) MSKContext *ctx;
@property (nonatomic, retain, strong) MSKEnvelopeModel *envModel;
@property (nonatomic, retain, strong) MSKOscillatorModel *oscModel;
@property (nonatomic, retain, strong) MSKFilterModel *filtModel;


@end
