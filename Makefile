.POSIX:

BUILD_DIR?=build
APP_DIR?=application
INCLUDE_DIR?=include
COMMON_DIR?=common

KERNEL=${BUILD_DIR}/a.out
CSRC=${addprefix ${APP_DIR}/, main.c}
INC=${wildcard ${INCLUDE_DIR}/*.h}
LDS=${addprefix ${COMMON_DIR}/, linker.ld}
ASSRC=${addprefix ${COMMON_DIR}/, start.S}

RISCV_PREFIX=riscv64-unknown-elf-
GCC=${RISCV_PREFIX}gcc
GDB=${RISCV_PREFIX}gdb
QEMU=qemu-system-riscv64

GCCFLAGS+=\
	-march=rv64imac -mabi=lp64 -mcmodel=medany\
	-std=c11 \
	-g \
	-ffreestanding \
	-O0 \
	-Wl,--gc-sections,--no-dynamic-linker \
	-nostartfiles \
	-nostdlib \
	-nodefaultlibs \
	-Wl,-T,${LDS} 
QEMUFLAGS+=\
	-machine virt \
	-m 128M \
	-bios none \
	-nographic \
	-gdb tcp::1234 \
	-kernel ${KERNEL} \
	-S \
	-serial tcp:localhost:4321,server,nowait

.PHONY: all clean qemu

all: ${KERNEL}

clean:
	rm -f ${KERNEL}

qemu: ${KERNEL} 
	@-pkill -f ${QEMU} 
	@${QEMU} ${QEMUFLAGS} &
	@${GDB}\
		-ex "set confirm off"\
		-ex "set pagination off"\
		-ex "target remote localhost:1234"\
		-ex "symbol-file $<"\
		-ex "layout split"\
		-ex "fs cmd"\
		-ex "b setup"\
		-ex "b loop" 

${KERNEL}: ${CSRC} ${INC} ${ASSRC} ${LDS}
	${GCC} ${GCCFLAGS} ${CSRC} ${ASSRC} -o $@
