
qemu-test:
	qemu-system-x86_64 \
	-enable-kvm -no-reboot \
    -kernel linux/arch/x86/boot/bzImage \
	-nographic -nodefaults -serial stdio \
    -device virtio-blk-pci,id=blk0,drive=hd0,scsi=off \
    -drive "file=./lat_syscall.ext2,format=raw,if=none,id=hd0" \
    -append "panic=-1 console=ttyS0 root=/dev/vda rw loglevel=15 nokaslr init=/bin/sh"

build-env-image:
	cd docker && \
		docker build . -t linuxbuild:latest -f build-env.Dockerfile

setup-osv:
	git submodule update --init --recursive
	pushd osv && \
		sudo ./scripts/setup.py

patch-linux:
	cd linux && \
		git apply ../kml_4.0_001.diff

build-linux:
	sudo docker run --privileged -it -v "$(PWD)/linux":/linux-volume --rm linuxbuild:latest	\
		bash -c "make -j32 -C /linux-volume"

build-linux-lto:
	docker run -it -v "$(PWD)/linux-misc":/linux-volume --rm linuxbuild:latest	\
		bash -c "make -j8 -C /linux-volume"

run-hello:
	make -C hello
	qemu-system-x86_64 \
	-kernel linux/arch/x86_64/boot/bzImage \
	-initrd hello/initramfs-hello.cpio.gz \
	-nographic -enable-kvm \
	-append "init=/trusted/hello console=ttyS0"

debuggable:
	cd linux; \
	./scripts/config --enable DEBUG_KERNEL; \
	./scripts/config --enable DEBUG_INFO; \
	./scripts/config --disable DEBUG_INFO_REDUCED; \
	./scripts/config --enable DEBUG_INFO_SPLIT; \
	./scripts/config --enable DEBUG_INFO_DWARF4; \
	./scripts/config --enable GDB_SCRIPTS

ext4-fs:
	cd linux; \
	./scripts/config --enable EXT4_FS; \
	./scripts/config --enable BLOCK;

ide-drive:
	cd linux; \
	./scripts/config --enable BLOCK; \
	./scripts/config --enable BLK_DEV_SD; \
	./scripts/config --enable ATA_PIIX; \
	./scripts/config --enable ATA; \
	./scripts/config --enable SATA_AHCI; \
	./scripts/config --enable SCSI_CONSTANTS; \
	./scripts/config --enable SCSI_SPI_ATTRS; \

serial:
	cd linux; \
	./scripts/config --enable SERIAL_8250; \
	./scripts/config --enable SERIAL_8250_CONSOLE; \

printk:
	cd linux; \
	./scripts/config --enable EXPERT; \
	./scripts/config --enable PRINTK;

tty:
	cd linux; \
	./scripts/config --enable EXPERT; \
	./scripts/config --enable TTY;

exe:
	cd linux; \
	./scripts/config --enable BINFMT_ELF; \
	./scripts/config --enable BINFMT_SCRIPT;

64bit:
	cd linux; \
	./scripts/config --enable 64BIT;

network:
	cd linux; \
	./scripts/config --enable NET; \
	./scripts/config --enable INET;

futex:
	cd linux; \
	./scripts/config --enable EXPERT; \
	./scripts/config --enable FUTEX;

epoll:
	cd linux; \
	./scripts/config --enable EXPERT; \
	./scripts/config --enable EPOLL; \
	./scripts/config --enable SIGNALFD;

audit:
	cd linux; \
	./scripts/config --enable AUDIT; \
	./scripts/config --enable AUDITSYSCALL; \
	./scripts/config --eanble AUDIT_WATCH; \
	./scripts/config --enable AUDIT_TREE; \
	./scripts/config --enable INTEGRITY_AUDIT;

proc:
	cd linux; \
	./scripts/config --enable PROC_FS;

smp:
	cd linux; \
	./scripts/config --enable SMP; \
	./scripts/config --enable X86_64_SMP;

unix-socket:
	cd linux; \
	./scripts/config --enable UNIX;

multiuser:
	cd linux; \
	./scripts/config --enable MULTIUSER;

ftrace:
	cd linux; \
	./scripts/config --enable DEBUG_FS; \
	./scripts/config --enable FTRACE; \
	./scripts/config --enable FUNCTION_TRACER; \
	./scripts/config --enable FUNCTION_GRAPH_TRACER; \
	./scripts/config --enable FUNCTION_STACK_TRACER; \
	./scripts/config --enable FUNCTION_DYNAMIC_TRACER;
