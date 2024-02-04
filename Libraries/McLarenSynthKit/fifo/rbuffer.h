/*
 * Sept 18, 2018
 * Based on portaudio.  Modified for atomics.
 *
 */

/////////////////////////////////////////////////////////////////////////////
// Ring buffer utility from the PortAudio project.
// Original licence information is listed below.
 
/*
 * Portable Audio I/O Library
 * Ring Buffer utility.
 *
 * Author: Phil Burk, http://www.softsynth.com
 * modified for SMP safety on Mac OS X by Bjorn Roche
 * modified for SMP safety on Linux by Leland Lucius
 * also, allowed for const where possible
 * Note that this is safe only for a single-thread reader and a
 * single-thread writer.
 *
 * This program uses the PortAudio Portable Audio Library.
 * For more information see: http://www.portaudio.com
 * Copyright (c) 1999-2000 Ross Bencina and Phil Burk
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 
/*
 * The text above constitutes the entire PortAudio license; however,
 * the PortAudio community also makes the following non-binding requests:
 *
 * Any person wishing to distribute modifications to the Software is
 * requested to send the modifications to the original developer so that
 * they can be incorporated into the canonical version. It is also
 * requested that these non-binding requests be included along with the
 * license above.
 */
 
#include "stdlib.h"
#include "string.h"
#include "stdatomic.h"

typedef struct rbuffer_t {
        size_t buffer_size;
        size_t write_index;
        size_t read_index;
        size_t big_mask;
        size_t small_mask;
        void *buffer;
} rbuffer_t;
 
static int rbuffer_init(rbuffer_t *rbuf, size_t num_of_bytes);
static void rbuffer_destroy(rbuffer_t *rbuf);
static void rbuffer_flush(rbuffer_t *rbuf);
static size_t rbuffer_write_available(rbuffer_t *rbuf);
static size_t rbuffer_read_available(rbuffer_t *rbuf);
static size_t rbuffer_write(rbuffer_t *rbuf, const void *data, size_t num_of_bytes);
static size_t rbuffer_read(rbuffer_t *rbuf, void *data, size_t num_of_bytes);
static size_t rbuffer_write_regions(rbuffer_t *rbuf, size_t num_of_bytes, void **data_ptr1, size_t *size_ptr1, void **data_ptr2, size_t *size_ptr2);
static size_t rbuffer_advance_write_index(rbuffer_t *rbuf, size_t num_of_bytes);
static size_t rbuffer_read_regions(rbuffer_t *rbuf, size_t num_of_bytes, void **data_ptr1, size_t *size_ptr1, void **data_ptr2, size_t *size_ptr2);
static size_t rbuffer_advance_read_index(rbuffer_t *rbuf, size_t num_of_bytes);
 
static int rbuffer_init(rbuffer_t *rbuf, size_t num_of_bytes)
{
        if (((num_of_bytes - 1) & num_of_bytes) != 0)
                return -1;                              /*Not Power of two. */
        rbuf->buffer_size = num_of_bytes;
        rbuf->buffer = (void *)malloc(num_of_bytes);
        rbuffer_flush(rbuf);
        rbuf->big_mask = (num_of_bytes *2) - 1;
        rbuf->small_mask = (num_of_bytes) - 1;
        return 0;
}
 
static void rbuffer_destroy(rbuffer_t *rbuf)
{
        if (rbuf->buffer)
                free(rbuf->buffer);
        rbuf->buffer = NULL;
        rbuf->buffer_size = 0;
        rbuf->write_index = 0;
        rbuf->read_index = 0;
        rbuf->big_mask = 0;
        rbuf->small_mask = 0;
}
 
static size_t rbuffer_read_available(rbuffer_t *rbuf)
{
        atomic_thread_fence(memory_order_seq_cst);
        return ((rbuf->write_index - rbuf->read_index) & rbuf->big_mask);
}
 
static size_t rbuffer_write_available(rbuffer_t *rbuf)
{
        return (rbuf->buffer_size - rbuffer_read_available(rbuf));
}
 
static void rbuffer_flush(rbuffer_t *rbuf)
{
        rbuf->write_index = rbuf->read_index = 0;
}
 
static size_t rbuffer_write_regions(rbuffer_t *rbuf, size_t num_of_bytes, void **data_ptr1, size_t *size_ptr1, void **data_ptr2, size_t *size_ptr2)
{
        size_t index;
        size_t available = rbuffer_write_available(rbuf);
        if (num_of_bytes > available)
                num_of_bytes = available;
        index = rbuf->write_index & rbuf->small_mask;
        if ((index + num_of_bytes) > rbuf->buffer_size) {
                size_t first_half = rbuf->buffer_size - index;
                *data_ptr1 = &rbuf->buffer[index];
                *size_ptr1 = first_half;
                *data_ptr2 = &rbuf->buffer[0];
                *size_ptr2 = num_of_bytes - first_half;
        } else {
                *data_ptr1 = &rbuf->buffer[index];
                *size_ptr1 = num_of_bytes;
                *data_ptr2 = NULL;
                *size_ptr2 = 0;
        }
        return num_of_bytes;
}
 
static size_t rbuffer_advance_write_index(rbuffer_t *rbuf, size_t num_of_bytes)
{
        atomic_thread_fence(memory_order_seq_cst);
        return rbuf->write_index = (rbuf->write_index + num_of_bytes) & rbuf->big_mask;
}
 
static size_t rbuffer_read_regions(rbuffer_t *rbuf, size_t num_of_bytes, void **data_ptr1, size_t *size_ptr1, void **data_ptr2, size_t *size_ptr2)
{
        size_t index;
        size_t available = rbuffer_read_available(rbuf);
        if (num_of_bytes > available)
                num_of_bytes = available;
        index = rbuf->read_index & rbuf->small_mask;
        if ((index + num_of_bytes) > rbuf->buffer_size) {
                size_t first_half = rbuf->buffer_size - index;
                *data_ptr1 = &rbuf->buffer[index];
                *size_ptr1 = first_half;
                *data_ptr2 = &rbuf->buffer[0];
                *size_ptr2 = num_of_bytes - first_half;
        } else {
                *data_ptr1 = &rbuf->buffer[index];
                *size_ptr1 = num_of_bytes;
                *data_ptr2 = NULL;
                *size_ptr2 = 0;
        }
        return num_of_bytes;
}
 
static size_t rbuffer_advance_read_index(rbuffer_t *rbuf, size_t num_of_bytes)
{
        atomic_thread_fence(memory_order_seq_cst);
        return rbuf->read_index = (rbuf->read_index + num_of_bytes) & rbuf->big_mask;
}
 
static size_t rbuffer_write(rbuffer_t *rbuf, const void *data, size_t num_of_bytes)
{
        size_t size1, size2, num_write;
        void *data1, *data2;
        num_write = rbuffer_write_regions(rbuf, num_of_bytes, &data1, &size1, &data2, &size2);
        if (size2 > 0) {
                memcpy(data1, data, size1);
                data = ((void *) data) + size1;
                memcpy(data2, data, size2);
        } else {
                memcpy(data1, data, size1);
        }
        rbuffer_advance_write_index(rbuf, num_write);
        return num_write;
}
 
static size_t rbuffer_read(rbuffer_t *rbuf, void *data, size_t num_of_bytes)
{
        size_t size1, size2, num_read;
        void *data1, *data2;
        num_read = rbuffer_read_regions(rbuf, num_of_bytes, &data1, &size1, &data2, &size2);
        if (size2 > 0) {
                memcpy(data, data1, size1);
                data = ((void *) data) + size1;
                memcpy(data, data2, size2);
        } else {
                memcpy(data, data1, size1);
        }
        rbuffer_advance_read_index(rbuf, num_read);
        return num_read;
}
 
