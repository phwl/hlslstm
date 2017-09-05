vlog *.v

vlog -sv ../src/*.v
vlog -sv ../ip/*.v

vsim tb_is

# mem load -i D:/ningyixu/SaaS_TFS/SaaS/Hardware/sim2/data/ddr0_preload.mem -format hex /tb_is/ddr0_inst/memdata
# mem load -i D:/ningyixu/SaaS_TFS/SaaS/Hardware/sim2/data/ddr1_preload.mem -format hex /tb_is/ddr1_inst/memdata

do wave.do
run 0.00001 us

# mem save -o D:/ningyixu/SaaS_TFS/SaaS/Hardware/sim2/data/ddr1_preload.mem -f hex -startaddress 0 -endaddress 65536 /tb_is/ddr1_inst/memdata
# mem save -o D:/ningyixu/SaaS_TFS/SaaS/Hardware/sim2/data/ddr0_preload.mem -f hex -startaddress 0 -endaddress 65536 /tb_is/ddr0_inst/memdata

