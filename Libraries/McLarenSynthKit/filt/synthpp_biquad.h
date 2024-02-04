/** -*- mode:c++; intent-tabs-mode:nil; tab-width:2; -*-
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/synthpp_common.h"
#include "McLarenSynthKit/filt/Biquad.h"

/*
 * Synthpp interface
 */

static double biquadPitchShiftMultiplier(double semis) {
  if (semis == 0.0)
    return 1.0;

  return pow(2.0, semis/12.0);
}

class synthpp_biquad {

  unsigned rate;
  unsigned period;

  Biquad *bql;
  Biquad *bqr;

 public:
  synthpp_biquad(unsigned _rate, unsigned _period) {
    rate = _rate;
    period = _period;
    // Fc is rate/2, Q=sqrt(2), peakgaindb=0db
    bql = new Biquad(bq_type_lowpass, 0.5, 0.707, 0);
    bqr = new Biquad(bq_type_lowpass, 0.5, 0.707, 0);
  }

 public:
  k1Rate<double> fc;
  k1Rate<double> q;
  k1Rate<double> fcmod; 

  void makeLowpass() {
    // fc.val = 0.5; // rate/2
    fc.l = rate / 2.0;
    q.l = 0.707;
    fcmod.l = 0;

    bql->setBiquad(bq_type_lowpass, 0.5, 0.707, 0);   
    bqr->setBiquad(bq_type_lowpass, 0.5, 0.707, 0);
  }

  void setType(int type) {
    bql->setType(type);
    bqr->setType(type);
  }

  void render(a2Rate<float> out, a2Rate<float> in) {

    fc.preamble();
    q.preamble();
    fcmod.preamble();

    double thefc = fc.l * biquadPitchShiftMultiplier(fcmod.l);

    bql->setFc(thefc / rate);
    bqr->setFc(thefc / rate);

    bql->setQ(q.l);
    bqr->setQ(q.l);
    
    for (int i = 0; i < period; i++) {
      in.fetch(i);

      out.l = bql->process(in.l);
      out.r = bqr->process(in.r);
      out.store(i);
    }
  }

};

