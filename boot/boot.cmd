bitstream_image=system.bit.bin
devicetree_image=devicetree.dtb
kernel_image=uImage
ramdisk_image=uramdisk.image.gz

loadbootenv_addr=0x2000000
loadbit_addr=0x100000

load mmc 0 ${loadbootenv_addr} uEnv.txt
echo "Importing environment from SD ..."
env import -t ${loadbootenv_addr} ${filesize}
echo Loading bitstream from SD/MMC/eMMC to RAM..
load mmc 0 ${loadbit_addr} ${bitstream_image} && fpga load 0 ${loadbit_addr} ${filesize}
fatload mmc 0 0x4000000 ${kernel_image}
fatload mmc 0 0x3A00000 ${devicetree_image}
fatload mmc 0 0x2000000 ${ramdisk_image}
bootm 0x4000000 0x2000000 0x3A00000
