OUTPUT_ARCH("riscv")

ENTRY(_start)

_uart = 0x10000000;
PROVIDE(_uart = 0x10000000);

MEMORY {
        RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128M
}

SECTIONS {
        .text : ALIGN(4K) {
                _text = .;
                *(.init)
                *(.text .text.*)
                _etext = .;
        } > RAM

        .data : ALIGN(8) {
                _data = .;
                *(.data .data.*)
                *(.rodata .rodata.*)
                _sdata = .;
                *(.sdata .sdata.*)
                *(.srodata .srodata*)
                _edata = .;
        } > RAM

        .bss : ALIGN(8) {
                _bss = .;
                *(.sbss .sbss.*)
                *(.bss .bss.*)
                _ebss = ALIGN(8);
        } > RAM

        . = ORIGIN(RAM) + 64K;

        PROVIDE(__stack_top = .);

	_end = .;

        __global_pointer$ = MIN(_sdata + 0x800, MAX(_data + 0x800, _ebss - 0x800));

}
