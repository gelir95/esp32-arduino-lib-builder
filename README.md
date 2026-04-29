# ESP32 Arduino Lib Builder [![ESP32 Arduino Libs CI](https://github.com/espressif/esp32-arduino-lib-builder/actions/workflows/push.yml/badge.svg)](https://github.com/espressif/esp32-arduino-lib-builder/actions/workflows/push.yml)

This repository contains the scripts that produce the libraries included with esp32-arduino.

Tested on Ubuntu (32 and 64 bit), Raspberry Pi and MacOS.

### Build on Ubuntu and Raspberry Pi
```bash
sudo apt-get install git wget curl libssl-dev libncurses-dev flex bison gperf python python-pip python-setuptools python-serial python-click python-cryptography python-future python-pyparsing python-pyelftools cmake ninja-build ccache jq
sudo pip install --upgrade pip
git clone https://github.com/espressif/esp32-arduino-lib-builder
cd esp32-arduino-lib-builder
./build.sh
```

### Using the User Interface

You can more easily build the libraries using the user interface found in the `tools/config_editor/` folder.
It is a Python script that allows you to select and edit the options for the libraries you want to build.
The script has mouse support and can also be pre-configured using the same command line arguments as the `build.sh` script.
For more information and troubleshooting, please refer to the [UI README](tools/config_editor/README.md).

To use it, follow these steps:

1. Make sure you have the following prerequisites:
  - Python 3.9 or later
  - All the dependencies listed in the previous section

2. Install the required UI packages using `pip install -r tools/config_editor/requirements.txt`.

3. Execute the script `tools/config_editor/app.py` from any folder. It will automatically detect the path to the root of the repository.

4. Configure the compilation and ESP-IDF options as desired.

5. Click on the "Compile Static Libraries" button to start the compilation process.

6. The script will show the compilation output in a new screen. Note that the compilation process can take many hours, depending on the number of libraries selected and the options chosen.

7. If the compilation is successful and the option to copy the libraries to the Arduino Core folder is enabled, it will already be available for use in the Arduino IDE. Otherwise, you can find the compiled libraries in the `esp32-arduino-libs` folder alongside this repository.
  - Note that the copy operation doesn't currently support the core downloaded from the Arduino IDE Boards Manager, only the manual installation from the [`arduino-esp32`](https://github.com/espressif/arduino-esp32) repository.

### Documentation

For more information about how to use the Library builder, please refer to this [Documentation page](https://docs.espressif.com/projects/arduino-esp32/en/latest/lib_builder.html?highlight=lib%20builder)

---

## Bluepad32 Branch

The `bluepad32` branch of this fork builds a custom Arduino-ESP32 framework with **Bluepad32 v4.2.0** on **ESP-IDF release/v5.4**, solving the ESP-NOW coexistence issue present in Core 2.x.

### Prerequisites

WSL2 with Ubuntu 22.04:

```bash
sudo apt install python3-venv python3-dev python3-pip \
  git wget curl libssl-dev libncurses-dev flex bison gperf \
  cmake ninja-build ccache jq
```

### Build

```bash
git clone -b bluepad32 https://github.com/gelir95/esp32-arduino-lib-builder.git
cd esp32-arduino-lib-builder

# Install ESP-IDF tools (one-time, ~500 MB)
bash ./esp-idf/install.sh
source ./esp-idf/export.sh

# Build framework (~40–90 min depending on CPU)
AR_USER=espressif bash ./build.sh -s -e -t esp32
```

### Create release packages

```bash
# Board zip (framework-arduinoespressif32)
bash ./tools/package-bluepad32.sh
# → dist/esp32-bluepad32-<version>.zip

# Libs zip (framework-arduinoespressif32-libs)
cd out/tools/esp32-arduino-libs && zip -r ~/bluepad32-libs.zip . && cd -
```

Upload both zips as a GitHub release, then reference them in your project.

### PlatformIO integration

```ini
[env:myboard]
platform = https://github.com/pioarduino/platform-espressif32/releases/download/55.03.37/platform-espressif32.zip
board = esp32dev
framework = arduino
platform_packages =
    framework-arduinoespressif32@https://github.com/gelir95/esp32-arduino-lib-builder/releases/download/<tag>/esp32-bluepad32-<version>.zip
    framework-arduinoespressif32-libs@https://github.com/gelir95/esp32-arduino-lib-builder/releases/download/<tag>/bluepad32-libs.zip
```
