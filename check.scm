(use-modules (llvm))

(LLVMInitializeNativeTarget)

(define mod (LLVMModuleCreateWithName "fac_module"))
(define i32 (LLVMInt32Type))
(define args (vector i32))
(define fac (LLVMAddFunction mod "fac" (LLVMFunctionType i32 args #f)))
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

(define call_fac_args (vector n_minus))
(define call_fac (LLVMBuildCall builder fac call_fac_args "fac(n - 1)"))
(define res_iffalse (LLVMBuildMul builder n call_fac "n * fac(n - 1)"))
(LLVMBuildBr builder end)
(LLVMPositionBuilderAtEnd builder end)
(define res (LLVMBuildPhi builder i32 "result"))
(define phi_vals (vector res_iftrue res_iffalse))
(define phi_blocks (vector iftrue iffalse))
(LLVMAddIncoming res phi_vals phi_blocks)
(LLVMBuildRet builder res)

(LLVMDumpModule mod)

(define pass-manager (LLVMCreatePassManager))

(use-modules (srfi srfi-8))

(receive
 (failed engine error-message)
 (LLVMCreateJITCompilerForModule mod 2)

 (LLVMAddTargetData (LLVMGetExecutionEngineTargetData engine) pass-manager)
 (for-each
  (lambda (pass) (pass pass-manager))
  (list
   LLVMAddConstantPropagationPass
   LLVMAddInstructionCombiningPass
   LLVMAddPromoteMemoryToRegisterPass
   ;; LLVMAddDemoteMemoryToRegisterPass
   LLVMAddGVNPass
   LLVMAddCFGSimplificationPass))
 (LLVMRunPassManager pass-manager mod)
 (LLVMDumpModule mod)

 (let* [(input 10)
        (exec-args (vector (LLVMCreateGenericValueOfInt i32 input 0)))
        (exec-res (LLVMRunFunction engine fac exec-args))]
   (format #t "fac(~d) = ~d\n" input (LLVMGenericValueToInt exec-res 0))))
