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
