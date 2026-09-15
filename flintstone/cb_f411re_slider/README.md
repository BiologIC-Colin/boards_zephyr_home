# cb_f411re_slider

Board support for the Ki_Slider camera slider controller.
STM32F411RE (U3, LQFP-64), 96 MHz from an 8 MHz crystal.

KiCad project: `C:\Electronics\Ki_Slider` — schematic PDF in `Docs/`.

Every pin in `cb_f411re_slider.dts` was taken from the exported KiCad netlist
rather than the silkscreen, and each one carries the designators of the parts
around it so the DTS can be checked against the schematic without opening KiCad.

## Pin map

| Pin | Signal | Notes |
|---|---|---|
| PA2 / PA3 | USART2 console | J11 debug header |
| PA4 | TMC_CS | plain GPIO CS, not SPI1_NSS |
| PA5 / PA6 / PA7 | SPI1 to TMC5130 | mode 3, 3 MHz |
| PA9 / PA10 | USART1 to ESP32-S3 | net names are from the ESP's point of view |
| PA13 / PA14 / PB3 | SWD + SWO | J5 |
| PB0 | TMC DIAG0 | interrupt output, push-pull active high |
| PB1 | TMC DIAG1 | position compare, open collector |
| PB2 | TMC_ENN_MCU | enable **output**, reaches the TMC only via JP1 / J4 |
| PB10 / PB12 | camera shutter / focus | opto-isolated, active high |
| PB13 / PB14 | spares | J6 |
| PB15 | TMC_ENN | enable **read-back**, keep as input |
| PC0 | 3V3_ESP enable | `regulator-fixed`, off at reset |
| PC1 | 3V3_ESP power good | pull-up to the always-on rail |
| PC2 / PC3 / PC5 | ESP reset / boot / ready | |
| PC4 | heartbeat LED | active high, MCU sources ~2.5 mA |
| PH0 / PH1 | 8 MHz crystal X1 | **not** a bypass clock |

## Two things that are not obvious from the schematic

**The TMC enable is two nets with a link between them.** PB2 (`TMC_ENN_MCU`)
reaches the TMC's DRV_ENN (`TMC_ENN`, on PB15) only through JP1 or a
normally-closed e-stop on J4. Open that link and R25's pull-up disables the
power stage in hardware with no firmware involved — which is the point. PB15
exists so firmware can tell whether its enable actually arrived.

**The hall end stops never reach the MCU.** J8 feeds the TMC5130's own REFL and
REFR inputs. Homing status is available only over SPI (RAMP_STAT) or via the
DIAG0 interrupt, and it needs the forked driver in `drivers/drivers/stepper` —
the in-tree one leaves those inputs disabled.

J8 is the end-stop terminal block: pin 1 3V3, pin 2 HALL_L, pin 3 HALL_R,
pin 4 GND. It is easy to count from the wrong end and land on the wrong switch.

## Do not set `hse-bypass`

This board has a real crystal. In bypass mode OSC_OUT is disabled, HSE never
starts, and Zephyr hangs in a `PRE_KERNEL_1` init before the console comes up —
a completely silent board that looks like a UART fault. The Nucleo F411RE board
files this port was derived from do set it, because their HSE comes from the
ST-Link MCO.
