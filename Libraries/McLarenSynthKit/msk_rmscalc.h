/*
 * A set of inline functions for calculating rms/peak while iterating
 * through a sample buffer.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

typedef struct msk_rmscalc_struct {

  double rmsPeakL, rmsPeakR;
  double absPeakL, absPeakR;
  double rmsL, rmsR;

} msk_rmscalc_t;

/*
 * Use this way:
 *
 * msk_rmscalc_t rms;
 * msk_rmscalc_clear(&rms);
 * for (i = 0; i < nframes; i++) {
 *   double left = ...
 *   double right = ...
 *   msk_rmscalc_accum(&rms, left, right)
 * }
 * msk_rms_calc_total(&rms, nframes);
 *
 */


static inline void msk_rmscalc_clear(msk_rmscalc_t *rms)
{
  // very quiet is not quite zero
  rms->rmsPeakL = 1e-12f;
  rms->rmsPeakR = 1e-12f;
  rms->absPeakL = 1e-12f;
  rms->absPeakR = 1e-12f;
  rms->rmsL = 0.0;
  rms->rmsR = 0.0;
}

static inline void msk_rmscalc_accum(msk_rmscalc_t *rms, double left, double right)
{
  double absval;
  
  rms->rmsPeakL += (left * left);
  rms->rmsPeakR += (right * right);

  absval = fabs(left);
  rms->absPeakL = (absval > rms->absPeakL) ? absval : rms->absPeakL;

  absval = fabs(right);
  rms->absPeakR = (absval > rms->absPeakR) ? absval : rms->absPeakR;
}

static inline void msk_rmscalc_total(msk_rmscalc_t *rms, int nframes)
{
  // compute RMS values
  rms->rmsL = sqrt(rms->rmsPeakL / nframes);
  rms->rmsR = sqrt(rms->rmsPeakR / nframes);
}

