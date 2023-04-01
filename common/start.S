.section .init, "ax"
.global _start
_start:
    .cfi_startproc
    .cfi_undefined ra
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    la sp, __stack_top
    add s0, sp, zero

	lla	t0,_bss
	lla	t1,_ebss
	j	2f
1:	sd	zero,(t0)
	addi	t0,t0,8
2:	bne	t0,t1,1b

    call setup
    lla ra,loop
    tail loop

    .cfi_endproc
    .end
