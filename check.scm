(use-modules (llvm))

(define (->llvm-array constructor setter values)
  (let* [(size (length values))
         (array (constructor size))]
    (do [(i 0 (1+ i))
         (values values (cdr values))]
        ((= i size)
         array)
      (setter array i (car values)))))

(define (->LLVMTypeArray values)
  (->llvm-array LLVMTypeArrayCreate LLVMTypeArraySet values))

(define (LLVMTypeArray . values)
  (->LLVMTypeArray values))

(define (->LLVMValueArray values)
  (->llvm-array LLVMValueArrayCreate LLVMValueArraySet values))

(define (LLVMValueArray . values)
  (->LLVMValueArray values))

(define (LLVMBasicBlockArray . values)
  (->llvm-array LLVMBasicBlockArrayCreate LLVMBasicBlockArraySet values))

(LLVMInitializeNativeTarget)

(define mod (LLVMModuleCreateWithName "fac_module"))
(define i32 (LLVMInt32Type))
(define args (LLVMTypeArray i32))
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

(define call_fac_args (LLVMValueArray n_minus))
(define call_fac (LLVMBuildCall builder fac call_fac_args 1 "fac(n - 1)"))
(define res_iffalse (LLVMBuildMul builder n call_fac "n * fac(n - 1)"))
(LLVMBuildBr builder end)
(LLVMPositionBuilderAtEnd builder end)
(define res (LLVMBuildPhi builder i32 "result"))
(define phi_vals (LLVMValueArray res_iftrue res_iffalse))
(define phi_blocks (LLVMBasicBlockArray iftrue iffalse))
(LLVMAddIncoming res phi_vals phi_blocks 2)
(LLVMBuildRet builder res)

(LLVMDumpModule mod)

(define pass-manager (LLVMCreatePassManager))

;  (LLVMAddTargetData (LLVMGetExecutionEngineTargetData engine) pass-manager)

(define passes (list
                LLVMAddConstantPropagationPass
                LLVMAddInstructionCombiningPass
                LLVMAddPromoteMemoryToRegisterPass
;;              LLVMAddDemoteMemoryToRegisterPass
                LLVMAddGVNPass
                LLVMAddCFGSimplificationPass))
(for-each (lambda (pass) (pass pass-manager)) passes)
(LLVMRunPassManager pass-manager mod)
(LLVMDumpModule mod)
