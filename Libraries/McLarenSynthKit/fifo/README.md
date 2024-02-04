# Output FIFO

The Output Fifo is a non-blocking communication channel from the Audio Loop to the Audio Context.
It uses a circular buffer.  The Output Fifo must be accessed by CFunctions within the Audio Loop.
In the Audio Context, a combination of CFunctions and methods can be used.

