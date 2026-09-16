# cb_s3_slider

Board support for the **ESP32-S3 half** of the Ki_Slider camera slider
controller — ESP32-S3-WROOM-1-N16R8 (U6), 16MB flash, 8MB octal PSRAM.

The STM32 half of the same physical board is `cb_f411re_slider`. They are two
board definitions because they are two different SoC families with separate
build artifacts, not because they are two PCBs.

KiCad project: `C:\Electronics\Ki_Slider`.

## This module is not in charge of itself

| | owned by |
|---|---|
| 3V3_ESP rail | STM32 PC0, via the `esp_3v3_reg` regulator node |
| EN (reset) | STM32 PC2 |
| IO0 (boot strap) | STM32 PC3 |
| power good | STM32 PC1 reads U2's PG |
| READY | this module's IO21 → STM32 PC5 |

So the ESP is dark until `cam_slider` on the STM32 enables the rail, and it
cannot be put into download mode without the STM32's `esp boot` command (or
shorting J9 pin 5 to ground by hand).

## Pin map

| Pin | Signal | Notes |
|---|---|---|
| IO48 | heartbeat LED | R22 560R → D5, active high |
| IO21 | READY → STM32 PC5 | STM32 holds a pull-down |
| IO17 / IO18 | UART1 to STM32 USART1 | net names are from the ESP's point of view |
| GPIO43 / GPIO44 | UART0 → J9 | console, shell and esptool |
| IO8 / IO9 | I2C0 on J3 | R23/R24 4.7K pull-ups fitted |
| IO10 / IO11 / IO12 | SPI2 to display J7 | FSPI pins, so no GPIO matrix |
| IO13 / IO14 / IO15 / IO16 | DISP_PWR / DC / RST / BL_BUSY | plain GPIOs |
| IO0 | boot strap | R21 pull-up, driven low by STM32 PC3 for download |

**There is no MISO on J7** — the display bus is write-only, and IO13 is
`DISP_PWR`, not a data line. Easy to misread from the pin numbering.

**GPIO33-37 are consumed by the octal PSRAM** on an N16R8 module and must stay
unconnected. The schematic already leaves them so.

## J9, the programming header

| Pin | Signal |
|---|---|
| 1 | 3V3_ESP |
| 2 | GND |
| 3 | TXD0 |
| 4 | RXD0 |
| 5 | IO0 |
| 6 | EN |

Pin 1 is 3V3_ESP as an **output** of this board's buck. Do not let a USB-serial
adapter feed 3.3V back into it — that back-powers U2's output and the whole ESP
rail while the STM32 believes it is off.

## No USB

U6 pins 13 and 14 (USB D+/D-) are unconnected, so there is no USB-serial-JTAG
and no DFU. UART0 on J9 is the only path in, and `usb_serial` is disabled in the
DTS to stop Zephyr claiming the console.
