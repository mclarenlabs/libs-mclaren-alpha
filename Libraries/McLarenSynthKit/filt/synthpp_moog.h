/** -*- mode:c++; intent-tabs-mode:nil; tab-width:2; -*-
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/synthpp_common.h"
#include "McLarenSynthKit/filt/OberheimVariationModel.h"

/*
 * Synthpp interface
 */

static double moogPitchShiftMultiplier(double semis) {
  if (semis == 0.0)
    return 1.0;

  return pow(2.0, semis/12.0);
}

class synthpp_moog {

  unsigned rate;
  unsigned period;

  OberheimVariationMoog *moogl;
  OberheimVariationMoog *moogr;

 public:
  synthpp_moog(unsigned _rate, unsigned _period) {
    rate = _rate;
    period = _period;
    // Fc is rate/2, Q=sqrt(2), peakgaindb=0db
    moogl = new OberheimVariationMoog(rate);
    moogr = new OberheimVariationMoog(rate);
  }

 public:
  k1Rate<double> fc;
  k1Rate<double> q;
  k1Rate<double> fcmod;

  void setTanh(int hasTanh) {
    moogl->setTanh(hasTanh);
    moogr->setTanh(hasTanh);
  }

  void render(a2Rate<float> out, a2Rate<float> in) {

    fc.preamble();
    q.preamble();
    fcmod.preamble();

    double thefc = fc.l * moogPitchShiftMultiplier(fcmod.l);

    moogl->SetCutoff(thefc);
    moogr->SetCutoff(thefc);

    moogl->SetResonance(q.l); // should be range 1..10
    moogr->SetResonance(q.l);
    
    for (int i = 0; i < period; i++) {
      in.fetch(i);

      out.l = moogl->doFilter(in.l);
      out.r = moogl->doFilter(in.r);
      out.store(i);
    }
  }

};

