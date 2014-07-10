# Thu 15 May 2014

* Test DDS at Harvard (not yet working)

* SEL7 ok.

    Crosstalk to D14?

* Install Xilinx ISE 14.7 so I can modify the program

* Copy /usr/local/zynq from zippy7 to get fcgio.h

* aluminizerlite builds

* Plug board 01 into slot 11

* Check DDS registers

* All registers return 0892.

    Address lines were stuck (SW bug).

* Clock is off

    RF transformer for input clock is spec'd to run at 650 MHz
    Observe 300 mV pulses coming out of SYNC_CLK, 100 to 200 us duration
    Only visibule on Agilent U1604B scope, not Digilent or real scope.

* Measure 1.785 V at 1.8 V supply.

    Spec minimum is 1.71V

* Modified `pulse_controller.c` and `AD9914.cpp` to fix DDS addressing problems.

    Read registers:

    ```
    AD9914 board=11 addr=0x00...03 = 08 00 01 00
    AD9914 board=11 addr=0x04...07 = 00 09 00 00
    AD9914 board=11 addr=0x08...0B = 1C 19 00 00
    AD9914 board=11 addr=0x0C...0F = 20 21 05 00
    AD9914 board=11 addr=0x10...13 = 00 00 00 00
    AD9914 board=11 addr=0x14...17 = 00 00 00 00
    AD9914 board=11 addr=0x18...1B = 2C 41 12 40
    AD9914 board=11 addr=0x1C...1F = 4A 0B 10 04
    AD9914 board=11 addr=0x20...23 = 80 08 90 00
    AD9914 board=11 addr=0x24...27 = 00 00 00 00
    AD9914 board=11 addr=0x28...2B = 00 00 00 00
    AD9914 board=11 addr=0x2C...2F = 00 00 00 00
    AD9914 board=11 addr=0x30...33 = 00 00 00 00
    AD9914 board=11 addr=0x34...37 = 00 12 00 04
    AD9914 board=11 addr=0x38...3B = 40 1C 00 00
    AD9914 board=11 addr=0x3C...3F = 00 00 80 00
    ```

    These match the default values from the manual,
    except for `0x0D`, which reads `0x21`, but the manual says `0x31`.

    Can't write to registers, but debugging from home is limited (zynq is at Harvard).

* Reset must be on for 24 SYSCLK cycles

    SYSCLK is usually REFCLK
    REFCLK is off and I can't turn it on remotely.

# Fri 16 May 2014

* Turn on REFCLK at 600 MHZ

    Restart FPGA
    Observe 25 MHz SYNC_CLK

* Set `ftw[11] = 0x771C23C6`

    ```
    AD9914 board=11 addr=0x00...03 = 08 01 01 00
    AD9914 board=11 addr=0x04...07 = 00 09 00 00
    AD9914 board=11 addr=0x08...0B = 1C 19 00 00
    AD9914 board=11 addr=0x0C...0F = 20 21 05 1C
    AD9914 board=11 addr=0x10...13 = 77 C6 23 00
    AD9914 board=11 addr=0x14...17 = 00 00 00 00
    AD9914 board=11 addr=0x18...1B = 0C 41 12 40
    AD9914 board=11 addr=0x1C...1F = 4A 0B 10 04
    AD9914 board=11 addr=0x20...23 = 81 08 90 00
    AD9914 board=11 addr=0x24...27 = 00 00 00 00
    AD9914 board=11 addr=0x28...2B = 00 00 00 00
    AD9914 board=11 addr=0x2C...2F = 00 00 00 00
    AD9914 board=11 addr=0x30...33 = 00 00 00 00
    AD9914 board=11 addr=0x34...37 = 00 92 20 04
    AD9914 board=11 addr=0x38...3B = 40 5C 00 00
    AD9914 board=11 addr=0x3C...3F = 00 40 A0 00
    ```

* Fix address locations for ftw, amplitude.

* 10 MHz signal has distortion at negative side.  something is overdriven ?

# Mon 19 May 2014

* `Amplitude = 80%`

    | Freq (MHz) | Power of carrier (dBm) |
    |------------|------------------------|
    | 1          | 10.0                   |
    | 2          | 11.0                   |
    | 5          | 11.6                   |
    | 10         | 12.1                   |
    | 20         | 12.7                   |
    | 50         | 13.2                   |
    | 100        | 13.2                   |
    | 200        | 12.3                   |
    | 400        | 11.4                   |
    | 600        | 11.7                   |
    | 800        | 11.3                   |
    | 1000       | 10.0                   |

* Switch REF CLK from 3 GHz to 3.5 GHz.

    Test wideband SFDR for 171.5 GHz

* Observe spurs that are a bit stronger than expected.

    `S0_3.jpg`
    `291.673 MHz` at `-53 dBc (REF_CLK/12)`
    `145 MHz` at `-61 dBc (REF_CLK/24)`

* 2 ferrites on output

    `S0_5.jpg`
    `291.673 MHz` at `-58 dBc (REF_CLK/12)`
    `145 MHz` at `-67 dBc (REF_CLK/24)`

* Short refclk and output grounds:

    `S0_4.jpg`, `S0_6.jpg`

* 10 MHz signal has distortion at negative side.  something is overdriven ?

    Replace R11 3.3k with 4.7k (as on schematic)
    Looks much better on scope

* **Update FPGA bit file, so pulse sequences w/ DDS work**

* Copy zynq/linux-xlnx from zippy7 to zippyH

* need linux-xlnx/scripts/dtc/dtc

* Run PlanAhead

    Prerequistes:

    ```
    sudo apt-get install libncurses5:i386 libx11-6:i386 libxext:i386 libxrender1:i386
    sudo apt-get install libxtst6:i386 libxi6:i386 libuuid1:i386 lib32z1 libglib2.0-0:i386
    sudo apt-get install libsm6:i386 libxrandr2:i386 libfreetype6:i386 libfontconfig1:i386
    sudo ln -s /usr/bin/make /usr/local/bin/gmake
    ```