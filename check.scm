(use-modules (llvm))

(define (->llvm-array constructor setter values)
  (let* [(size (length values))
         (array (constructor size))]
    (do [(i 0 (1+ i))
         (values values (cdr values))]
        ((= i size)
         array)
      (setter array i (car values)))))

(define (->llvm-type-array values)
  (->llvm-array LLVMTypeArrayMake LLVMTypeArraySet values))

(define (llvm-type-array . values)
  (->llvm-type-array values))

(define (->llvm-value-array values)
  (->llvm-array LLVMValueArrayMake LLVMValueArraySet values))

(define (llvm-value-array . values)
  (->llvm-value-array values))

(define (llvm-block-array . values)
  (->llvm-array LLVMBasicBlockArrayMake LLVMBasicBlockArraySet values))

(LLVMInitializeNativeTarget)

(define mod (LLVMModuleCreateWithName "fac_module"))
(define i32 (LLVMInt32Type))
(define args (llvm-type-array i32))
(define fac (LLVMAddFunction mod "fac" (LLVMFunctionType i32 args 1 #f)))
(LLVMSetFunctionCallConv fac (LLVMCCallConv))

(define n (LLVMGetParam fac 0))

(define entry (LLVMAppendBasicBlock fac "entry"))
(define iftrue (LLVMAppendBasicBlock fac "iftrue"))
(define iffalse (LLVMAppendBasicBlock fac "iffalse"))
(define end (LLVMAppendBasicBlock fac "end"))

(define builder (LLVMCreateBuilder))
(LLVMPositionBuilderAtEnd builder entry)

(define If (LLVMBuildICmp builder (LLVMIntEQ) n (LLVMConstInt i32 0 0) "n == 0"))
(LLVMBuildCondBr builder If iftrue iffalse)
(LLVMPositionBuilderAtEnd builder iftrue)
(define res_iftrue (LLVMConstInt i32 1 0))
(LLVMBuildBr builder end)
(LLVMPositionBuilderAtEnd builder iffalse)
(define n_minus (LLVMBuildSub builder n (LLVMConstInt i32 1 0) "n - 1"))

(define call_fac_args (llvm-value-array n_minus))
(define call_fac (LLVMBuildCall builder fac call_fac_args 1 "fac(n - 1)"))
(define res_iffalse (LLVMBuildMul builder n call_fac "n * fac(n - 1)"))
(LLVMBuildBr builder end)
(LLVMPositionBuilderAtEnd builder end)
(define res (LLVMBuildPhi builder i32 "result"))
(define phi_vals (llvm-value-array res_iftrue res_iffalse))
(define phi_blocks (llvm-block-array iftrue iffalse))
(LLVMAddIncoming res phi_vals phi_blocks 2)
(LLVMBuildRet builder res)

(LLVMDumpModule mod)
