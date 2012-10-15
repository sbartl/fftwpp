program fexample
  use fftwpp
  use fhash

  use, intrinsic :: ISO_C_Binding !FIXME: use only.... to clean up namespace?
  implicit NONE
  include 'fftw3.f03'
  integer(c_int) :: m, mx, my, mz, i, j, k, mmx, mmy, mxyz
  integer :: returnflag
  
  complex(C_DOUBLE_COMPLEX), pointer :: f(:), g(:), ff(:,:), gg(:,:), &
       fff(:,:,:),  ggg(:,:,:)
  type(C_PTR) :: pf, pg, pconv

  returnflag=0 ! return value for tests
  
  write(*,*) "Example of calling fftw++ convolutions from Fortran:"


  ! 1D convolutions:
  m=8 ! problem size
  
  !allocate memory:
  pf = fftw_alloc_complex(int(m, C_SIZE_T))
  pg = fftw_alloc_complex(int(m, C_SIZE_T))
  call c_f_pointer(pf, f, [m])
  call c_f_pointer(pg, g, [m])

  ! initialize arrays
  call init(f,g,m)

!  write(*,*)
!  write(*,*) "input f:"
!  call output(f,m)

!  write(*,*)
!  write(*,*) "input g:"
!  call output(g,m)

  write(*,*)
  write(*,*) "1d non-centered complex convolution:"
  pconv=cconv1d_create(m)
  call cconv1d_convolve(pconv,pf,pg)
  call delete_cconv1d(pconv)

  call output(f,m)

  if( hash1(pf,m).ne.-1208058208 ) then
     write(*,*) "ImplicitConvolution output incorect."
     returnflag = returnflag+1
  end if

  call init(f,g,m) ! reset input data

  write(*,*)
  write(*,*) "1d centered Hermitian-symmetric complex convolution:"
  pconv=hconv1d_create(m)
  call hconv1d_convolve(pconv,pf,pg)
  call delete_hconv1d(pconv)

  call output(f,m)

  if( hash1(pf,m).ne.-1208087538 ) then
     write(*,*) "ImplicitHConvolution output incorect."
     returnflag = returnflag+2
  end if
  
  ! memory-aligned arrays need to be deleted using FFTW.
  call fftw_free(pf)
  call fftw_free(pg)

  ! 2d non-centered complex convolution

  write(*,*)
  write(*,*) "2d non-centered complex convolution:"
  ! 2D problem size
  mx=4
  my=4
  
  pf = fftw_alloc_complex(int(mx*my, C_SIZE_T))
  pg = fftw_alloc_complex(int(mx*my, C_SIZE_T))
  call c_f_pointer(pf, ff, [mx,my])
  call c_f_pointer(pg, gg, [mx,my])
  
  call init2(ff,gg,mx,my)
  
  pconv=cconv2d_create(mx,my)
  call cconv2d_convolve(pconv,pf,pg)
  call delete_cconv2d(pconv)
  
  call output2(ff,mx,my)
  
  if( hash1(pf,mx*my).ne.-268695633 ) then
     write(*,*) "ImplicitConvolution2 output incorect."
     returnflag = returnflag+4
  end if
  
  call fftw_free(pf)
  call fftw_free(pg)

  ! 2d centered Hermitian convolution

  write(*,*)
  write(*,*) "2d centered Hermitian-symmetric complex convolution:"

  mmx=2*mx-1
  
  pf = fftw_alloc_complex(int(mmx*my, C_SIZE_T))
  pg = fftw_alloc_complex(int(mmx*my, C_SIZE_T))
  call c_f_pointer(pf, ff, [my,mmx])
  call c_f_pointer(pg, gg, [my,mmx])
  
  call init2(ff,gg,mmx,my)

  pconv=hconv2d_create(mx,my)
  call hconv2d_convolve(pconv,pf,pg)
  call delete_hconv2d(pconv)

  call output2(ff,mmx,my)

  if( hash1(pf,mmx*my).ne.-947771835 ) then
     write(*,*) "ImplicitHConvolution2 output incorect."
     returnflag = returnflag+4
  end if

  call fftw_free(pf)
  call fftw_free(pg)

  ! 3d non-centered complex convolution
  
  write(*,*)
  write(*,*) "3d non-centered complex convolution:"
  mx=4
  my=4
  mz=4
  
  pf = fftw_alloc_complex(int(mx*my*mz, C_SIZE_T))
  pg = fftw_alloc_complex(int(mx*my*mz, C_SIZE_T))
  call c_f_pointer(pf, fff, [mz,my,mx])
  call c_f_pointer(pg, ggg, [mz,my,mx])

  call init3(fff,ggg,mx,my,mz)
  
  pconv=cconv3d_create(mx,my,mz)
  call cconv3d_convolve(pconv,pf,pg)
  call delete_cconv3d(pconv)

  call output3(fff,mx,my,mz)

  if( hash1(pf,mx*my*mz).ne.1073436205 ) then
     write(*,*) "ImplicitConvolution3 output incorect."
     returnflag = returnflag+4
  end if

  call fftw_free(pf)
  call fftw_free(pg)

  ! 3d centered Hermitian convolution
  write(*,*)
  write(*,*) "3d centered Hermitian-symmetric complex convolution:"
  mx=4
  my=4
  mz=4
  
  mmx=2*mx-1
  mmy=2*my-1
  mxyz=mmx*mmy*mz;
  pf = fftw_alloc_complex(int(mxyz, C_SIZE_T))
  pg = fftw_alloc_complex(int(mxyz, C_SIZE_T))
  call c_f_pointer(pf, fff, [mz,mmy,mmx])
  call c_f_pointer(pg, ggg, [mz,mmy,mmx])

  call init3(fff,ggg,mmx,mmy,mz)

  pconv=hconv3d_create(mx,my,mz)
  call hconv3d_convolve(pconv,pf,pg)
  call delete_hconv3d(pconv)

  call output3(fff,mmx,mmy,mz)
  
  if( hash1(pf,mxyz).ne.-472674783 ) then
     write(*,*) "ImplicitHConvolution3 output incorect."
     returnflag = returnflag+4
  end if

  call fftw_free(pf)
  call fftw_free(pg)
  ! 1d centered Hermitian ternary convolution

  ! 2d centered Hermitian ternary convolution

  call EXIT(returnflag)

  contains
    
    subroutine init(f,g,m)
      use, intrinsic :: ISO_C_Binding
      implicit NONE
      integer :: i
      integer(c_int), intent(in) :: m
      complex(C_DOUBLE_COMPLEX), pointer, intent(inout) :: f(:), g(:)
      do i=0,m-1
         f(i+1)=cmplx(i,(i+1))
         g(i+1)=cmplx(i,(2*i +1))
      end do
    end subroutine init

    subroutine init2(f,g,mx,my)
      use, intrinsic :: ISO_C_Binding
      implicit NONE
      integer :: i, j
      integer(c_int), intent(in) :: mx, my
      complex(C_DOUBLE_COMPLEX), pointer, intent(inout) :: f(:,:), g(:,:)
      do i=0,mx-1
         do j=0,my-1
            f(j+1,i+1)=cmplx(i,j)
            g(j+1,i+1)=cmplx(2*i,j+1)
         end do
      end do
    end subroutine init2
    

    subroutine init3(f,g,mx,my,mz)
      use, intrinsic :: ISO_C_Binding
      implicit NONE
      integer :: i, j
      integer(c_int), intent(in) :: mx, my, mz
      complex(C_DOUBLE_COMPLEX), pointer, intent(inout) :: f(:,:,:), g(:,:,:)
      do i=0,mx-1
         do j=0,my-1
            do k=0,mz-1
               f(k+1,j+1,i+1)=cmplx(i+k,j+k)
               g(k+1,j+1,i+1)=cmplx(2*i+k,j+1+k)
            end do
         end do
      end do
    end subroutine init3
    
    subroutine output(f,m)
      use, intrinsic :: ISO_C_Binding
      implicit NONE
      integer :: i
      integer(c_int), intent(in) :: m
      complex(C_DOUBLE_COMPLEX), pointer, intent(inout) :: f(:)
      do i=1,m
         print*,f(i)
      end do
    end subroutine output

    subroutine output2(f,mx,my)
      use, intrinsic :: ISO_C_Binding
      implicit NONE
      integer :: i, j
      integer(c_int), intent(in) :: mx, my
      complex(C_DOUBLE_COMPLEX), pointer, intent(inout) :: f(:,:)
      do i=1,mx
         do j=1,my
            print*,f(i,j)
         end do
         write(*,*)
      end do
    end subroutine output2

    subroutine output3(f,mx,my,mz)
      use, intrinsic :: ISO_C_Binding
      implicit NONE
      integer :: i, j
      integer(c_int), intent(in) :: mx, my, mz
      complex(C_DOUBLE_COMPLEX), pointer, intent(inout) :: f(:,:,:)
      do i=1,mx
         do j=1,my
            do k=1,mz
               print*,f(i,j,k)
            end do
            write(*,*)
         end do
         write(*,*)
      end do
    end subroutine output3
end program fexample
