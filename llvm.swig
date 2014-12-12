%module llvm
%{
#include <llvm-c/Core.h>
%}

%apply bool { LLVMBool };

%include <llvm-c/Core.h>
%scheme %{ (load-extension "./libguile-llvm" "SWIG_init") %}

%inline %{

  LLVMTypeRef *LLVMTypeArrayMake(int size) {
    return (LLVMTypeRef *) malloc(size * sizeof(LLVMTypeRef));
  }

  void LLVMTypeArraySet(LLVMTypeRef* array, int index, LLVMTypeRef type) {
    array[index] = type;
  }

  void LLVMTypeArrayDispose(LLVMTypeRef* array) {
    free(array);
  }
%}
