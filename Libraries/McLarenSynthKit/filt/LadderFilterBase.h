#pragma once

#ifndef LADDER_FILTER_BASE_H
#define LADDER_FILTER_BASE_H

#include "util.h"

class LadderFilterBase
{
public:
	
	LadderFilterBase(float sampleRate) : sampleRate(sampleRate) {}
	virtual ~LadderFilterBase() {}
	
	virtual float doFilter(float input) = 0;
	virtual void SetResonance(float r) = 0;
	virtual void SetCutoff(float c) = 0;
	
	float GetResonance() { return resonance; }
	float GetCutoff() { return cutoff; }
	
protected:
	
	float cutoff;
	float resonance;
	float sampleRate;
};

#endif
