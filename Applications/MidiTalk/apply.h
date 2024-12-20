/** -*- mode: objc -*-
 *
 * The callbacks from MLPiano, MLExpressiveButton and ASKSeqDispatcher
 * all invoke a selector on a target with one, two or three integer arguments.
 *
 * In order to have a single place to put in error checking and verbosity,
 * the functions in this file have been created.
 *
 */

#import <Foundation/Foundation.h>

void applyWithOneInt(id target, SEL selector, int val);
void applyWithTwoInts(id target, SEL selector, int val1, int val2);
void applyWithThreeInts(id target, SEL selector, int val1, int val2, int val3);




  


    
