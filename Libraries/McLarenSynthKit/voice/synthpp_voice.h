/** -*- mode:c++ -*-
 *
 * C++ implementation of synthesizer operators
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#include <math.h>
#include "McLarenSynthKit/synthpp_common.h"

struct gosc {

  // context properties
  unsigned rate;
  unsigned period;

  // primary configuration parameters
  k1Rate<enum msk_oscillator_type> osctype;

  // note properties
  int note;

  // controls
  k1Rate<int> octave;
  k1Rate<int> transpose;
  k1Rate<int> cents;
  k1Rate<double> bend;
  k1Rate<int> bendwidth;
  k1Rate<int> pw = 50.0;

  // oscillator state
  double freq;
  double phi = 0;
  double dphi = 0;
  double modulo = 0;
  double incr = 0;
  

  gosc( unsigned _rate, unsigned _period )
  {
    rate = _rate;
    period = _period;
    // fprintf(stderr, "gosc init\n");
  }

  void calcFreq() {
    double b = bend.l * bendwidth.l;
    freq = 440.0 * exp2((((note + transpose.l + b + (cents.l/100.0)) - 69) / 12.0)  + octave.l);
  }

  void calcDelta() {
    incr = freq / rate; // modulo incr
    dphi = (2 * M_PI) * incr; // radians incr
  }
    
  double compute_sound(double phi, double modulo, int osctype, double pw) {
    double sound;
    switch (osctype) {
    case MSK_OSCILLATOR_TYPE_NONE:
      sound = 0.0;
      break;
    case MSK_OSCILLATOR_TYPE_SIN:
      sound = SINFN(phi);
      break;
    case MSK_OSCILLATOR_TYPE_SAW:
      sound = 2.0*modulo - 1.0;
      break;
    case MSK_OSCILLATOR_TYPE_SQUARE:
      sound = ((modulo*100.0) > pw) ? -1.0 : 1.0;
      break;
    case MSK_OSCILLATOR_TYPE_TRIANGLE:
      sound = 2.0*fabs(2*modulo-1.0) - 1.0;
      break;
    case MSK_OSCILLATOR_TYPE_REVSAW:
      sound = 1.0 - 2.0*modulo;
      break;
    default:
      sound = 2*modulo -1.0;
      break;
    }

    return sound;
  }

  void incrModulo() {
    modulo += incr;
    if (modulo >= 1.0) {
      modulo -= 1.0;
    }
    phi += dphi;
    if (phi >= 2*M_PI) {
      phi -= 2*M_PI;
    }
  }
    
  /* called once per period */
  template <class ENV>
  void render(a2Rate<float> &out, ENV &env) {
    env.preamble();
    osctype.preamble();

    octave.preamble();
    transpose.preamble();
    cents.preamble();
    bend.preamble();
    bendwidth.preamble();
    pw.preamble();

    calcFreq();
    calcDelta();

    if (pw.l < 5) pw.l = 5;
    if (pw.l > 95) pw.l = 95;

    for (int i = 0; i < period; i++) {
      bend.fetch(i);
      env.fetch(i);

      double sound = compute_sound(phi, modulo, osctype.l, pw.l);
      incrModulo();

      // out.val = sound * env.val;
      out.l = sound * env.l;
      out.r = sound * env.r;
      out.store(i);
    }
    
  }

};

struct pdosc : public gosc {

  pdosc( unsigned _rate, unsigned _period) :
    gosc(_rate, _period)
  {
    // fprintf(stderr, "pdosc init\n");
  }

  // controls
  k1Rate<double> modulation = 3.5;

  double compute_sound(double phi, double modulo, int osctype, double pw) {

    // this is too much to call every sample
    while (modulo >= 1.0) {
      modulo -= 1.0;
    }
    while (phi >= 2*M_PI) {
      phi -= 2*M_PI;
    }
    
    double sound;

    switch (osctype) {
    case MSK_OSCILLATOR_TYPE_NONE:
      sound = 0.0;
      break;
    case MSK_OSCILLATOR_TYPE_SIN:
      sound = SINFN(phi);
      break;
    case MSK_OSCILLATOR_TYPE_SAW:
      sound = 2.0*modulo - 1.0;
      break;
    case MSK_OSCILLATOR_TYPE_SQUARE:
      sound = ((modulo*100.0) > pw) ? -1.0 : 1.0;
      break;
    case MSK_OSCILLATOR_TYPE_TRIANGLE:
      sound = 2.0*fabs(2*modulo-1.0) - 1.0;
      break;
    case MSK_OSCILLATOR_TYPE_REVSAW:
      sound = 1.0 - 2.0*modulo;
      break;
    default:
      sound = 2*modulo -1.0;
      break;
    }

    return sound;
  }


  /* called once per period */
  template <class ENV, class PD>
  void render(a2Rate<float> &out, ENV &env, PD &pd) {
    env.preamble();
    pd.preamble();

    osctype.preamble();

    octave.preamble();
    transpose.preamble();
    cents.preamble();
    bend.preamble();
    bendwidth.preamble();
    pw.preamble();
    modulation.preamble();

    calcFreq();
    calcDelta();

    if (pw.l < 5) pw.l = 5;
    if (pw.l > 95) pw.l = 95;

    for (int i = 0; i < period; i++) {
      bend.fetch(i);
      env.fetch(i);
      pd.fetch(i);

      float pdl = modulation.l * 3.5 * pd.l;
      float pdr = modulation.r * 3.5 * pd.r;

      double lsound = compute_sound(phi+pdl, modulo+pdl, osctype.l, pw.l);
      double rsound = compute_sound(phi+pdr, modulo+pdr, osctype.l, pw.r);

      incrModulo();

      out.l = lsound * env.l;
      out.r = rsound * env.r;
      out.store(i);
    }
    
  }

};

