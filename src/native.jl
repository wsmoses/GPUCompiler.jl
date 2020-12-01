# native target for CPU execution

## target

export NativeCompilerTarget

Base.@kwdef struct NativeCompilerTarget <: AbstractCompilerTarget
    cpu::String=(LLVM.version() < v"8") ? "" : unsafe_string(LLVM.API.LLVMGetHostCPUName())
    features::String=(LLVM.version() < v"8") ? "" : unsafe_string(LLVM.API.LLVMGetHostCPUFeatures())
    reloc::LLVM.API.LLVMRelocMode=LLVM.API.LLVMRelocDefault
    extern::Bool
end

llvm_triple(::NativeCompilerTarget) = Sys.MACHINE

function llvm_machine(target::NativeCompilerTarget)
    triple = llvm_triple(target)

    t = Target(triple=triple)

    optlevel = LLVM.API.LLVMCodeGenLevelDefault
    reloc = target.reloc
    tm = TargetMachine(t, triple, target.cpu, target.features, optlevel, reloc)
    asm_verbosity!(tm, true)

    return tm
end

GPUCompiler.extern_policy(job::CompilerJob{NativeCompilerTarget,P} where P) =
    job.target.extern


## job

runtime_slug(job::CompilerJob{NativeCompilerTarget}) = "native_$(job.target.cpu)-$(hash(job.target.features))"
