# SPDX-License-Identifier: Apache-2.0
#
# The module's USB pins are not brought out on this board, so flashing is over
# UART0 on J9. The ESP cannot be reset by the adapter either - use the STM32's
# "esp boot" shell command to put it into download mode first.

if(NOT "${OPENOCD}" MATCHES "^${ESPRESSIF_TOOLCHAIN_PATH}/.*")
  set(OPENOCD OPENOCD-NOTFOUND)
endif()
find_program(OPENOCD openocd PATHS ${ESPRESSIF_TOOLCHAIN_PATH}/openocd-esp32/bin NO_DEFAULT_PATH)

include(${ZEPHYR_BASE}/boards/common/esp32.board.cmake)
include(${ZEPHYR_BASE}/boards/common/openocd.board.cmake)
