%module llvm

%{
#include <llvm-c/Core.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>
#include <llvm-c/Transforms/Scalar.h>
%}

%apply bool { LLVMBool };

// these newobject/delobject pairs don't seem
// to have any effect on the generated code
// but let's keep it for documentation

%newobject LLVMModuleCreateWithName;
%delobject LLVMDisposeModule;

%newobject LLVMCreateBuilder;
%delobject LLVMDisposeBuilder;

%newobject LLVMCreatePassManager;
%delobject LLVMDisposePassManager;

%include <llvm-c/Core.h>
%include <llvm-c/Analysis.h>
%include <llvm-c/ExecutionEngine.h>
%include <llvm-c/Target.h>
%include <llvm-c/Transforms/Scalar.h>

%scheme %{ (load-extension "./libguile-llvm" "SWIG_init") %}

%scheme %{
(define (->llvm-array constructor setter values)
  (let* [(size (length values))
         (array (constructor size))]
    (do [(i 0 (1+ i))
         (values values (cdr values))]
        ((= i size)
         array)
      (setter array i (car values)))))
%}

%define EXPORT_ARRAY_OF(type)

%newobject type ## ArrayCreate;
%delobject type ## ArrayDispose;

%inline %{
  type ## Ref * type ## ArrayCreate (int size) {
    return (type ## Ref *) SWIG_malloc(size * sizeof(type ## Ref));
  }
  void type ## ArrayDispose (type ## Ref *array) {
    SWIG_free(array);
  }
  type ## Ref type ## ArrayGet(type ## Ref *array, int index) {
    return array[index];
  }
  void type ## ArraySet(type ## Ref *array, int index, type ## Ref value) {
    array[index] = value;
  }
%}

%scheme %{
(define (type ## Array . values)
  (->llvm-array type ## ArrayCreate type ## ArraySet values))
(export type ## Array)
%}
%enddef

EXPORT_ARRAY_OF(LLVMType)
EXPORT_ARRAY_OF(LLVMValue)
EXPORT_ARRAY_OF(LLVMBasicBlock)
EXPORT_ARRAY_OF(LLVMGenericValue)

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
%inline %{
void LLVMCreateJITCompilerForModuleMV(LLVMModuleRef M,
                                      unsigned OptLevel,
                                      LLVMBool* OutFailed,
                                      char **OutError,
                                      LLVMExecutionEngineRef *OutJIT) {
  *OutFailed = LLVMCreateJITCompilerForModule(OutJIT, M, OptLevel, OutError);
}
%}
