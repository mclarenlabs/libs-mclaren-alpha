/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * The Output Fifo holds a reference to an rbuffer and implements CFunctions
 * for interacting with it
 *
 * Copyright (c) McLaren Labs 2024 
 */

#import <Foundation/Foundation.h>
#import "McLarenSynthKit/fifo/MSKOFifo.h"
#include "rbuffer.h"

@implementation MSKOFifo  {
  rbuffer_t	_rbuf;		// circular buffer struct, not a reference
}

- (id) init {
  if (self = [super init]) {
    rbuffer_init(&_rbuf, 4096*32);
  }
  return self;
}

/*
 * Determine if there is enough space available to safely send a message
 */

BOOL CFMSKOFifo_avail(__unsafe_unretained MSKOFifo *ofifo) {

  rbuffer_t *rbuf = &(ofifo->_rbuf);

  size_t size = sizeof(msk_ofifo_message_t);

  if (rbuffer_write_available(rbuf) >= size)
    return YES;
  else
    return NO;
}

/*
 * Determine if there is enough space for a VAR message with _varlength_ bytes
 */

BOOL CFMSKOFifo_avail_varlength(__unsafe_unretained MSKOFifo *ofifo, size_t varlength) {

  rbuffer_t *rbuf = &(ofifo->_rbuf);

  size_t size = varlength + sizeof(msk_ofifo_message_t);

  if (rbuffer_write_available(rbuf) >= size)
    return YES;
  else
    return NO;
}

/*
 * After determining there is enough space, safely write the message.
 * Pass the message by copying.  Just because.
 */

#if 0
BOOL CFMSKOFifo_write_message(__unsafe_unretained MSKOFifo *ofifo, msk_ofifo_message_t msg)
{
  rbuffer_t *rbuf = &(ofifo->_rbuf);
  size_t size;

  if (msg.tag != MSK_OFIFO_TAG_VAR)
    size = sizeof(msk_ofifo_message_t);
  else
    size = msg.data.var.length + sizeof(msk_ofifo_message_t);
  
  size_t cnt = 0;
  cnt += rbuffer_write(rbuf, &msg, sizeof(msk_ofifo_message_t));

  if (msg.tag == MSK_OFIFO_TAG_VAR)
    cnt += rbuffer_write(rbuf, msg.data.var.bytes, msg.data.var.length);

  return (cnt == size);
}
#endif

BOOL CFMSKOFifo_write_message(__unsafe_unretained MSKOFifo *ofifo, msk_ofifo_message_t msg)
{
  rbuffer_t *rbuf = &(ofifo->_rbuf);
  size_t size;
  size_t cnt = 0;

  if (msg.tag != MSK_OFIFO_TAG_VAR) {
    size = sizeof(msk_ofifo_message_t);
    cnt = rbuffer_write(rbuf, &msg, sizeof(msk_ofifo_message_t));
    return (cnt == size);
  }
  else {
    // concatenate msg and varbytes into a single buf before submitting to rbuf
    size = msg.data.var.length + sizeof(msk_ofifo_message_t);
    void *tempbuf = alloca(size);
    memcpy(tempbuf, &msg, sizeof(msk_ofifo_message_t));
    memcpy(tempbuf + sizeof(msk_ofifo_message_t), msg.data.var.bytes, msg.data.var.length);
    cnt = rbuffer_write(rbuf, tempbuf, size);
    return (cnt == size);
  }
}

/*
 * Read the message into the location given and return YES if read.  Else return NO.
 */

BOOL CFMSKOFifo_read_message(__unsafe_unretained MSKOFifo *ofifo, msk_ofifo_message_t *msg, void *varbytes)
{
  rbuffer_t *rbuf = &(ofifo->_rbuf);

  size_t cnt = rbuffer_read_available(rbuf);

  if (cnt >= sizeof(msk_ofifo_message_t)) {
    cnt = rbuffer_read(rbuf, msg, sizeof(msk_ofifo_message_t));

    if (msg->tag == MSK_OFIFO_TAG_VAR)
      cnt += rbuffer_read(rbuf, varbytes, msg->data.var.length);

    return YES;
  }
  else {
    return NO;
  }
}

- (void) dealloc {
  rbuffer_destroy(&_rbuf);
#if LOGDEALLOC
  NSLog(@"MSKOFifo dealloc");
#endif
}


@end
