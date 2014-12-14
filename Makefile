LLVM_INCLUDE_DIR := $(shell llvm-config --includedir)
LLVM_CFLAGS := $(shell llvm-config --cflags)
LLVM_LDFLAGS := $(shell llvm-config --libs --system-libs --cflags --ldflags core x86 interpreter jit mcjit)
GUILE_CFLAGS := $(shell pkg-config --cflags guile-2.0)
GUILE_LDFLAGS := $(shell pkg-config --cflags --libs guile-2.0)
SWIG ?= swig

all: check

check: libguile-llvm.so
	guile -L . ./check.scm

libguile-llvm.so: llvm_wrap.o
	g++ \
		llvm_wrap.o \
		-shared -o libguile-llvm.so \
		$(LLVM_LDFLAGS) \
		$(GUILE_LDFLAGS)

llvm_wrap.o: llvm_wrap.c
	gcc \
		-o llvm_wrap.o \
		-c llvm_wrap.c \
		$(LLVM_CFLAGS) \
		$(GUILE_CFLAGS)

llvm_wrap.c: llvm.swig llvm-arrays-as-vectors.i
	$(SWIG) -guile -I$(LLVM_INCLUDE_DIR) -scmstub llvm.swig

clean:
	rm -f libguile-llvm.so llvm_wrap.o llvm_wrap.c
