%module llvm
%{
#include <llvm-c/Core.h>
%}
%include <llvm-c/Core.h>
%scheme %{ (load-extension "./libguile-llvm" "SWIG_init") %}
