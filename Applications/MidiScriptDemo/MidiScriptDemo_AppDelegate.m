#import "MidiScriptDemo_AppDelegate.h"
#import "MLExpressiveButton.h"
#import "STScriptingSupport.h"
#import "NSColor+ColorExtensions.h"
#import "LabelWithValue.h"

#import "StepTalk/StepTalk.h"

@implementation AppDelegate

- (id) init {
  if (self = [super init]) {

    if ([NSApp isScriptingSupported]) {
    NSLog(@"YES Scripting is supported.  calling initializeApplicationScripting");

    // This call sets up the scripting environment by calling the category method
    // added to NSApplication in the file
    //    ./STScriptingSupport.h
    // which is provided as part of the StepTalk distribution.
    [NSApp initializeApplicationScripting];

  }

  [self makeWindow]; // order matters to get NSWindows95InterfaceStyle menus
  [self makeMenu];
  }
  return self;
}


- (void) makeMenu {

  // The main menu - must create before [NSApp run] to get some default behavior
  self.mainMenu = [NSMenu new];

  // the [Info] item
  id<NSMenuItem> infoItem =
    [self.mainMenu addItemWithTitle: @"Info"
			    action: NULL
		     keyEquivalent: @""];

  NSMenu *infoMenu = [NSMenu new];
  [infoItem setSubmenu:infoMenu];
  infoItem.title = @"Info";

  [infoMenu addItemWithTitle:@ "About"
		      action:@selector(orderFrontStandardAboutPanel:)
	       keyEquivalent:@""];

#if 1
  // Note: the [NSApp scriptingMenu] installs itself as the main
  // menu and also does not work well with
  //   defaults write pad NSMenuInterfaceStyle NSWindows95InterfaceStyle
  // so we write it ourselves
  
  if([NSApp isScriptingSupported])
    {
      id<NSMenuItem> scriptingItem =
	[self.mainMenu addItemWithTitle: @"Scripting"
			action: NULL
		 keyEquivalent: @""];

      NSMenu *scriptingMenu = [NSMenu new];
      [scriptingMenu addItemWithTitle: @"Scripts panel ..."
			       action: @selector(orderFrontScriptsPanel:)
			keyEquivalent: @""];
      [scriptingMenu addItemWithTitle: @"Transcript ..."
			       action: @selector(orderFrontTranscriptWindow:)
			keyEquivalent: @""];

      [scriptingItem setSubmenu: scriptingMenu];
    }
  
#endif

  // the [Services] item
  id<NSMenuItem> servicesItem =
    [self.mainMenu addItemWithTitle: @"Services"
			    action: NULL
		     keyEquivalent: @""];
  NSMenu *servicesMenu = [NSMenu new];
  [servicesItem setSubmenu: servicesMenu];


  // the [Windows] item
  id<NSMenuItem> windowsItem =
    [self.mainMenu addItemWithTitle: @"Windows"
			    action: NULL
		     keyEquivalent: @""];
  NSMenu *windowsMenu = [NSMenu new];

  [windowsMenu addItemWithTitle:@"Arrange in Front"
			 action:@selector(arrangeInFront:)
		  keyEquivalent:@""];

  [windowsItem setSubmenu: windowsMenu];


  // The last two on the main menu
  [self.mainMenu addItemWithTitle:@ "Hide"
			   action:@selector(hide:)
		    keyEquivalent:@"h"];

  [self.mainMenu addItemWithTitle:@ "Quit"
		      action:@selector(terminate:)
	       keyEquivalent:@"q"];



  [NSApp setServicesMenu:servicesMenu];
  [NSApp setWindowsMenu:windowsMenu];
  [NSApp setMainMenu:self.mainMenu];
}

- (void) makeWindow {

  NSRect windowRect = NSMakeRect(0, 100, 1100, 300);
  self.mainWindow = [[NSWindow alloc]
		      initWithContentRect:windowRect
				styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable
				  backing:NSBackingStoreBuffered
				    defer:NO];
  self.mainWindow.delegate = self;

  self.mainWindow.title = @"MidiScriptDemo";
  // self.mainWindow.backgroundColor = [NSColor whiteColor];

  // automatically save/restore window position by AppKit
  [self.mainWindow setFrameAutosaveName:@"MidiScriptDemo"];

  [self.mainWindow makeKeyAndOrderFront:self];
  [self.mainWindow orderFrontRegardless];

}

- (void) makeToneGenerator {

  self.toneGen = [[ToneGenerator alloc] init];
  [self.toneGen openPcm:@"default"];
  [self.toneGen start];
}

- (void) makeButtons {

  NSFont *font = [NSFont userFixedPitchFontOfSize:24.0];

  NSRect rect1 = NSMakeRect(50, 50, 95, 45);
  self.but1 = [[MLExpressiveButton alloc] initWithFrame:rect1];
  [[self.but1 cell] setColor:[NSColor mcBlueColor]];
  self.but1.font = font;
  self.but1.title = @"but1";

  NSRect rect2 = NSMakeRect(50, 100, 95, 45);
  self.but2 = [[MLExpressiveButton alloc] initWithFrame:rect2];
  [[self.but2 cell] setColor:[NSColor mcGreenColor]];
  self.but2.font = font;
  self.but2.title = @"but2";

  NSRect rect3 = NSMakeRect(50, 150, 95, 45);
  self.but3 = [[MLExpressiveButton alloc] initWithFrame:rect3];
  [[self.but3 cell] setColor:[NSColor mcOrangeColor]];
  self.but3.font = font;
  self.but3.title = @"but3";

  NSRect rect4 = NSMakeRect(50, 200, 95, 45);
  self.but4 = [[MLExpressiveButton alloc] initWithFrame:rect4];
  [[self.but4 cell] setColor:[NSColor mcPurpleColor]];
  self.but4.font = font;
  self.but4.title = @"but4";

  // TOM: 2023-05-09 - this works - but does not add to a chain
  // [self.mainWindow makeFirstResponder: self.but6];

  // TOM: 2023-05-09 - implement the focus ring TAB
  [self.mainWindow.contentView addSubview:self.but1];
  [self.mainWindow.contentView addSubview:self.but2];
  [self.mainWindow.contentView addSubview:self.but3];
  [self.mainWindow.contentView addSubview:self.but4];
}

- (MLGauge*) makeGauge:(NSRect)rect
{

  MLGauge *gauge = [[MLGauge alloc] initWithFrame:rect];

  gauge.centerx = 50;
  gauge.centery = 50;
  gauge.radius = 40;
  gauge.degStart = 225;
  gauge.degEnd = -45;
  gauge.arcWidth = 16;
  gauge.userStart = 0.0;
  gauge.userEnd = 1.0;
  gauge.userProgress = 0.0;
  gauge.coarseAdj = 0.1;
  gauge.fineAdj = 0.01;

  gauge.font = [NSFont userFixedPitchFontOfSize:20.0];
  gauge.format = @"%.2g";
  gauge.legendFont = [NSFont userFixedPitchFontOfSize:10.0];
  gauge.legend = @"km/h";

  return gauge;


}

- (void) makeGauges
{

  NSRect rect1 = NSMakeRect(300, 150, 100, 100);
  self.gauge1 = [self makeGauge:rect1];
  self.gauge1.color = [NSColor mcBlueColor];

  NSRect rect2 = NSMakeRect(400, 150, 100, 100);
  self.gauge2 = [self makeGauge:rect2];
  self.gauge2.color = [NSColor mcGreenColor];

  // make this a midi controller CC8 0..127
  self.gauge2.legend = @"CC8";
  self.gauge2.format = @"%g";  
  self.gauge2.userStart = 0;
  self.gauge2.userEnd = 127;
  self.gauge2.coarseAdj = 1;
  self.gauge2.fineAdj = 1;
  
  NSRect rect3 = NSMakeRect(500, 150, 100, 100);
  self.gauge3 = [self makeGauge:rect3];
  self.gauge3.color = [NSColor mcOrangeColor];

  NSRect rect4 = NSMakeRect(600, 150, 100, 100);
  self.gauge4 = [self makeGauge:rect4];
  self.gauge4.color = [NSColor mcPurpleColor];

  [self.mainWindow.contentView addSubview:self.gauge1];
  [self.mainWindow.contentView addSubview:self.gauge2];
  [self.mainWindow.contentView addSubview:self.gauge3];
  [self.mainWindow.contentView addSubview:self.gauge4];
}

   
  

- (void) makePad {

  NSRect rect = NSMakeRect(850, 50, 200, 200);
  self.pad = [[MLPad alloc] initWithFrame:rect];
  self.pad.labelFont = [NSFont userFontOfSize:20];
  self.pad.xwid = 50;
  self.pad.ywid = 50;
  

  [self.mainWindow.contentView addSubview:self.pad];

}

- (void) makePiano 
{
  NSRect rect = NSMakeRect(200, 50, 15*40, 100);

  self.piano = [[MLPiano alloc] initWithFrame:rect];
  self.piano.totalWholeNotes = 15;
  
  [self.mainWindow.contentView addSubview:self.piano];

  // octave up/down and display
  NSButton *down = [NSButton new];
  [down setTitle:@"▼"];
  [down setFont:[NSFont userFontOfSize:20.0]];
  [down setFrame:NSMakeRect(200, 10, 25, 25)];
  [down setAction: @selector(octaveDownPressed:)];
  self.octaveDown = down;
  
  NSButton *up = [NSButton new];
  [up setTitle:@"▲"];
  [up setFont:[NSFont userFontOfSize:20.0]];
  [up setFrame:NSMakeRect(230, 10, 25, 25)];
  [up setAction: @selector(octaveUpPressed:)];
  self.octaveUp = up;
  
  LabelWithValue *lv = [LabelWithValue new];
  [lv setLabel:@"octave:"];
  [lv setValue:@"c4"];
  [lv setFrame:NSMakeRect(260, 10, 125, 25)];
  self.octaveLabel = lv;
  
  [self.mainWindow.contentView addSubview:up];
  [self.mainWindow.contentView addSubview:down];
  [self.mainWindow.contentView addSubview:lv];
}

- (void) octaveUpPressed:(id)sender
{
  int octave = self.piano.octave;
  if (octave < 8) 
    {
      octave +=1;
      self.piano.octave = octave;
      [self.octaveLabel setValue:[NSString stringWithFormat:@"c%d", octave]];
    }
}

- (void) octaveDownPressed:(id)sender
{
  int octave = self.piano.octave;
  if (octave > 0) 
    {
      octave -= 1;
      self.piano.octave = octave;
      [self.octaveLabel setValue:[NSString stringWithFormat:@"c%d", octave]];
    }
}

	  
/*
 * Application Delegate Callbacks
 */

- (void) applicationWillFinishLaunching: (NSNotification *) aNotification
{
}
  

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
  [self makeToneGenerator];
  [self makeButtons];
  [self makeGauges];
  [self makePad];
  [self makePiano];

  self.but1.nextKeyView = self.but2;
  self.but2.nextKeyView = self.but3;
  self.but3.nextKeyView = self.but4;
  self.but4.nextKeyView = self.gauge1;

  self.gauge1.nextKeyView = self.gauge2;
  self.gauge2.nextKeyView = self.gauge3;
  self.gauge3.nextKeyView = self.gauge4;
  self.gauge4.nextKeyView = self.pad;

  self.pad.nextKeyView = self.piano;

  self.piano.nextKeyView = self.octaveDown;
  self.octaveDown.nextKeyView = self.octaveUp;
  self.octaveUp.nextKeyView = self.but1;

  [self.mainWindow makeFirstResponder:self.but1];

  [NSApp orderFrontScriptsPanel:self];
  [NSApp orderFrontTranscriptWindow:self];

}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSNotification*)aNotification
{
  // NSLog(@"applicationShouldTerminate");
  return NSTerminateNow;
}

- (void) applicationWillTerminate:(NSNotification*)aNotification
{
  // NSLog(@"applicationWillTerminate");
}


@end
