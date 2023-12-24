
obj-m += thead-ddr-pmu.o
PWD := $(shell pwd)


all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod *.mod.c .tmp_versions
	rm -rf modules.order Module.symvers
