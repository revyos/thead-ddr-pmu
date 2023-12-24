Comments

thead-ddr-pmu is a IP module used to do performance monitor.
How to get the code

git clone git@gitlab.alibaba-inc.com:thead-linux-private/thead-ddr-pmu.git
Description of each directories

driver/: Linux kernel module Driver.
test/: Test cases and demo app.
How to build

Build a buildroot of SoC project
Build module at fce root path
make
Build each directory one by one:
make driver
make test