---
name: iot
description: |
  IoT and embedded systems development skill. Activates when building, optimizing, or deploying firmware, device communication, and fleet management systems. Covers embedded firmware architecture (FreeRTOS, Zephyr, bare-metal), communication protocols (MQTT, CoAP, BLE, LoRa), OTA update strategies, power optimization for battery-operated devices, device provisioning and fleet management, and edge computing. Every recommendation is hardware-aware and includes concrete implementation. Triggers on: /godmode:iot, "embedded", "firmware", "MQTT", "IoT", "sensor", "microcontroller", "OTA", "device fleet".
---

# IoT — IoT & Embedded Systems Development

## When to Activate
- User invokes `/godmode:iot`
- User says "embedded", "firmware", "microcontroller", "IoT", "Internet of Things"
- User mentions "MQTT", "CoAP", "BLE", "Bluetooth", "LoRa", "Zigbee"
- User mentions "ESP32", "STM32", "nRF52", "Raspberry Pi", "Arduino"
- User mentions "FreeRTOS", "Zephyr", "bare-metal", "RTOS"
- When designing OTA update systems or device provisioning
- When optimizing power consumption for battery devices
- When building device fleet management or telemetry systems

## Workflow

### Step 1: IoT Project Assessment
Determine the embedded/IoT development approach:

```
IOT PROJECT ASSESSMENT:
Project type: <sensor node | gateway | actuator | wearable | industrial | custom>
Target MCU: <ESP32 | STM32 | nRF52 | RP2040 | custom>
RTOS: <FreeRTOS | Zephyr | bare-metal | Linux (embedded)>

Connectivity:
  Primary: <WiFi | BLE | LoRa | Cellular (LTE-M/NB-IoT) | Ethernet>
  Secondary: <none | BLE for provisioning | WiFi for gateway>
  Protocol: <MQTT | CoAP | HTTP | custom binary>
  Cloud platform: <AWS IoT Core | Azure IoT Hub | GCP IoT | self-hosted>

Power profile:
  Source: <mains powered | battery | solar + battery | energy harvesting>
  Battery capacity: <mAh>
  Target lifetime: <hours | days | months | years>
  Sleep modes: <light sleep | deep sleep | hibernation>

Production scale:
  Prototype quantity: <1-10 | 10-100 | 100+>
  Production target: <hundreds | thousands | millions>
  Certifications needed: <FCC | CE | UL | none yet>

Constraints:
  RAM: <KB available>
  Flash: <KB/MB available>
  Real-time requirements: <hard real-time | soft real-time | none>
  Operating temperature: <commercial | industrial | automotive>
```

### Step 2: Firmware Architecture

#### RTOS-Based Architecture
```
RTOS FIRMWARE STRUCTURE:
├── src/
│   ├── main.c                  # Application entry, task creation
│   ├── tasks/                  # FreeRTOS/Zephyr task implementations
│   │   ├── sensor_task.c       # Sensor reading task
│   │   ├── comms_task.c        # Communication task (MQTT/CoAP)
│   │   ├── control_task.c      # Actuator/control logic
│   │   └── ota_task.c          # OTA update handler
│   ├── drivers/                # Hardware abstraction layer
│   │   ├── gpio.c              # GPIO driver
│   │   ├── i2c.c               # I2C bus driver
│   │   ├── spi.c               # SPI bus driver
│   │   ├── uart.c              # UART driver
│   │   └── adc.c               # ADC driver
│   ├── hal/                    # Board-specific hardware config
│   │   ├── board.h             # Pin definitions, peripheral mapping
│   │   └── board.c             # Board initialization
│   ├── middleware/              # Protocol implementations
│   │   ├── mqtt_client.c       # MQTT connection and pub/sub
│   │   ├── coap_client.c       # CoAP request/response
│   │   └── ble_service.c       # BLE GATT service
│   ├── storage/                # Non-volatile storage
│   │   ├── config_store.c      # Configuration persistence
│   │   └── data_log.c          # Sensor data logging
│   └── utils/                  # Common utilities
│       ├── ring_buffer.c       # Lock-free ring buffer
│       ├── crc.c               # CRC calculation
│       └── watchdog.c          # Watchdog timer management
├── include/                    # Header files (mirrors src/ structure)
├── test/                       # Unit tests (Unity/CMock or Zephyr ztest)
├── boards/                     # Board-specific configs (Zephyr)
├── CMakeLists.txt              # Build system
└── sdkconfig / prj.conf        # SDK/RTOS configuration

Rules:
  - One task per concern (sensing, communication, control, OTA)
  - Tasks communicate via queues and event groups (never shared globals)
  - Drivers are hardware-abstracted (swap MCU without changing tasks)
  - All memory statically allocated (no malloc in production firmware)
  - Watchdog monitors all tasks — reset on task starvation
  - Error codes propagated (not silently ignored)
```

#### Bare-Metal Architecture
```
BARE-METAL FIRMWARE STRUCTURE:
Main loop architecture (super-loop):
  while(1) {
    1. Read sensors (poll or DMA buffer)
    2. Process data (filter, aggregate, threshold)
    3. Update outputs (actuators, display)
    4. Handle communication (send/receive packets)
    5. Check for OTA updates
    6. Enter lowest safe sleep mode
  }

Interrupt-driven architecture:
  ISR → Flag/Buffer → Main loop processes
  Rules:
    - ISRs are SHORT (set flag, buffer data, return)
    - Never do I/O, allocation, or complex logic in ISR
    - Use volatile for shared ISR/main-loop variables
    - Disable/enable interrupts for critical sections (keep minimal)

Timer-based scheduling:
  Use hardware timer to create pseudo-RTOS:
    Timer ISR fires at fixed interval (e.g., 1ms)
    Increment tick counter
    Schedule tasks by tick count (task A every 10ms, task B every 1s)
    Cooperative — tasks must yield quickly
```

### Step 3: Communication Protocol Design

#### MQTT
```
MQTT ARCHITECTURE:
Broker: <Mosquitto (self-hosted) | AWS IoT Core | HiveMQ | EMQX>
QoS strategy:
  Telemetry data: QoS 0 (at most once) — acceptable data loss for high-frequency
  Commands/config: QoS 1 (at least once) — ensure delivery
  Critical alerts: QoS 2 (exactly once) — no duplicates for alarms

Topic hierarchy:
  <org>/<site>/<device-type>/<device-id>/<data-type>
  Example:
    acme/factory-1/sensor/dev-001/temperature    — sensor readings
    acme/factory-1/sensor/dev-001/status          — device status
    acme/factory-1/sensor/dev-001/cmd             — commands to device
    acme/factory-1/sensor/dev-001/ota             — OTA update notifications
    $SYS/broker/clients/connected                  — broker system topics

Message format (keep small for constrained devices):
  Binary: CBOR or Protocol Buffers (smallest, most efficient)
  Text: JSON (human-readable, larger payload)
  Hybrid: JSON for prototyping, migrate to binary for production

Connection management:
  [ ] Clean session = false (persistent subscriptions)
  [ ] Last Will and Testament configured (offline detection)
  [ ] Keep-alive interval matched to sleep cycle
  [ ] Automatic reconnect with exponential backoff
  [ ] Client ID is unique and deterministic (e.g., MAC address)
  [ ] TLS 1.2+ with server certificate validation
  [ ] Client certificate for mutual authentication (mTLS)
```

#### CoAP
```
COAP ARCHITECTURE:
Use when: UDP is preferred, constrained networks, request-response pattern

Methods:
  GET: Read sensor value, configuration
  PUT: Update configuration, actuator state
  POST: Trigger action, submit data batch
  DELETE: Remove resource (rare in IoT)

Resource design:
  coap://<device>/.well-known/core   — Resource discovery
  coap://<device>/sensors/temp        — Temperature reading
  coap://<device>/sensors/humidity    — Humidity reading
  coap://<device>/config              — Device configuration
  coap://<device>/actuators/relay     — Relay control

Observe pattern (CoAP equivalent of MQTT subscribe):
  Client sends GET with Observe option
  Server sends notifications on resource change
  Reduces polling overhead significantly

Block-wise transfer:
  For payloads > ~1KB, use block options
  Essential for OTA updates over CoAP

DTLS:
  [ ] DTLS 1.2 for transport security
  [ ] Pre-shared keys (PSK) for resource-constrained devices
  [ ] Raw public keys or X.509 certificates for capable devices
```

### Step 4: OTA Update Strategies

```
OTA UPDATE ARCHITECTURE:

Update types:
  Full firmware: Replace entire application image
  Delta/diff: Apply binary patch (smaller download, complex)
  A/B partitioning: Dual firmware slots, swap on reboot
  Component: Update individual modules (requires modular architecture)

A/B UPDATE FLOW (RECOMMENDED):
  Slot A: Current running firmware (active)
  Slot B: Download target (inactive)

  1. Device checks for update (periodic poll or push notification)
  2. Download new firmware to Slot B (resumable, with integrity check)
  3. Verify Slot B (SHA-256 hash + signature verification)
  4. Mark Slot B as pending boot
  5. Reboot into Slot B
  6. New firmware self-tests (hardware check, connectivity check)
  7. If self-test passes: mark Slot B as confirmed (new active)
  8. If self-test fails: rollback to Slot A automatically

SECURITY:
  [ ] Firmware images signed with asymmetric key (Ed25519 or ECDSA P-256)
  [ ] Public key embedded in bootloader (not application — cannot be overwritten)
  [ ] Anti-rollback protection (version counter in one-time-programmable fuses)
  [ ] Encrypted firmware images (prevent IP extraction from captured updates)
  [ ] Secure boot chain: ROM bootloader → signed bootloader → signed application

RELIABILITY:
  [ ] Resumable downloads (store progress, continue after power loss)
  [ ] Integrity verification before applying (SHA-256 minimum)
  [ ] Automatic rollback on boot failure (watchdog-triggered)
  [ ] Update staging (canary → gradual rollout → full fleet)
  [ ] Minimum battery level required before starting update
  [ ] Separate bootloader from application (bootloader rarely updated)

FLEET ROLLOUT:
  Stage 1: Internal test devices (immediate)
  Stage 2: Canary group — 1% of fleet (24h observation)
  Stage 3: Gradual rollout — 10%, 25%, 50%, 100%
  Gate: Each stage requires success rate > 99% before proceeding
  Rollback: Automatic if failure rate > 1% at any stage
```

### Step 5: Power Optimization

```
POWER OPTIMIZATION STRATEGIES:

Sleep modes (typical power consumption):
  Active:      10-100 mA (MCU running, peripherals active)
  Light sleep:  1-5 mA (CPU paused, RAM retained, fast wake)
  Deep sleep:   10-100 uA (most peripherals off, RTC running)
  Hibernation:  1-10 uA (only RTC/wake pin active)

Duty cycling strategy:
  1. Wake from deep sleep (RTC timer or external interrupt)
  2. Initialize peripherals (only what is needed)
  3. Read sensors (power sensor → stabilize → read → power off)
  4. Process data locally (edge compute, reduce transmissions)
  5. Transmit if threshold exceeded or batch full
  6. Enter deepest safe sleep mode

COMMUNICATION OPTIMIZATION:
  [ ] Batch sensor readings (send 10 readings in one packet, not 10 packets)
  [ ] Compress payloads (CBOR vs JSON saves 30-50% bandwidth)
  [ ] Reduce transmission power to minimum reliable level
  [ ] Use connection-less protocols where possible (CoAP over MQTT)
  [ ] Schedule transmissions during low-traffic windows
  [ ] Negotiate longest possible MQTT keep-alive

PERIPHERAL MANAGEMENT:
  [ ] Power gate sensors (MOSFET switch, only power during reading)
  [ ] Use DMA for data transfer (CPU can sleep during transfer)
  [ ] Disable unused peripherals in hardware config
  [ ] Use lowest clock speed that meets timing requirements
  [ ] ADC: lower resolution = less power (10-bit vs 12-bit if precision allows)

BATTERY ESTIMATION:
  Formula: battery_life = capacity_mAh / average_current_mA
  Example:
    3000 mAh battery
    Deep sleep 95% of time at 50 uA = 0.05 mA
    Active 5% of time at 80 mA = 4 mA
    Average: (0.95 × 0.05) + (0.05 × 80) = 4.0475 mA
    Life: 3000 / 4.0475 = ~741 hours = ~30 days

  Improve by:
    - Increasing sleep percentage (reduce wake frequency)
    - Reducing active current (lower clock, fewer peripherals)
    - Reducing active duration (optimize code, use DMA)
    - Larger battery or solar harvesting

MEASUREMENT:
  [ ] Use current probe / power profiler (Nordic PPK2, Joulescope)
  [ ] Measure each operating mode separately
  [ ] Profile entire duty cycle (wake → work → sleep)
  [ ] Account for peak current (radio transmit bursts)
  [ ] Test at operating temperature extremes (battery capacity varies)
```

### Step 6: Device Fleet Management

```
FLEET MANAGEMENT ARCHITECTURE:
┌─────────────────────────────────────────────────┐
│  Cloud Platform                                  │
│  ├── Device Registry (identity, metadata, state) │
│  ├── Certificate Authority (device certificates)  │
│  ├── OTA Manager (firmware distribution)          │
│  ├── Telemetry Ingestion (time-series database)   │
│  ├── Command & Control (device shadow / twin)     │
│  ├── Alert Engine (threshold, anomaly detection)   │
│  └── Dashboard (fleet overview, device drill-down) │
├─────────────────────────────────────────────────┤
│  Device Shadow / Digital Twin                     │
│  ├── Desired state (set by cloud/user)            │
│  ├── Reported state (set by device)               │
│  └── Delta (difference triggers sync)             │
├─────────────────────────────────────────────────┤
│  Device (firmware)                                │
│  ├── Secure boot + identity (X.509 certificate)   │
│  ├── MQTT/CoAP client (shadow sync, telemetry)    │
│  ├── OTA client (download, verify, apply)          │
│  ├── Local data buffer (survive connectivity loss) │
│  └── Watchdog + health reporting                   │
└─────────────────────────────────────────────────┘

DEVICE PROVISIONING:
  Option 1 — Factory provisioning:
    Unique certificate + config flashed during manufacturing
    Most secure, requires manufacturing integration

  Option 2 — Just-in-time provisioning (JITP):
    Device connects with bootstrap certificate
    Cloud validates and issues production certificate
    Good for medium-scale deployments

  Option 3 — Fleet provisioning (claim-based):
    Shared claim certificate for initial connection
    Device proves identity, receives unique certificate
    Scalable, but claim certificate must be protected

MONITORING:
  [ ] Device heartbeat (last-seen timestamp, alert on missing)
  [ ] Firmware version tracking (fleet-wide version distribution)
  [ ] Connectivity metrics (RSSI, packet loss, reconnection frequency)
  [ ] Resource utilization (free RAM, flash wear, CPU load)
  [ ] Error rates (task failures, communication errors, sensor faults)
  [ ] Battery level / power source status
  [ ] Geographic distribution (if location-aware)
```

### Step 7: IoT Development Report

```
┌────────────────────────────────────────────────────────────────┐
│  IOT PROJECT — <project name>                                   │
├────────────────────────────────────────────────────────────────┤
│  MCU: <ESP32 | STM32 | nRF52 | custom>                         │
│  RTOS: <FreeRTOS | Zephyr | bare-metal>                         │
│  Connectivity: <MQTT/WiFi | CoAP/BLE | LoRa | Cellular>        │
│                                                                  │
│  Firmware status:                                                │
│    Architecture: <DESIGNED | IMPLEMENTED | TESTED | DEPLOYED>   │
│    OTA system: <DESIGNED | IMPLEMENTED | TESTED | DEPLOYED>     │
│    Security: <BASIC | TLS | MTLS | SECURE BOOT>                │
│                                                                  │
│  Power profile:                                                  │
│    Active current: <N mA>                                        │
│    Sleep current: <N uA>                                         │
│    Duty cycle: <N% active>                                       │
│    Estimated battery life: <N days/months/years>                 │
│                                                                  │
│  Fleet:                                                          │
│    Provisioning: <MANUAL | JITP | FLEET>                        │
│    OTA rollout: <MANUAL | STAGED | AUTOMATED>                   │
│    Monitoring: <NONE | BASIC | FULL>                             │
│                                                                  │
│  Communication:                                                  │
│    Protocol: <MQTT | CoAP | custom>                              │
│    QoS: <0 | 1 | 2>                                             │
│    Avg message size: <N bytes>                                   │
│    Messages per day: <N>                                         │
├────────────────────────────────────────────────────────────────┤
│  Next: /godmode:test — Test firmware (HIL + unit tests)          │
│        /godmode:secure — Security audit (TLS, auth, boot)        │
│        /godmode:ship — Production deployment                     │
└────────────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Transition
1. Commit firmware scaffold: `"iot: <mcu> — firmware architecture with <rtos>"`
2. Commit communication layer: `"iot: <protocol> — <broker/server> integration"`
3. Commit OTA system: `"iot: OTA — A/B update with signed firmware"`
4. If fleet-ready: "Firmware deployed. Run `/godmode:ship` for production rollout."
5. If prototyping: "Firmware scaffold complete. Run `/godmode:test` to add hardware-in-loop tests."

## Key Behaviors

1. **Memory is scarce.** Every byte counts on microcontrollers. Static allocation, stack analysis, and heap avoidance are standard practice, not optimization.
2. **Power determines product viability.** A battery device that dies in a week instead of a year is a failed product. Measure power consumption from day one.
3. **OTA is not optional.** Field-deployed devices without OTA capability become permanent liabilities. Design OTA into the architecture from the start.
4. **Security is hardware-rooted.** Software-only security on IoT devices is insufficient. Use secure boot, hardware crypto, and tamper detection where available.
5. **Test on real hardware.** Simulators miss timing issues, electrical noise, thermal behavior, and radio interference. Hardware-in-the-loop testing is essential.
6. **Connectivity will fail.** Devices must operate gracefully without connectivity. Buffer data locally, retry with backoff, and never block on network operations.

## Example Usage

### Building a sensor monitoring system
```
User: /godmode:iot Build a temperature/humidity monitoring system with ESP32

IoT: Assessing requirements...

IOT PROJECT:
MCU: ESP32-S3
RTOS: FreeRTOS (ESP-IDF)
Connectivity: MQTT over WiFi
Cloud: AWS IoT Core

Architecture:
  /src
    /tasks
      sensor_task.c    — Read DHT22 every 30s, buffer readings
      comms_task.c     — MQTT publish batched readings every 5 min
      ota_task.c       — Check for updates on boot + every 24h
    /drivers
      dht22.c          — DHT22 temperature/humidity driver
    /middleware
      mqtt_client.c    — AWS IoT MQTT with mTLS
    /storage
      config_store.c   — NVS-backed configuration

Power profile:
  Active: 80 mA (WiFi TX)
  Light sleep: 2 mA (between readings)
  Duty cycle: 3% active
  With 3000 mAh battery: ~27 days

OTA: A/B partition scheme, signed with Ed25519

Next: /godmode:test to add unit tests (Unity framework)
      /godmode:secure to audit TLS and provisioning
```

## HARD RULES
1. NEVER use dynamic memory allocation (malloc/new) in production firmware — use static allocation and memory pools.
2. NEVER busy-wait/poll between sensor readings — use sleep modes with timer/interrupt wakeup.
3. NEVER skip watchdog timers on field-deployed devices — watchdog is the last defense against permanent hangs.
4. NEVER hardcode WiFi credentials or API keys in firmware source — use provisioning flows (BLE, QR, NFC).
5. NEVER deploy firmware without rollback capability — always maintain a known-good fallback image.
6. NEVER send raw sensor data to the cloud at high frequency — aggregate locally, transmit summaries.
7. NEVER trust incoming network data — validate all commands, verify server certificates, treat every message as potentially malicious.
8. ALWAYS sign firmware images with asymmetric keys (Ed25519 or ECDSA P-256) — public key in bootloader.
9. ALWAYS implement anti-rollback protection with monotonic version counters.
10. ALWAYS measure power consumption with a current probe from day one — estimated != actual.

## Auto-Detection
On activation, detect IoT project context automatically:
```
AUTO-DETECT:
1. Detect MCU/platform:
   - sdkconfig, sdkconfig.defaults → ESP32 (ESP-IDF)
   - CMakeLists.txt + prj.conf → Zephyr RTOS
   - FreeRTOSConfig.h → FreeRTOS
   - platformio.ini → PlatformIO project
   - arduino.json, *.ino → Arduino
   - Makefile + STM32*.ld → STM32 bare-metal
2. Detect RTOS:
   - FreeRTOS headers (task.h, queue.h, semphr.h)
   - Zephyr headers (zephyr/kernel.h)
   - No RTOS headers → bare-metal
3. Detect connectivity:
   - mqtt*, MQTTClient → MQTT protocol
   - coap*, CoAP → CoAP protocol
   - ble*, BLE*, bluetooth → BLE
   - lora*, LoRa → LoRaWAN
   - wifi*, WiFi → WiFi connectivity
4. Detect cloud platform:
   - aws_iot*, AWS IoT SDK → AWS IoT Core
   - azure_iot*, IoTHubClient → Azure IoT Hub
   - google_cloud_iot → GCP IoT
5. Detect OTA implementation:
   - esp_ota*, esp_https_ota → ESP32 OTA
   - mcuboot → MCUboot bootloader
   - partition table with ota_0, ota_1 → A/B partitioning
6. Scan for power management:
   - esp_sleep*, deep_sleep → Sleep mode implementation
   - pm_*, power_manager → Power management module
```

## Firmware Development Loop
Firmware development is iterative — build, flash, test, measure, optimize:
```
current_iteration = 0
target_met = false

WHILE NOT target_met:
  1. BUILD firmware: cmake --build build/
  2. FLASH to target device: esptool.py flash / west flash / st-flash
  3. TEST on real hardware:
     a. Functional test: sensors read correctly, communication works
     b. Power measurement: measure active/sleep current with probe
     c. Stability test: run for N hours, check watchdog resets
  4. MEASURE against targets:
     - Battery life estimate vs target
     - Communication reliability vs target
     - Memory usage (stack high watermark, heap remaining)
  5. IF any target not met:
     - IDENTIFY bottleneck (power? memory? timing? reliability?)
     - OPTIMIZE: adjust sleep timing, reduce TX power, optimize code
     - current_iteration += 1
  6. IF all targets met:
     - target_met = true
  7. IF current_iteration > 20:
     - REPORT: "Hardware constraints may prevent meeting targets"
     - SUGGEST: hardware changes or target relaxation
     - WAIT for user decision

EXIT when targets met OR user accepts current state
```

## Multi-Agent Dispatch
For IoT projects with multiple firmware components:
```
DISPATCH parallel agents (one per firmware layer):

Agent 1 (worktree: iot-drivers):
  - Hardware drivers and HAL
  - Scope: drivers/, hal/, board-specific code
  - Output: Tested driver implementations

Agent 2 (worktree: iot-comms):
  - Communication protocol stack
  - Scope: middleware/mqtt*, middleware/coap*, middleware/ble*
  - Output: Protocol implementation with reconnect/retry logic

Agent 3 (worktree: iot-ota):
  - OTA update system
  - Scope: ota_task, bootloader config, partition table
  - Output: A/B OTA with signature verification and rollback

Agent 4 (worktree: iot-tests):
  - Unit tests + integration tests
  - Scope: test/ directory
  - Output: Unity/Ztest test suite for all modules

MERGE ORDER: drivers → comms → ota → tests
CONFLICT RESOLUTION: drivers branch owns HAL interfaces that others depend on
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full IoT project assessment and setup |
| `--power` | Power optimization analysis only |
| `--ota` | OTA update system design only |
| `--fleet` | Fleet management architecture only |
| `--protocol <name>` | Design specific protocol (mqtt, coap, ble, lora) |
| `--mcu <name>` | Target specific MCU (esp32, stm32, nrf52, rp2040) |
| `--rtos <name>` | Use specific RTOS (freertos, zephyr, baremetal) |

## Anti-Patterns

- **Do NOT use dynamic memory allocation in production firmware.** Heap fragmentation on devices without virtual memory leads to crashes after hours/days of operation. Use static allocation and memory pools.
- **Do NOT poll when you can sleep.** A device that busy-waits between readings wastes orders of magnitude more power than one that sleeps and wakes on timer interrupt.
- **Do NOT skip watchdog timers.** Field-deployed devices will encounter conditions you never tested. The watchdog is the last line of defense against permanent hangs.
- **Do NOT send raw sensor data to the cloud.** Process and aggregate locally. A temperature reading every second does not need 86,400 cloud messages per day — send minutely averages.
- **Do NOT hardcode WiFi credentials or API keys in firmware.** Use provisioning flows (BLE setup, QR code, NFC) to configure credentials at deployment time.
- **Do NOT ignore brownout detection.** Low battery voltage causes erratic behavior, not clean shutdowns. Detect low voltage and enter safe mode before data corruption occurs.
- **Do NOT deploy without rollback capability.** A bad OTA update to a device in the field without rollback capability is a permanent brick. Always maintain a known-good fallback image.
- **Do NOT trust the network.** Validate all incoming commands, verify server certificates, and treat every message as potentially malicious. IoT devices are high-value attack targets.
