%define LLVM_POINTER_VECTOR_INPUT(C_TYPE, POINTER_TYPE)

     /* We make use of the new multi-dispatch typemaps here. */
     %typemap(in, doc="$NAME is a vector of " #C_TYPE " values")
     (C_TYPE *VECTORINPUT, unsigned VECTORLENINPUT) {
       SCM_VALIDATE_VECTOR($argnum, $input);
       $2 = scm_c_vector_length($input);
       if ($2 > 0) {
	 $2_ltype i;
	 $1 = (C_TYPE *) SWIG_malloc(sizeof(C_TYPE) * $2);
	 for (i = 0; i<$2; i++) {
	   SCM swig_scm_value = scm_vector_ref($input, scm_from_long(i));
	   $1[i] = ((C_TYPE)SWIG_MustGetPtr(swig_scm_value, POINTER_TYPE, 1, 0));
	 }
       }
       else $1 = NULL;
     }

     %typemap(in, doc="$NAME is a vector of " #C_TYPE " values")
     C_TYPE *VECTORINPUT {
       SCM_VALIDATE_VECTOR($argnum, $input);
       unsigned length = scm_c_vector_length($input);
       if (length > 0) {
	 unsigned i;
	 $1 = (C_TYPE *) SWIG_malloc(sizeof(C_TYPE) * length);
	 for (i = 0; i<length; i++) {
	   SCM swig_scm_value = scm_vector_ref($input, scm_from_long(i));
	   $1[i] = ((C_TYPE)SWIG_MustGetPtr(swig_scm_value, POINTER_TYPE, 1, 0));
	 }
       }
       else $1 = NULL;
     }

     /* Do not check for NULL pointers (override checks). */
     %typemap(check)(C_TYPE *VECTORINPUT, unsigned VECTORLENINPUT), C_TYPE *VECTORINPUT
     "/* no check for NULL pointer */";

     /* Discard the temporary array after the call. */
     %typemap(freearg)(C_TYPE *VECTORINPUT, unsigned VECTORLENINPUT), C_TYPE *VECTORINPUT
       {if ($1!=NULL) SWIG_free($1);}

%enddef

%define LLVM_VECTOR_INPUT(LLVM_TYPE)
  LLVM_POINTER_VECTOR_INPUT(LLVM ## LLVM_TYPE ## Ref, SWIGTYPE_p_LLVMOpaque ## LLVM_TYPE)
%enddef
