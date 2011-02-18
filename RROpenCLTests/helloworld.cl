__kernel void add( __constant int x, __constant int y, __global int * output )
{
    *output = x + y;
}