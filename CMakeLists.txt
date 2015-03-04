project(Zynq-HW)

## Setup
cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

set(PLANAHEAD_PPR_FILE aluminizer/hw_src/project_1.ppr)
set(PLANAHEAD_RUN_FILE aluminizer/hw_src/project_1.data/runs/runs.xml)

add_custom_target(prepare-dir ALL
  COMMAND bash "${PROJECT_SOURCE_DIR}/prepare-dir.sh"
  "${PROJECT_SOURCE_DIR}/aluminizer" "${PROJECT_BINARY_DIR}"
  "${PLANAHEAD_RUN_FILE}"
  WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}")

add_custom_target(planahead-synth ALL
  DEPENDS prepare-dir
  COMMAND xplanahead synth "${PLANAHEAD_PPR_FILE}"
  WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")

add_custom_target(planahead-bitgen ALL
  DEPENDS planahead-synth
  COMMAND xplanahead bitgen "${PLANAHEAD_PPR_FILE}"
  WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")

add_custom_target(planahead-export-hw ALL
  DEPENDS planahead-bitgen
  COMMAND xplanahead export-hw "${PLANAHEAD_PPR_FILE}"
  WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")

set(BIT_FILE
  aluminizer/hw_src/project_1.runs/impl_1/module_1_stub.bit)

add_custom_target(planahead-promgen ALL
  DEPENDS planahead-export-hw
  COMMAND cp "${PROJECT_BINARY_DIR}/${BIT_FILE}"
  "${PROJECT_BINARY_DIR}/system.bit"
  COMMAND xilinx run promgen -w -p bin -data_width 32 -b -u 0x0
  "${PROJECT_BINARY_DIR}/system.bit")
