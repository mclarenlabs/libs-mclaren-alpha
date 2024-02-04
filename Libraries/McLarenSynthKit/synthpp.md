# SynthPP

Files in this project including the name "synthpp" are C++ files for implementing audio thread modules in a stylized way to gain some amount of polymorphism for use in different contexts.  C++ Templates are used to expand a single audio generator function definition into multiple different instantiations.

Many audio generation functions follow a similar pattern.  The render function is called once per period.  It accesses some control values at the beginning of the loop, calculates a new value for each item in the output buffer and optionally updates some values.  A pseudo-code sketch of an oscillator might look like this.

    def render(double out[persize], double *kontrol)
    {
      double local = kontrol[0];
      for (i = 0; i++; i<persize) {
        out[i] = oscillator_function(i, local)
      }
    }

Where the oscillator_function computes SIN values, etc.

Now consider that we want to generalize this function to use an external kontrol that supplies a value for each "sample", not just each "period."  The pseudo-code would look something like this.

    def render(double out[persize], double kontrol[persize])
    {

      for (i = 0; i++; i<persize) {
        double local = kontrol[i];
        out[i] = oscillator_function(i, local)
      }
    }

The inner part of the audio render function is very similar, but the accessing of the audio buffers and kontrol values changes slightly.

This is what the `synthpp` template classes and functions do: they generalize the definition of the audio loop so that the accessing of values is abstracted.  This operation is done by the "accessors" defined in `synthpp_common.h`.

Using accessors, the render function would look something like this.

``` C++
template <class KACCESSOR>
def render(double out[persize], KACCESSOR &kontrol)
{
  kontrol.preamble();
  for (i = 0; i++; i<persize) {
    kontrol.fetch(i);
    out.val = oscillator_function(i, kontrol.val);
  }
  out.store(i)
}
```

With a KACCESSOR that only performs a fetch ONLY in the preamble, the loop accesses the kontrol value once.  With a KACCESSOR that accesses the kontrol value from an array, the preamble does nothing and the fetch implements a memory access.  The compiler can generate both implementations for the two different types of KACCESSOR template classes.

## Advantages

The advantage of using an approach like this is to avoid writing copies of similar code which can help avoid introducing bugs.  An oscillator function with some sort of kontrol input is largely the same whether that kontrol is read from a single value, an audio buffer of length `persize` or even if that kontrol value is interpolated over the duration of the audio period.  The code body can remain the same, and the context in which it is used defines how the external kontrol value is accessed and used.

## References

Related work on abstracting an idea like accessors appears in

* https://www.cs.cmu.edu/~rbd/papers/ugg-icmc-2018.pdf

by Roger Dannenberg of CMU.  In that paper, he presents using a preprocessor to generate audio loops.  Here, we are combiniing C++ with ObjC Templates to do something similar.
