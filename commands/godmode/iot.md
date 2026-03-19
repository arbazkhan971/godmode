# /godmode:iot

IoT and embedded systems development — firmware architecture (FreeRTOS, Zephyr, bare-metal), communication protocols (MQTT, CoAP, BLE, LoRa), OTA update strategies, power optimization for battery devices, device provisioning and fleet management.

## Usage

```
/godmode:iot                               # Full IoT project assessment
/godmode:iot --power                       # Power optimization analysis
/godmode:iot --ota                         # OTA update system design
/godmode:iot --fleet                       # Fleet management architecture
/godmode:iot --protocol mqtt               # MQTT protocol design
/godmode:iot --mcu esp32                   # Target ESP32 MCU
/godmode:iot --rtos freertos               # Use FreeRTOS
```

## What It Does

1. Assesses IoT project requirements (MCU, RTOS, connectivity, power budget, scale)
2. Designs firmware architecture (RTOS task model or bare-metal super-loop)
3. Configures communication protocols:
   - MQTT: topic hierarchy, QoS strategy, message format, TLS/mTLS
   - CoAP: resource design, observe pattern, DTLS security
   - BLE: GATT service design, connection parameters
4. Implements OTA update system (A/B partitioning, signed firmware, rollback)
5. Optimizes power consumption:
   - Sleep mode strategies, duty cycling, peripheral power gating
   - Battery life estimation with detailed current profiling
6. Designs device fleet management (provisioning, shadow/twin, monitoring, staged rollout)

## Output
- Firmware scaffold with task architecture and driver HAL
- Communication protocol configuration with security
- OTA update system with signed firmware and rollback
- Power budget analysis with estimated battery life
- Commit: `"iot: <mcu> — <description>"`

## Next Step
After scaffold: `/godmode:test` to add unit tests (Unity/ztest).
After firmware: `/godmode:secure` to audit TLS and provisioning.
When ready: `/godmode:ship` for production deployment.

## Examples

```
/godmode:iot                               # Full project assessment and setup
/godmode:iot --power                       # Power optimization analysis
/godmode:iot --ota                         # Design OTA update system
/godmode:iot --protocol mqtt               # MQTT broker and topic design
/godmode:iot --fleet                       # Fleet management architecture
```
