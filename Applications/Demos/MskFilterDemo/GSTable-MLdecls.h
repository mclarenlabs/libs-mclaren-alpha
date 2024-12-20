/*
 * An abbreviated interface def that hides implementation details
 * so that an ARC module does not need to see the interior
 *
 *  NSView * __autoreleasing *_jails;
 *
 * implementation declaration.
 *
 * Excerpted from
 *    libs-gui/Headers/Additions/GNUstepGUI/{GSTable.h,GSHbox.h,GSVbox.h}
 *
 * McLaren Labs 2023
 *
 */


@interface GSTable: NSView

- (id) initWithNumberOfRows:(int)rows numberOfColumns:(int)columns;
- (id) init;

-(void) setBorder: (float)aBorder;
-(void) setXBorder: (float)aBorder;
-(void) setYBorder: (float)aBorder;
-(void) setMinXBorder: (float)aBorder;
-(void) setMaxXBorder: (float)aBorder;
-(void) setMinYBorder: (float)aBorder;
-(void) setMaxYBorder: (float)aBorder;

-(void) putView: (NSView *)aView
	  atRow: (int)row
	 column: (int)column;
-(void) putView: (NSView *)aView
	  atRow: (int)row
	 column: (int)column
    withMargins: (float)margins;
-(void) putView: (NSView *)aView
	  atRow: (int)row
	 column: (int)column
   withXMargins: (float)xMargins
       yMargins: (float)yMargins;
-(void) putView: (NSView *)aView
	  atRow: (int)row
	 column: (int)column
 withMinXMargin: (float)minXMargin   // Left Margin 
     maxXMargin: (float)maxXMargin   // Right Margin
     minYMargin: (float)minYMargin   // Lower Margin (Upper if flipped)
     maxYMargin: (float)maxYMargin;  // Upper Margin (Lower if flipped)

-(NSSize) minimumSize;
-(void) sizeToFit;

-(void) setXResizingEnabled: (BOOL)aFlag 
		  forColumn: (int)aColumn;
-(BOOL) isXResizingEnabledForColumn: (int)aColumn;
-(void) setYResizingEnabled: (BOOL)aFlag 
		     forRow: (int)aRow;
-(BOOL) isYResizingEnabledForRow: (int)aRow;

-(void) addRow;
-(void) addColumn;

-(int) numberOfRows;
-(int) numberOfColumns;

@end


@interface GSHbox: GSTable

-(id) init;
-(void) addView: (NSView *)aView;
-(void) addView: (NSView *)aView enablingXResizing: (BOOL)aFlag;
-(void) addView: (NSView *)aView withMinXMargin: (float)aMargin;
-(void) addView: (NSView *)aView
  enablingXResizing: (BOOL)aFlag
  withMinXMargin: (float)aMargin;
-(void) addSeparator;
-(void) addSeparatorWithMinXMargin: (float)aMargin;
-(void) setDefaultMinXMargin: (float)aMargin;
-(int) numberOfViews;

@end

@interface GSVbox: GSTable

-(id) init;
-(void) addView: (NSView *)aView;
-(void) addView: (NSView *)aView
enablingYResizing: (BOOL)aFlag;
-(void) addView: (NSView *)aView
 withMinYMargin: (float)aMargin;
-(void) addView: (NSView *)aView
enablingYResizing: (BOOL)aFlag
 withMinYMargin: (float)aMargin;
-(void) addSeparator;
-(void) addSeparatorWithMinYMargin: (float)aMargin;
-(void) setDefaultMinYMargin: (float)aMargin;
-(int) numberOfViews;

@end
