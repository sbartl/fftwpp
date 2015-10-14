#include "Array.h"
#include "fftw++.h"

// Compile with
// g++ -I .. -fopenmp example2r.cc ../fftw++.cc -lfftw3 -lfftw3_omp

using namespace std;
using namespace Array;
using namespace fftwpp;

int main()
{
  cout << "2D real to complex out-of-place FFT" << endl;

  fftw::maxthreads=get_max_threads();
  
  unsigned int nx=4, ny=5;
  unsigned int nyp=ny/2+1;
  size_t align=sizeof(Complex);
  
  array2<double> f(nx,ny,align);
  array2<Complex> g(nx,nyp,align);
//  array2<double> f(nx,2*nyp,(double *) g()); // For in-place transforms
  
  rcfft2d Forward(nx,ny,f,g);
  crfft2d Backward(nx,ny,g,f);
  
  for(unsigned int i=0; i < nx; i++) 
    for(unsigned int j=0; j < ny; j++) 
      f(i,j)=i+j;
	
  cout << endl << "input:" << endl << f;

  Forward.fft0(f,g);
  
//  cout << endl << "output:" << endl << g;
//  Forward.deNyquist(g);
  
  cout << endl << "output:" << endl << g;
  
  Backward.fft0Normalized(g,f);
  
  cout << endl << "back to input:" << endl << f;
}
