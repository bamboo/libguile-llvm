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
