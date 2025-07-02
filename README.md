# 🕶️ ShadowCloak - Advanced Privacy & Anonymity Suite

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Version](https://img.shields.io/badge/Version-1.0-brightgreen.svg)](https://github.com/TechVenom/ShadowCloak)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen.svg)](https://github.com/TechVenom/ShadowCloak)

> **A comprehensive, modular privacy and anonymity toolkit designed for cybersecurity professionals and privacy-conscious users.**

## 📋 Table of Contents

- [🎯 Overview](#-overview)
- [✨ Features](#-features)
- [🏗️ Architecture](#️-architecture)
- [🚀 Installation](#-installation)
- [📖 Usage](#-usage)
- [🔧 Configuration](#-configuration)
- [🛡️ Security](#️-security)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [👨‍💻 Author](#-author)

## 🎯 Overview

ShadowCloak is a professional-grade privacy and anonymity suite built with a modular architecture for maximum flexibility and maintainability. Designed by cybersecurity experts, it provides comprehensive protection through multiple layers of anonymization techniques.

### 🎪 Key Highlights

- **🔒 Enterprise-Grade Security**: Professional anonymization techniques
- **🧩 Modular Architecture**: Clean, maintainable, and extensible codebase
- **🌐 Network Safety**: No connection-breaking aggressive rules
- **🎯 User-Friendly**: Interactive and silent operation modes
- **📊 Comprehensive**: 9 distinct privacy protection features

## ✨ Features

### 🌐 Network Anonymization
- **Tor Integration**: Safe Tor routing without connection disruption
- **IP Detection**: Multiple fallback methods for reliable IP detection
- **DNS Protection**: Secure DNS configuration with leak prevention
- **Protocol Hardening**: IPv6 disabling and unnecessary protocol blocking

### 🎭 Identity Obfuscation
- **MAC Randomization**: Network interface anonymization with restoration
- **Hostname Camouflage**: Dynamic hostname changing with backup
- **Timezone Randomization**: Geographic location obfuscation
- **Combined Identity Changes**: One-click complete identity transformation

### 💻 System Privacy
- **Log Wiping**: Comprehensive system and application log clearing
- **Memory Clearing**: RAM and cache sanitization
- **Browser Hardening**: Firefox, Chrome, and Brave privacy configuration
- **Secure Deletion**: Multi-pass file wiping capabilities

### 🛠️ Advanced Features
- **Interactive Mode**: User-friendly feature selection interface
- **Silent Mode**: Automated operation for scripting
- **Status Monitoring**: Real-time system anonymity status
- **Backup & Restore**: Safe configuration backup and restoration

## 🏗️ Architecture

ShadowCloak follows a clean modular architecture for optimal maintainability:

```
shadowcloak/
├── shadowcloak_modular.sh    # Main orchestrator script
├── install.sh                # System-wide installation
└── modules/                  # Modular components
    ├── config.sh            # Configuration management
    ├── utils.sh             # Utility functions
    ├── network.sh           # Network operations
    ├── anonymity.sh         # Identity obfuscation
    ├── system.sh            # System operations
    ├── browser.sh           # Browser hardening
    └── interface.sh         # User interface
```

### 📊 Module Statistics
| Module | Functions | Purpose |
|--------|-----------|---------|
| config.sh | 2 | Configuration & variables |
| utils.sh | 15 | Utilities & helpers |
| network.sh | 8 | Network operations |
| anonymity.sh | 11 | Identity obfuscation |
| system.sh | 8 | System operations |
| browser.sh | 7 | Browser hardening |
| interface.sh | 9 | User interface |

## 🚀 Installation

### Quick Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/TechVenom/ShadowCloak.git
cd ShadowCloak

# Run the installer
chmod +x install.sh
sudo ./install.sh

# Use system-wide
shadowcloak start
```

### Manual Installation

```bash
# Make scripts executable
chmod +x shadowcloak_modular.sh modules/*.sh

# Run directly
sudo ./shadowcloak_modular.sh start
```

### Dependencies

ShadowCloak automatically installs required dependencies:
- `tor` - Anonymity network
- `macchanger` - MAC address manipulation
- `curl` - Network operations
- `systemd` - Service management

## 📖 Usage

### Interactive Mode
```bash
# Start interactive feature selection
shadowcloak start

# With specific network interface
shadowcloak start --iface wlan0
```

### Silent Mode
```bash
# Activate all features automatically
shadowcloak start --silent

# With secure logging
shadowcloak start --silent --secure-log
```

### Individual Features
```bash
shadowcloak tor          # Tor routing only
shadowcloak mac          # MAC randomization
shadowcloak dns          # DNS protection
shadowcloak hostname     # Hostname change
shadowcloak timezone     # Timezone randomization
shadowcloak logs         # Log wiping
shadowcloak browser      # Browser hardening
shadowcloak memory       # Memory clearing
shadowcloak protocols    # Protocol hardening
```

### System Management
```bash
shadowcloak status       # Show current status
shadowcloak changeid     # Change Tor identity + MAC
shadowcloak stop         # Stop and restore settings
shadowcloak help         # Display help
```

## 🔧 Configuration

### Configuration File
Location: `/etc/shadowcloak/shadowcloak.conf`

```bash
# Network interface (auto-detect if empty)
INTERFACE=""

# Default operation mode
SILENT_MODE=false

# Enable encrypted logging
SECURE_LOG=false

# Default features for silent mode
DEFAULT_FEATURES="0,1,2,3,4,5,6,7,8"
```

### Environment Variables
```bash
export SHADOWCLOAK_INTERFACE="wlan0"
export SHADOWCLOAK_SILENT="true"
export SHADOWCLOAK_SECURE_LOG="true"
```

## 🛡️ Security

### Security Features
- ✅ **Safe Network Operations**: No aggressive iptables rules
- ✅ **Graceful Fallbacks**: Multiple detection methods
- ✅ **Secure Logging**: Optional GPG encryption
- ✅ **Backup Protection**: Automatic configuration backup
- ✅ **Clean Restoration**: Complete settings restoration

### Security Considerations
- Always run as root for system-level modifications
- Review configuration before deployment
- Test in isolated environment first
- Keep backups of original configurations

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines
- Follow existing code style and structure
- Add appropriate documentation
- Test thoroughly before submitting
- Update README if needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Hezron Paipai (TechVenom)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👨‍💻 Author

**Hezron Paipai (TechVenom)**
- 🎓 Computer System Engineer
- 🔬 AI Developer & Researcher  
- 🛡️ Cybersecurity Expert
- 🌐 Full Stack Developer
- 🤖 AI Agents Specialist

### Connect with me:
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:gptboy47@gmail.com)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/TechVenom)

---

<div align="center">

**⭐ If you find ShadowCloak useful, please consider giving it a star! ⭐**

*Built with ❤️ for the privacy and cybersecurity community*

</div>
