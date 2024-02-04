/** -*- mode:objc -*-
 *
 * The OFifo (output fifo) is used to send messages from the Audio
 * Thread to the Audio Context dispatch queue where the messages are
 * relayed as callbacks.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/MSKContext.h"

/*
 * The types of messages
 */

typedef enum MSKOFifo_tag_enum : NSUInteger {

  MSK_OFIFO_TAG_AUDIOLEVELS = 0,
    MSK_OFIFO_TAG_ENVELOPE,
    MSK_OFIFO_TAG_THREADERROR,
    MSK_OFIFO_TAG_VAR,		// variable length payload
    MSK_OFIFO_TAG_MAX               // the last tag
    
} MSKOFifo_tag_t;

#define MSK_OFIFO_SOURCE_IDX_MAIN 0 // a special IDX for audio levels

typedef struct msk_ofifo_message_audiolevel_struct {
  double		rmsL;
  double		rmsR;
  double		absPeakL;
  double		absPeakR;  
} msk_ofifo_message_audiolevel_t;

typedef struct msk_ofifo_message_envelope_struct {
  unsigned int		gate;
  unsigned int		active;
  double		t;	// from start of seg?
  double		val;  	// 0..1.0
} msk_ofifo_message_envelope_t;

typedef struct msk_ofifo_message_threaderror_struct {
  int                   alsaerr;
} msk_ofifo_message_threaderror_t;

typedef struct msk_ofifo_message_var_struct {
  size_t		length;
  void			*bytes;
} msk_ofifo_message_var_t;

typedef struct msk_ofifo_message_struct {
  MSKOFifo_tag_t		tag;	// message type to select union
  unsigned int		idx;	// unit sending the message

  union {
    msk_ofifo_message_audiolevel_t	audiolevel;
    msk_ofifo_message_envelope_t	envelope;
    msk_ofifo_message_threaderror_t threaderror;
    msk_ofifo_message_var_t		var;
  } data;

} msk_ofifo_message_t;

@interface MSKOFifo : NSObject

- init;				// init, no parameters

BOOL CFMSKOFifo_avail(__unsafe_unretained MSKOFifo *ofifo);
BOOL CFMSKOFifo_avail_varlength(__unsafe_unretained MSKOFifo *ofifo, size_t varlength);
BOOL CFMSKOFifo_write_message(__unsafe_unretained MSKOFifo *ofifo, msk_ofifo_message_t msg);
BOOL CFMSKOFifo_read_message(__unsafe_unretained MSKOFifo *ofifo, msk_ofifo_message_t *msg, void *varbytes);

@end
