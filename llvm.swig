%module llvm

%{
#include <llvm-c/Core.h>
#include <llvm-c/Target.h>
#include <llvm-c/ExecutionEngine.h>
%}

%apply bool { LLVMBool };

%include <llvm-c/Core.h>
%include <llvm-c/Target.h>
%include <llvm-c/ExecutionEngine.h>

%scheme %{ (load-extension "./libguile-llvm" "SWIG_init") %}

%define EXPORT_ARRAY_OF(type)

%newobject type ## ArrayMake;
%delobject type ## ArrayDispose;

%inline %{
  type ## Ref * type ## ArrayMake (int size) {
    return (type ## Ref *) malloc(size * sizeof(type ## Ref));
  }
  void type ## ArrayDispose (type ## Ref *array) {
    free(array);
  }
  type ## Ref type ## ArrayGet(type ## Ref *array, int index) {
    return array[index];
  }
  void type ## ArraySet(type ## Ref *array, int index, type ## Ref value) {
    array[index] = value;
  }
%}
%enddef

EXPORT_ARRAY_OF(LLVMType)
EXPORT_ARRAY_OF(LLVMValue)
EXPORT_ARRAY_OF(LLVMBasicBlock)
