%module llvm
%{
#include <llvm-c/Core.h>
%}

%apply bool { LLVMBool };

%include <llvm-c/Core.h>
%scheme %{ (load-extension "./libguile-llvm" "SWIG_init") %}
