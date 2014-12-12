(use-modules
 (llvm)
 (srfi srfi-1))

(define (->type-array types)
  (let* [(size (length types))
         (array (LLVMTypeArrayMake size))]
    (for-each
     (lambda (index-and-value)
       (LLVMTypeArraySet array (car index-and-value) (cdr index-and-value)))
     (map cons (iota size) types))
    array))

(define (type-array . types)
  (->type-array types))

(LLVMInitializeNativeTarget)

(define mod (LLVMModuleCreateWithName "fac_module"))
(define int32 (LLVMInt32Type))
(define args (type-array int32))
(define fac (LLVMAddFunction mod "fac" (LLVMFunctionType int32 args 1 #f)))
(LLVMSetFunctionCallConv fac (LLVMCCallConv))

;(define n (LLVMGetParam fac 0))

(LLVMDumpModule mod)
