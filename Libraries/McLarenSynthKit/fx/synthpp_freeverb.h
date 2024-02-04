/** -*- mode:c++; intent-tabs-mode:nil; tab-width:2; -*-
 *
 * Translate Freeverb algorithm from ObjC to C++
 *
 * Original
 *  Written by Jezar at Dreampoint, June 2000
 *  http://www.dreampoint.co.uk
 *  This code is public domain
 *
 * Copyright (c) McLaren Labs 2024
 */

#include "McLarenSynthKit/synthpp_common.h"

#define undenormalise(sample) if(((*(unsigned int*)&sample)&0x7f800000)==0) sample=0.0f

struct tuning {

  unsigned rate;
  unsigned period;

  int combtuningL[8];
  int combtuningR[8];
  int allpasstuningL[4];
  int allpasstuningR[4];

  int numcombs = 8;
  int numallpasses = 4;

  float muted = 0;
  float fixedgain = 0.015f;

  float scalewet = 3;
  float scaledry = 2;
  float scaledamp = 0.4f;
  float scaleroom = 0.28f;
  float offsetroom = 0.7f;

  float initialroom = 0.5f;
  float initialdamp = 0.5f;
  float initialwet = 1.0 / scalewet;
  float initialdry = 0;
  float initialwidth = 1.0;
  float initialmode = 0;
  float freezemode = 0.5f;
  int stereospread = 23;

  tuning(unsigned _rate, unsigned _period) {
    rate = _rate;
    period = _period;

    if (true || rate == 44000) {
      combtuningL[0] = 1116;
      combtuningL[1] = 1188;
      combtuningL[2] = 1277;
      combtuningL[3] = 1356;
      combtuningL[4] = 1422;
      combtuningL[5] = 1491;
      combtuningL[6] = 1557;
      combtuningL[7] = 1617;

      combtuningR[0] = 1116 + stereospread;
      combtuningR[1] = 1188 + stereospread;
      combtuningR[2] = 1277 + stereospread;
      combtuningR[3] = 1356 + stereospread;
      combtuningR[4] = 1422 + stereospread;
      combtuningR[5] = 1491 + stereospread;
      combtuningR[6] = 1557 + stereospread;
      combtuningR[7] = 1617 + stereospread;

      allpasstuningL[0] = 556;
      allpasstuningL[1] = 441;
      allpasstuningL[2] = 341;
      allpasstuningL[3] = 225;

      allpasstuningR[0] = 556 + stereospread;
      allpasstuningR[1] = 441 + stereospread;
      allpasstuningR[2] = 341 + stereospread;
      allpasstuningR[3] = 225 + stereospread;
    }
    else {
      float s = rate / 44000.0;

      combtuningL[0] = floor(s * 1116);
      combtuningL[1] = floor(s * 1188);
      combtuningL[2] = floor(s * 1277);
      combtuningL[3] = floor(s * 1356);
      combtuningL[4] = floor(s * 1422);
      combtuningL[5] = floor(s * 1491);
      combtuningL[6] = floor(s * 1557);
      combtuningL[7] = floor(s * 1617);

      combtuningR[0] = floor(s * 1116) + floor(s * stereospread);
      combtuningR[1] = floor(s * 1188) + floor(s * stereospread);
      combtuningR[2] = floor(s * 1277) + floor(s * stereospread);
      combtuningR[3] = floor(s * 1356) + floor(s * stereospread);
      combtuningR[4] = floor(s * 1422) + floor(s * stereospread);
      combtuningR[5] = floor(s * 1491) + floor(s * stereospread);
      combtuningR[6] = floor(s * 1557) + floor(s * stereospread);
      combtuningR[7] = floor(s * 1617) + floor(s * stereospread);

      // fprintf(stderr, "combtuningR[7]:%d\n", combtuningR[7]);

      allpasstuningL[0] = floor(s * 556);
      allpasstuningL[1] = floor(s * 441);
      allpasstuningL[2] = floor(s * 341);
      allpasstuningL[3] = floor(s * 225);

      allpasstuningR[0] = floor(s * 556) + floor(s * stereospread);
      allpasstuningR[1] = floor(s * 441) + floor(s * stereospread);
      allpasstuningR[2] = floor(s * 341) + floor(s * stereospread);
      allpasstuningR[3] = floor(s * 225) + floor(s * stereospread);

      // fprintf(stderr, "allpasstuningR[3]:%d\n", allpasstuningR[3]);
    }
  }
    

};

class allpass {

  unsigned rate;
  unsigned period;

  float *buffer = NULL;
  int bufsize = 0;
  int bufidx = 0;
  float feedback;

 public:
  allpass(unsigned _rate, unsigned _period, unsigned _bufsize) {
    rate = _rate;
    period = _period;
    bufsize = _bufsize;
    bufidx = 0;
    buffer = new float[_bufsize];
  }

  ~allpass() {
    delete[] buffer;
  }

  void setFeedback(float f) {
    feedback = f;
  }

  void mute() {
    // fprintf(stderr, "allpass-mute bufsize:%u\n", bufsize);
    for (int i = 0; i < bufsize; i++) {
      buffer[i] = 0;
    }
  }

  inline float process(float input) {
    float output;
    float bufout;

    bufout = buffer[bufidx];
    undenormalise(bufout);

    output = -input + bufout;
    buffer[bufidx] = input + (bufout*feedback);
    if (++bufidx >= bufsize) bufidx = 0;

    return output;
  }
};

class comb {

  unsigned rate;
  unsigned period;

  float *buffer = NULL;
  int bufsize = 0;
  int bufidx = 0;
  float filterstore;
  float feedback;
  float damp1;
  float damp2;

 public:
  comb(unsigned _rate, unsigned _period, unsigned _bufsize) {
    rate = _rate;
    period = _period;
    bufsize = _bufsize;
    bufidx = 0;
    filterstore = 0;
    buffer = new float[_bufsize];
  }

  ~comb() {
    delete[] buffer;
  }

  void setFeedback(float f) {
    feedback = f;
  }

  void setDamp(float val) {
    damp1 = val;
    damp2 = 1.0 - val;
  }

  void mute() {
    for (int i = 0; i < bufsize; i++) {
      buffer[i] = 0;
    }
  }

  inline float process(float input) {
    float output;

    output = buffer[bufidx];
    undenormalise(output);

    filterstore = (output * damp2) + (filterstore * damp1);
    undenormalise(filterstore);

    buffer[bufidx] = input + (filterstore * feedback);
    if (++bufidx >= bufsize) bufidx = 0;

    return output;
  }
};  



class freeverb {

protected:
  unsigned rate; // sample rate
  unsigned period; // period size

private:
  tuning *tun = NULL;
  comb *combL[8];
  comb *combR[8];
  allpass *allpassL[4];
  allpass *allpassR[4];

  float gain;
  float roomsize, roomsize1;
  float damp, damp1;
  float wet, wet1, wet2;
  float dry;
  float width;
  float mode;

public:
  freeverb(unsigned _rate, unsigned _period) {
    rate = _rate;
    period = _period;

    tun = new tuning(_rate, _period);

    for (int i = 0; i < tun->numcombs; i++) {
      combL[i] = new comb(rate, period, tun->combtuningL[i]);
      combR[i] = new comb(rate, period, tun->combtuningR[i]);
    }

    for (int i = 0; i < tun->numallpasses; i++) {
      allpassL[i] = new allpass(rate, period, tun->allpasstuningL[i]);
      allpassR[i] = new allpass(rate, period, tun->allpasstuningR[i]);
    }

    allpassL[0]->setFeedback(0.5f);
    allpassR[0]->setFeedback(0.5f);
    allpassL[1]->setFeedback(0.5f);
    allpassR[1]->setFeedback(0.5f);
    allpassL[2]->setFeedback(0.5f);
    allpassR[2]->setFeedback(0.5f);
    allpassL[3]->setFeedback(0.5f);
    allpassR[3]->setFeedback(0.5f);

    setWet(tun->initialwet);
    setRoomsize(tun->initialroom);
    setDry(tun->initialdry);
    setDamp(tun->initialdamp);
    setWidth(tun->initialwidth);
    setMode(tun->initialmode);

    // Buffer will be full of rubbish - so we MUST mute them
    mute();
  }

  ~freeverb() {
    // fprintf(stderr, "delete freeverb\n");
    for (int i = 0; i < tun->numcombs; i++) {
      delete combL[i];
      delete combR[i];
    }
    for (int i = 0; i < tun->numallpasses; i++) {
      delete allpassL[i];
      delete allpassR[i];
    }
  }

  void setRoomsize(float value) {
    roomsize = (value * tun->scaleroom) + tun->offsetroom;
    update();
  }

  float getRoomsize() {
    return (roomsize - tun->offsetroom) / tun->scaleroom;
  }

  void setDamp(float value) {
    damp = value * tun->scaledamp;
    update();
  }

  float getDamp() {
    return damp / tun->scaledamp;
  }

  void setWet(float value) {
    wet = value * tun->scalewet;
    update();
  }

  float getWet() {
    return wet / tun->scalewet;
  }

  void setDry(float value) {
    dry = value * tun->scaledry;
  }

  float getDry() {
    return dry / tun->scaledry;
  }

  void setWidth(float value) {
    width = value;
    update();
  }

  float getWidth() {
    return width;
  }

  void setMode(float value) {
    mode = value;
    update();
  }

  float getMode() {
    if (mode > tun->freezemode)
      return 1;
    else
      return 0;
  }

  // Recalculate internal values after a parameter change
  void update() {

    wet1 = wet * (width/2.0 + 0.5f);
    wet2 = wet * ((1-width) / 2.0);

    if (mode >= tun->freezemode) {
      roomsize1 = 1;
      damp1 = 0;
      gain = tun->muted;
    }
    else {
      roomsize1 = roomsize;
      damp1 = damp;
      gain = tun->fixedgain;
    }

    // fprintf(stderr, "update roomsize:%g roomsize1:%g damp1:%g wet:%g wet1:%g wet2:%g gain:%g\n",
    // roomsize, roomsize1, damp, wet, wet1, wet2, gain);

    for (int i = 0; i < tun->numcombs; i++) {
      combL[i]->setFeedback(roomsize1);
      combR[i]->setFeedback(roomsize1);
    }

    for (int i = 0; i < tun->numcombs; i++) {
      combL[i]->setDamp(damp1);
      combR[i]->setDamp(damp1);
    }
  }

  //
  // Reverberator Section
  //

  void mute() {
    if (mode >= tun->freezemode)
      return;

    for (int i = 0; i < tun->numcombs; i++) {
      combL[i]->mute();
      combR[i]->mute();
    }

    for (int i = 0; i < tun->numallpasses; i++) {
      allpassL[i]->mute();
      allpassR[i]->mute();
    }
  }
      

  inline void process_replace(float *inputL, float *inputR,
                                     float *outputL, float *outputR,
                                     long numsamples, int skip) {
    float outL, outR, input;
    int numcombs = tun->numcombs;
    int numallpasses = tun->numallpasses;

    while (numsamples-- > 0) {
      outL = outR = 0;
      input = (*inputL + *inputR) * gain;

      // Accumulate comb filters in parallel
      for (int i = 0; i < numcombs; i++) {
        outL += combL[i]->process(input);
        outR += combR[i]->process(input);
      }

      // Feed through allpasses in series
      for (int i = 0; i < numallpasses; i++) {
        outL = allpassL[i]->process(outL);
        outR = allpassR[i]->process(outR);
      }

      // Calculate output REPLACING anything already there
      *outputL = outL*wet1 + outR*wet2 + *inputL*dry;
      *outputR = outR*wet1 + outL*wet2 + *inputR*dry;

      // Increment sample pointers, allowing for interleave (if any)
      inputL += skip;
      inputR += skip;
      outputL += skip;
      outputR += skip;
    }
    
  }

  inline void process_mix(float *inputL, float *inputR,
                                 float *outputL, float *outputR,
                                 long numsamples, int skip) {
    float outL, outR, input;
    int numcombs = tun->numcombs;
    int numallpasses = tun->numallpasses;

    while (numsamples-- > 0) {
      outL = outR = 0;
      input = (*inputL + *inputR) * gain;

      // Accumulate comb filters in parallel
      for (int i = 0; i < numcombs; i++) {
        outL += combL[i]->process(input);
        outR += combR[i]->process(input);
      }

      // Feed through allpasses in series
      for (int i=0; i < numallpasses; i++) {
        outL = allpassL[i]->process(outL);
        outR = allpassR[i]->process(outR);
      }

      // Calculate output MIXING anything already there
      *outputL += outL*wet1 + outR*wet2 + *inputL*dry;
      *outputR += outR*wet1 + outL*wet2 + *inputR*dry;

      // Increment sample pointers, allowing for interleave (if any)
      inputL += skip;
      inputR += skip;
      outputL += skip;
      outputR += skip;
    }
  }

};

/*
 * Synthpp interface
 */

class synthpp_freeverb : public freeverb {

public:

  // kontrols
  k1Rate<double> dry;
  k1Rate<double> wet;
  k1Rate<double> roomsize;
  k1Rate<double> damp;

  synthpp_freeverb(unsigned _rate, unsigned _period) :
    freeverb(_rate, _period) {
  }

  void render(a2Rate<float> out, a2Rate<float> in) {

    dry.preamble();
    wet.preamble();
    roomsize.preamble();
    damp.preamble();

    setDry(dry.l / 100.0);
    setWet(wet.l / 100.0);
    setRoomsize(roomsize.l / 100.0);
    setDamp(damp.l / 100.0);

    // process body
    process_replace(in.addr, in.addr+1, out.addr, out.addr+1, period, 2);

  }

};

