/** -*- mode:objc -*-
 *
 * A scheduler subclassed so that it redirects its logger output to
 * a textview with pretty formatting.
 *
 * McLaren Labs 2024
 */

#import "PrettyScheduler.h"
#import "NSObject+MLBlocks.h"

static NSDictionary  *timestampTextAttributes;
static NSDictionary  *patternTextAttributes;
static NSDictionary  *msgTextAttributes;
static NSDictionary  *normalTextAttributes;

@implementation PrettyScheduler

- (id) init {
  if (self = [super init]) {

    NSArray *twoFonts = [self normalAndBoldFonts];
    NSFont *normalFont = twoFonts[0];
    NSFont *boldFont = twoFonts[1];
    
    timestampTextAttributes = [[NSDictionary alloc]
			    initWithObjectsAndKeys:
			      normalFont, NSFontAttributeName,
			    [NSColor redColor], NSForegroundColorAttributeName,
                                nil, nil];

    patternTextAttributes = [[NSDictionary alloc]
			    initWithObjectsAndKeys:
			      normalFont, NSFontAttributeName,
			    [NSColor purpleColor], NSForegroundColorAttributeName,
                                nil, nil];

    msgTextAttributes = [[NSDictionary alloc]
			    initWithObjectsAndKeys:
			      boldFont, NSFontAttributeName,
			    [NSColor blueColor], NSForegroundColorAttributeName,
                                nil, nil];

    normalTextAttributes = [[NSDictionary alloc]
			     initWithObjectsAndKeys:
			       normalFont, NSFontAttributeName,
			     [NSColor blackColor], NSForegroundColorAttributeName,
			     nil, nil];
  }
  return self;
}

/*
 * Find a font family with both Normal and Bold fonts.
 * Return the two fonts.
 */

- (NSArray*) normalAndBoldFonts {

  CGFloat fontSize = 12.0;
  NSFont *fixedFont = [NSFont userFixedPitchFontOfSize:fontSize];

  // look for these two fonts in the same family
  NSFont *normalFont;
  NSFont *boldFont;

  NSFontManager *fm = [NSFontManager sharedFontManager];
  NSArray *fontFamilies = [fm availableFontFamilies];

  for (NSString *family in fontFamilies) {
    // a font def is an array of 4 values
    // fontDef:("Arial-BoldMT", Bold, 9, 2)
    NSArray *fontDefs = [fm availableMembersOfFontFamily: family];


    normalFont = nil;
    boldFont = nil;

    for (NSArray *fontDef in fontDefs) {
      NSString *fontName = fontDef[0];
      NSFont *font = [NSFont fontWithName:fontName size:fontSize];
      NSFontTraitMask traits = [fm traitsOfFont:font];
      if (((traits & NSBoldFontMask) != 0) &&
	  ((traits & NSFixedPitchFontMask) != 0) &&
	  ((traits & NSItalicFontMask) == 0)) {
	// NSLog(@"found Bold Font:%@", font);
	boldFont = font;
      }
      if (((traits & NSBoldFontMask) == 0) &&
	  ((traits & NSFixedPitchFontMask) != 0) &&
	  ((traits & NSItalicFontMask) == 0)) {
	// NSLog(@"found Normal Font:%@", font);
	normalFont = font;
      }
    }

    // we have examined all of the fonts in the family
    if ((normalFont != nil) && (boldFont != nil)) {
      return @[normalFont, boldFont];
    }
  }

  // we did not find a font pair
  return @[fixedFont, fixedFont];
}

/*
 * Override the logger method of the Scheduler to write output to
 * a textView.
 */

- (void) logger:(NSString*)fmtTime pat:(NSString*)patname msg:(NSString*)msg {

    [self performBlockOnMainThread:^{
	NSAttributedString *astring;
	NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];

	// print the formatted time

	astring = [[NSAttributedString alloc] initWithString:fmtTime
						  attributes:timestampTextAttributes];
	[_textView.textStorage appendAttributedString:astring];


	// print the pattern name
	[_textView.textStorage appendAttributedString:space];
    
	astring = [[NSAttributedString alloc] initWithString:patname
						  attributes:patternTextAttributes];
	[_textView.textStorage appendAttributedString:astring];

	// print the message
	[_textView.textStorage appendAttributedString:space];

	astring = [[NSAttributedString alloc] initWithString:msg
						  attributes:msgTextAttributes];
	[_textView.textStorage appendAttributedString:astring];

	// newline
	astring = [[NSAttributedString alloc] initWithString:@"\n"
						  attributes:normalTextAttributes];
	[_textView.textStorage appendAttributedString:astring];
      }];

}

@end
