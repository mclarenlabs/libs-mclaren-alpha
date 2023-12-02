
# An Explanation of the Envelope Generator

The envelope implements an exponential decay.  We choose a decay rate factor "r", 
where r<1.0.  At each sample point, the initial value of 1.0 is multiplied by r.
If we do this N times, then the value, V, after N samples is

    V = r^N
	
The definition of log says that

    log_r(e) = N

The change of base identity says

    log_b(x) = ln x / ln b
	
Using this, we can calculate what rate factor "r" to choose so that after N samples
we have a value of V.

    r = exp(ln(V) / N)
	
Let's say we apply this to the decay of an envelope, and with a starting value of
1.0, we want the envelope to reach 0.01 after 1000 cycles.

    r = exp(ln(0.01) / 1000)
	r = 0.995405417351527
	

## Application to Envelope Generator

There is a nice write-up of envelope generators here that uses the math above.

- https://www.earlevel.com/main/2013/06/02/envelope-generators-adsr-part-2/

In it, the author discussed how a true exponential decay only gets to 0.0 after an
infinite amount of time.  But if we apply the same decay calculations to
a starting value of

    1.0 + target
	
and a desired ending value of

    target
	
then there is a value that can be calculated.  Starting with a value of '1+target`,
the value after N multiplications of r needs ot be 'target'.  Or

    (1+target) * (r^N) = target

Working through the math with the identiies above, his formula for the
desired rate factor 'r' to go from '1+target' down to 'target' is

    r = exp(ln(target / (1.0+target)) / N)
	
## The Attack Phase

We calculate an 'r' such describing a rate that starts at '1+target' and decays
to 'target'.

We define a value called 'nrg' that is decaying, and the attack envelope at
each sample is

    env = (1+target) - nrg
	
Since 'nrg' starts at '1+target', 'env' will start at 0 and grow to 1.0 
after the desired interval, and will continue past 1.0.  When we detect
this threshold crossing, we transition the envelope into is decay phase.



    
