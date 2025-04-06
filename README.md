<div align="center">
  <img src="https://github.com/user-attachments/assets/ea0eea07-3cc8-4854-ad19-0577dff630e1" alt="logo" style="width: 40%;">
  <h1>Hydrith</h1>
  
  [About](#about) • [Install](#installation) • [Usage](#usage)

</div>

## About
**Hydrith** is a simple yet powerful tool to detect and remove digital footprints from Linux systems. Perfect for privacy-focused users, pentesters, or anyone wanting to clean their traces.

---

## Features
- Remove digital footprints (bash history, logs, etc.)
- Detect existing traces before wiping
- Creates fake log files
- Lightweight and fast

---

## Supported On

| OS | Platform | Version | Sudo |
|----------|----------|----------|----------|
| Windows | Cygwin | ALL | False |
| Linux | Ubuntu | ALL | True |
| Kali Linux | Kali Linux | ALL | True |
---

## Installation

Clone the repository and set executable permissions:
```bash
git clone https://github.com/Trabbit0ne/Hydrith && cd Hydrith && chmod +x *
```

---

## Usage

### To Remove Traces:
```bash
./main.sh
```

### To Detect Traces:
```bash
./detector.sh
```

---

## Notes
- Tested on most major Linux distributions.
- Run with root privileges for full effect.

---
