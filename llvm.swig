%module llvm

%{
#include <llvm-c/Core.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>
#include <llvm-c/Transforms/Scalar.h>
%}

%apply bool { LLVMBool };

%import list-vector.i
%import llvm-arrays-as-vectors.i

%{
#define SCM_TO_LLVMGenericValueRef(v) \
  ((LLVMGenericValueRef)SWIG_MustGetPtr(v, SWIGTYPE_p_LLVMOpaqueGenericValue, 1, 0))
%}
TYPEMAP_LIST_VECTOR_INPUT(LLVMGenericValueRef, SCM_TO_LLVMGenericValueRef, LLVMGenericValueRef);

LLVM_VECTOR_INPUT(Type);

LLVM_VECTOR_INPUT(Value);

LLVM_VECTOR_INPUT(BasicBlock);

%apply (LLVMTypeRef *VECTORINPUT, unsigned VECTORLENINPUT) {
       (LLVMTypeRef *ParamTypes, unsigned ParamCount)
};

%apply (LLVMValueRef *VECTORINPUT, unsigned VECTORLENINPUT) {
       (LLVMValueRef *Args, unsigned NumArgs)
};

%apply (int VECTORLENINPUT, LLVMGenericValueRef *VECTORINPUT) {
       (unsigned NumArgs, LLVMGenericValueRef *Args)
};

void LLVMAddIncoming(LLVMValueRef,
                     LLVMValueRef *VECTORINPUT,
                     LLVMBasicBlockRef *VECTORINPUT, unsigned VECTORLENINPUT);

// these newobject/delobject pairs don't seem
// to have any effect on the generated code
// but let's keep it for documentation

%newobject LLVMModuleCreateWithName;
%delobject LLVMDisposeModule;

%newobject LLVMCreateBuilder;
%delobject LLVMDisposeBuilder;

%newobject LLVMCreatePassManager;
%delobject LLVMDisposePassManager;

%typemap(in, numinputs=0) LLVMExecutionEngineRef *OutJIT (LLVMExecutionEngineRef tmp = NULL) {
  $1 = &tmp;
}

%typemap(argout) LLVMExecutionEngineRef *OutJIT {
  SWIG_APPEND_VALUE(SWIG_NewPointerObj(*$1, SWIGTYPE_p_LLVMOpaqueExecutionEngine, 0));
}

%typemap(in, numinputs=0) LLVMBool *OutFailed (LLVMBool tmp = 0) {
  $1 = &tmp;
}

%typemap(argout) LLVMBool *OutFailed {
  SWIG_APPEND_VALUE(scm_from_bool(*$1));
}

%typemap(in, numinputs=0) char **OutError (char* temp = NULL) {
  $1 = &temp;
}

%typemap(argout) char **OutError {
  SWIG_APPEND_VALUE(SWIG_str02scm(*$1));
}

%typemap(freearg) char **OutError {
  if (*$1) LLVMDisposeMessage(*$1);
}

%multiple_values;

%include <llvm-c/Core.h>
%include <llvm-c/Analysis.h>
%include <llvm-c/ExecutionEngine.h>
%include <llvm-c/Target.h>
%include <llvm-c/Transforms/Scalar.h>

%scheme %{ (load-extension "./libguile-llvm" "SWIG_init") %}
