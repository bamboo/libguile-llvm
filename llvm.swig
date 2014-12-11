%module llvm
%{
#include <llvm-c/Core.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>
%}
%include <llvm-c/Core.h>
%include <llvm-c/ExecutionEngine.h>
%include <llvm-c/Target.h>
%scheme %{ (load-extension "libguile-llvm" "SWIG_init") %}
