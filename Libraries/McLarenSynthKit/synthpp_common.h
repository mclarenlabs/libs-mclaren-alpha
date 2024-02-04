/** -*- mode:c++ -*-
 *
 * C++ implementation of synthesizer operators
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

/**
 * Definitions:
 *
 *   kontrol - a variable whose value is set asynchronously from the audio loop
 *     typically by a GUI, command plane or MIDI message.
 *
 *   audio buffer - an array of floats with left and right channels, whose length
 *     matches the number of frames in a period
 *
 *   constant - does not read memory to get its value
 *
 * Accessors are objects that reference audio buffers and kontrols by memory address
 * and transfer their values into and out-of the audio loop.  Accessors have a consistent
 * interface so that they may be used interchangably as templates in audio operator loops.
 *
 * The canonical audio loop structure is defined as follows.
 *
 * acc1.preamble();
 * acc2.preamble();
 * for (int i = 0; i < period; i++) {
 *   acc1.fetch(i);
 *   acc2.fetch(i);
 *   <function on accessed values>
 *   acc1.store(i);
 *   acc2.store(i);
 * }
 * acc1.postamble();
 * acc2.postamble();
 *
 */

/* stereo audio buffer accessor */
template <typename T>
struct a2Rate {
  T l, r;
  T *addr;

  a2Rate() {
    l = r = 0;
    addr = NULL;
  }

  a2Rate(T linitval, T rinitval, T *buffer) {
    l = linitval;
    r = rinitval;
    addr = buffer;
  }

  __attribute__((always_inline))
  void preamble() {
    l = addr[0];
    r = addr[1];
  }

  __attribute__((always_inline))
  void fetch(int i) {
    l = addr[2*i];
    r = addr[2*i + 1];
  }

  __attribute__((always_inline))
  void store(int i) {
    addr[2* i] = l;
    addr[2*i + 1] = r;
  }

  __attribute__((always_inline))
  void postamble() {
  }

};

/* mono audio buffer accessor - rarely used in McLaren */
template <typename T>
struct a1Rate { 
  T l, r;
  T *addr;

  a1Rate() {
    l = 0; r = 0;
    addr = NULL;
  }

  a1Rate(T initval, T *buffer) {
    l = initval;
    r = initval;
    addr = buffer;
  }

  __attribute__((always_inline))
  void preamble() {
    l = r = addr[0];
  }

  __attribute__((always_inline))
  void fetch(int i) {
    l = r = addr[i];
  }

  __attribute__((always_inline))
  void store(int i) {
    addr[i] = (l + r) / 2.0;
  }

  __attribute__((always_inline))
  void postamble() {
  }

};


/* k-rate accessor for framesize=1 */
template <typename T>
struct k1Rate {
  T l, r;
  T *addr;

  k1Rate() {
    l = r = (T) 0;
    addr = NULL;
  }

  k1Rate(T initval) {
    l = r = initval;
    addr = NULL;
  }

  void setRef(T &ref) {
    addr = &ref;
  }

  __attribute__((always_inline))
  void preamble() {
    if (addr != NULL)
      l = r = addr[0];
  }

  __attribute__((always_inline))
  void fetch(int i) {
    // no op
  }

  __attribute__((always_inline))
  void store(int i) {
    if (addr != NULL)
      addr[0] = (l + r) / 2.0;
  }

  __attribute__((always_inline))
  void postamble() {
  }

};


/* stereo k-rate accessor for framesize=2 */
template <typename T>
struct k2Rate {
  T l, r;
  T *addr;

  k2Rate() {
    addr = NULL;
  }

  k2Rate(T linitval, T rinitval) {
    l = linitval; r = rinitval;
    addr = NULL;
  }

  void setRef(T &ref) {
    addr = &ref;
  }

  __attribute__((always_inline))
  void preamble() {
    if (addr != NULL) {
      l = addr[0];
      r = addr[1];
    }
  }

  __attribute__((always_inline))
  void fetch(int i) {
    // no op
  }

  __attribute__((always_inline))
  void store(int i) {
    if (addr != NULL) {
      addr[0] = l;
      addr[1] = r;
    }
  }

  __attribute__((always_inline))
  void postamble() {
  }

};

/* stereo c-rate accessor - 1 values */
template <typename T>
struct c1Rate {
  T l, r;

  c1Rate() {
    l = r = 0;
  }

  c1Rate(T initval) {
    l = r = initval;
  }

  __attribute__((always_inline))
  void preamble() {
    // no op
  }

  __attribute__((always_inline))
  void fetch(int i) {
    // no op
  }

  __attribute__((always_inline))
  void store(int i) {
    // no op
  }

  __attribute__((always_inline))
  void postamble() {
  }

};


/* stereo c-rate accessor - 2 values */
template <typename T>
struct c2Rate {
  T l, r;

  c2Rate() {
    l = r = 0;
  }

  c2Rate(T linitval, T rinitval) {
    l = linitval; r = rinitval;
  }

  __attribute__((always_inline))
  void preamble() {
    // no op
  }

  __attribute__((always_inline))
  void fetch(int i) {
    // no op
  }

  __attribute__((always_inline))
  void store(int i) {
    // no op
  }

  __attribute__((always_inline))
  void postamble() {
  }

};


/* linear interopating from last value to new value over the range */
template <typename T>
struct k1iRate {
  unsigned period;
  T val;
  T newval;
  T oldval;
  T incr;
  T *addr;

  k1iRate(unsigned _period) {
    period = _period;
    addr = NULL;
  }

  k1iRate(unsigned _period, T initval) {
    period = _period;
    val = initval;
    addr = NULL;
  }

  void setRef(T &ref) {
    addr = &ref;
  }

  __attribute__((always_inline))
  void preamble() {
    if (addr != NULL) {
      newval = addr[0];
      incr = (newval - oldval) / period;
      // val = *addr;
    }
  }

  __attribute__((always_inline))
  void fetch(int i) {
    val += incr;
    // no op
  }

  __attribute__((always_inline))
  void store(int i) {
    if (addr != NULL)
      addr[i] = val;
    // *addr = val;
  }

  __attribute__((always_inline))
  void postamble() {
    oldval = val;
  }

};

