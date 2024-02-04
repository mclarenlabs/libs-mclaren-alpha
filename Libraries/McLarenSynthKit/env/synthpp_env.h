/** -*- mode:c++ -*-
 *
 * C++ implementation of synthesizer operators
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#include "McLarenSynthKit/synthpp_common.h"

struct baseEnv {

  // context properties
  unsigned rate;
  unsigned period;

  enum envState {
    ATTACK = 0, DECAY, SUSTAIN, RELEASE, DONE
  };

  uint64_t now = 0; // abs time in frames
  double tnow = 0; // current elapsed time in seconds
  double tstart = -1.0; // when the current envelope repetition started
  double t = 0; // envelope time relative to current repetition
  double trel = 0;  // when gate was released

  // envelope state
  enum envState adsr = ATTACK;
  bool gate = 1;
  bool reset = 0;
  bool abort = 0;
  double env = 0.0; // current value
  double envmax = 0.0; // max this period

public:

  baseEnv( unsigned _rate, unsigned _period) {
    rate = _rate;
    period = _period;

    doStart(0.0); // ready to start at time 0
  }
 
  // external configuration
  bool oneshot = 0;
  double shottime = 0.0;
  double gain = 1.0; // function of velocity

  k1Rate<double> attack = 0.01;
  k1Rate<double> decay = 0.8;
  k1Rate<double> sustain = 0.0;
  k1Rate<double> rel = 0.1;

  void noteOff() {
    gate = 0;
  }

  void noteAbort() {
    abort = 1;
  }

  void noteReset() {
    reset = 1;
  }

  double getT() {
    return t; // iteration time
  }

  double getEnv() {
    return env;
  }

  double getEnvMax() {
    return envmax;  // max this render period
  }

  bool isDone() {
    return (adsr == DONE);
  }

private:
    
  // start over
  void doStart(double tnow) {
    tstart = tnow;
    trel = 0;
    gate = 1;
    adsr = ATTACK;
  }

  void detectRelease() {
    if (adsr != RELEASE && gate == 0) {
      trel = tnow - tstart;
      adsr = RELEASE;
    }
  }

  virtual void computeControls() {
    fprintf(stderr, "base computeControls\n");
    // make use of the controls to configure for tick()
  }

  virtual void tick() {
    fprintf(stderr, "base tick\n");
    // put the code here
  }

public:
  void render(a2Rate<float> &out) {

    tnow = now * 1.0 / rate;
    t = tnow - tstart;     // compute the envelope-local time
    envmax = 0.0;

    attack.preamble();
    decay.preamble();
    sustain.preamble();
    rel.preamble();

    // truncate controls
    if (attack.l < 0.001) attack.l = 0.001;
    if (decay.l < 0.001) decay.l = 0.001;
    if (rel.l < 0.001) rel.l = 0.001;

    computeControls(); // do whatever with the controls

    // if is a oneshot, then begin release after time
    if (oneshot && (t > shottime)) {
      gate = 0;
    }

    // see if gate has been set to zero
    detectRelease();

    if (abort) {
      // quickly down to zero
      double incr = env / period;
      for (int i = 0; i < period; i++) {
        env -= incr;
        if (env < 0.0) env = 0.0;
        out.l = gain * env;
	out.r = out.l;
        out.store(i);
      }
      envmax = 0.0;
      adsr = DONE;
    }

    else if (reset && gate) {
      // start over from the beginning after quieting down
      reset = 0;
      envmax = env;

      double incr = env / period;
      for (int i = 0; i < period; i++) {
        env -= incr;
        if (env < 0.0) env = 0.0;
        out.l = gain * env;
	out.r = out.l;
        out.store(i);
      }

      doStart(tnow); // begin ATTACK again next time
    }

    else {
      // regular period
      for (int i = 0; i < period; i++) {
        tick();
        if (env > envmax) envmax = env;
        out.l = gain * env;
	out.r = out.l;
        out.store(i);
      }
    }

    // increment the current time in the envelope context
    now += period;

  }

};


struct linEnv : public baseEnv {

  // increments
  double aincr = 0.0;
  double dincr = 0.0;
  double rincr = 0.0;

 linEnv( unsigned _rate, unsigned _period) : baseEnv(_rate, _period) {
  }

  void computeControls() final {
    // convert to rates
    aincr = 1.0 / (attack.l * rate);
    dincr = 1.0 / (decay.l * rate);
    rincr = 1.0 / (rel.l * rate);
  }


  void tick() final {
    if (gate) {
      if (adsr == ATTACK) {
        env += aincr;
        if (env >= 1.0) adsr = DECAY;
      }
      else if (adsr == DECAY) {
        env -= dincr;
        if (env <= sustain.l) adsr = SUSTAIN;
      }
      else if (adsr == SUSTAIN) {
        // no op
      }
    }
    else {
      // then gate==0
      env -= rincr;
      if (env <= 0.0) {
        env = 0.0;
        adsr = DONE;
      }
    }
  }

};

struct expEnv : public baseEnv {

  float attackRate = 0;
  float decayRate = 0;
  float releaseRate = 0;
  float attackCoef = 0;
  float decayCoef = 0;
  float releaseCoef = 0;
  float sustainLevel = 0;

  float targetRatioA;
  float targetRatioDR;
  float attackBase;
  float decayBase;
  float releaseBase;
  

 expEnv( unsigned _rate, unsigned _period) : baseEnv(_rate, _period) {
    setAttackRate(0);
    setDecayRate(0);
    setReleaseRate(0);
    setSustainLevel(1.0);
    setTargetRatioA(0.3);
    setTargetRatioDR(0.0001);
  }

  void setAttackRate(float rate) {
    attackRate = rate;
    attackCoef = calcCoef(rate, targetRatioA);
    attackBase = (1.0 + targetRatioA) * (1.0 - attackCoef);
  }

  void setDecayRate(float rate) {
    decayRate = rate;
    decayCoef = calcCoef(rate, targetRatioDR);
    decayBase = (sustainLevel - targetRatioDR) * (1.0 - decayCoef);
  }

  void setReleaseRate(float rate) {
    releaseRate = rate;
    releaseCoef = calcCoef(rate, targetRatioDR);
    releaseBase = -targetRatioDR * (1.0 - releaseCoef);
  }

  float calcCoef(float rate, float targetRatio) {
    return (rate <= 0) ? 0.0 : exp(-log((1.0+targetRatio) / targetRatio) / rate);
  }

  void setSustainLevel(float level) {
    sustainLevel = level;
    decayBase = (sustainLevel - targetRatioDR) * (1.0 - decayCoef);
  }

  void setTargetRatioA(float targetRatio) {
    if (targetRatio < 0.000000001)
      targetRatio = 0.000000001; // -180dB
    targetRatioA = targetRatio;
    attackCoef = calcCoef(attackRate, targetRatioA);
    attackBase = (1.0 + targetRatioA) * (1.0 - attackCoef);
  }

  void setTargetRatioDR(float targetRatio) {
    if (targetRatio < 0.000000001)
      targetRatio = 0.000000001; // -180dB
    targetRatioDR = targetRatio;
    decayCoef = calcCoef(decayRate, targetRatioDR);
    releaseCoef = calcCoef(releaseRate, targetRatioDR);
    decayBase = (sustainLevel - targetRatioDR) * (1.0 - decayCoef);
    releaseBase = -targetRatioDR * (1.0 - releaseCoef);
  }

  void computeControls() final {
    // convert to rates
    setAttackRate(attack.l * rate); // samples
    setDecayRate(decay.l * rate);
    setReleaseRate(rel.l * rate);
    setSustainLevel(sustain.l);
  }


  void tick() final {
    if (gate) {
      if (adsr == ATTACK) {
        env = attackBase + env * attackCoef;
        if (env >= 1.0) {
          env = 1.0;
          adsr = DECAY;
        }
      }
      else if (adsr == DECAY) {
        env = decayBase + env * decayCoef;
        if (env <= sustain.l) {
          env = sustainLevel;
          adsr = SUSTAIN;
        }
      }
      else if (adsr == SUSTAIN) {
        // no op
      }
    }
    else {
      // then gate==0
      env = releaseBase + env * releaseCoef;
      if (env <= 0.0) {
        env = 0.0;
        adsr = DONE;
      }
    }
  }

};
