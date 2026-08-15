# 🛡️ IntraLinux Secure Shield

[Türkçe (TR)](#-intralinux-güvenli-kalkan-tr) | [English (EN)](#-intralinux-secure-shield-en)

---

## 🛡️ IntraLinux Güvenli Kalkan (TR)

Türkiye'deki Discord engelini ve DPI (Derin Paket İncelemesi) sansürünü aşmak için tasarlanmış, Linux işletim sistemlerine özel CLI, arayüzsüz (headless) ve SSH uyumlu güvenli tünel istemcisi.

SOCKS5 ve HTTP Proxy protokolleri, DoH (DNS-over-HTTPS) şifreli DNS çözümü ve TLS SNI paket parçalama teknolojisi ile sunucularda ve masaüstü sistemlerde sorunsuz çalışır.

### 🌟 Özellikler
* **Tek Komutla Kur:** `curl | bash` komutuyla tam otomatik indirme ve kurulum.
* **Çift Protokol Desteği:** 10808 portunda SOCKS5, 10809 portunda HTTP Proxy.
* **DPI Sansür Engeli Aşma:** DoH şifreli DNS çözümü ve TLS SNI paket parçalama.
* **Systemd Servis Desteği:** Açılışta otomatik arka plan servisi olarak çalışma.
* **SSH Uyumlu Hızlı Proxy:** `eval` ile mevcut oturumunuzu anında proxy arkasına alma.
* **Gnome Masaüstü Entegrasyonu:** GUI Linux'ta sistem proxy ayarlarını otomatik yapma.

---

### ⚡ Tek Komutla Otomatik Kurulum

Aşağıdaki komutu terminalinize yapıştırın. Gerekli dosyaları indirir, yetkilerini ayarlar ve başlatır:

```bash
curl -fsSL https://raw.githubusercontent.com/htdocz/intra-linux/main/intralinux.sh -o intralinux.sh && curl -fsSL https://github.com/htdocz/intra-linux/raw/main/bin/intra-linuxdpi -o intra-linuxdpi && mkdir -p bin && mv intra-linuxdpi bin/ && chmod +x intralinux.sh bin/intra-linuxdpi && ./intralinux.sh start
```

> 💡 Bu komut: scripti ve backend binary'yi indirir, `bin/` klasörüne yerleştirir, çalıştırma yetkisi verir ve tüneli başlatır.

---

### 🚀 Manuel Kurulum ve Kullanım

1. **Dosyalara Çalıştırma Yetkisi Verin:**
   ```bash
   chmod +x intralinux.sh bin/intra-linuxdpi
   ```

2. **Tüneli Arka Planda Başlatın:**
   ```bash
   ./intralinux.sh start
   ```

3. **Durumu Kontrol Edin:**
   ```bash
   ./intralinux.sh status
   ```

4. **Durdurmak İçin:**
   ```bash
   ./intralinux.sh stop
   ```

5. **Yeniden Başlatmak İçin:**
   ```bash
   ./intralinux.sh restart
   ```

---

### 🖥️ SSH ve Terminal (CLI) İçin Proxy Aktifleştirme

`curl`, `wget`, `apt-get` gibi araçların tünelden çıkmasını istiyorsanız:

* **Mevcut terminali proxy arkasına al:**
  ```bash
  eval $(./intralinux.sh env)
  ```

* **Proxy'yi kaldır:**
  ```bash
  eval $(./intralinux.sh unenv)
  ```

---

### ⚙️ Sistem Servisi Olarak Kurulum (Otomatik Başlangıç)

```bash
# Servis olarak kur (sudo gerekir)
sudo ./intralinux.sh install

# Standart systemd komutları
sudo systemctl start intralinux
sudo systemctl stop intralinux
sudo systemctl status intralinux

# Kaldırmak için
sudo ./intralinux.sh uninstall
```

---

### 🎨 Gnome Masaüstü Entegrasyonu

```bash
./intralinux.sh enable-gui   # Gnome sistem proxy'sini tünele bağlar
./intralinux.sh disable-gui  # Proxy ayarlarını devre dışı bırakır
```

---
---

## 🛡️ IntraLinux Secure Shield (EN)

A Linux-native CLI, headless, and SSH-friendly secure tunnel client designed to bypass Discord censorship and DPI (Deep Packet Inspection) filtering active in Turkey.

Runs seamlessly on servers and desktop systems using dual-protocol SOCKS5/HTTP Proxy, DoH encrypted DNS resolution, and TLS SNI packet splitting.

### 🌟 Features
* **One-Command Install:** Fully automatic download and setup via `curl | bash`.
* **Dual Protocol Proxy:** SOCKS5 on port 10808 and HTTP Proxy on port 10809.
* **DPI Censorship Bypass:** Encrypted DoH DNS resolution and TLS SNI packet splitting.
* **Systemd Integration:** Install as an autostart daemon service at boot.
* **SSH Friendly CLI Proxy:** Instantly inject proxy env vars into the active shell via `eval`.
* **Gnome Desktop Configurator:** Auto-configure system proxy on GUI Linux desktops.

---

### ⚡ One-Command Automatic Install

Paste the command below into your terminal. It downloads the required files, sets permissions, and starts the tunnel:

```bash
curl -fsSL https://raw.githubusercontent.com/htdocz/intra-linux/main/intralinux.sh -o intralinux.sh && curl -fsSL https://github.com/htdocz/intra-linux/raw/main/bin/intra-linuxdpi -o intra-linuxdpi && mkdir -p bin && mv intra-linuxdpi bin/ && chmod +x intralinux.sh bin/intra-linuxdpi && ./intralinux.sh start
```

> 💡 This command: downloads the manager script and backend binary, places it in the `bin/` folder, sets executable permissions, and starts the tunnel.

---

### 🚀 Manual Installation & Usage

1. **Grant Executable Permissions:**
   ```bash
   chmod +x intralinux.sh bin/intra-linuxdpi
   ```

2. **Start the Tunnel in Background:**
   ```bash
   ./intralinux.sh start
   ```

3. **Check Status:**
   ```bash
   ./intralinux.sh status
   ```

4. **Stop the Tunnel:**
   ```bash
   ./intralinux.sh stop
   ```

5. **Restart:**
   ```bash
   ./intralinux.sh restart
   ```

---

### 🖥️ SSH & Terminal (CLI) Session Proxying

For tools like `curl`, `wget`, or package managers (apt, yum) to route through the tunnel:

* **Proxy the active terminal session:**
  ```bash
  eval $(./intralinux.sh env)
  ```

* **Remove proxy from session:**
  ```bash
  eval $(./intralinux.sh unenv)
  ```

---

### ⚙️ Installing as a Systemd Service (Autostart)

```bash
# Install as systemd service (requires sudo)
sudo ./intralinux.sh install

# Manage via standard systemd commands
sudo systemctl start intralinux
sudo systemctl stop intralinux
sudo systemctl status intralinux

# Remove the service
sudo ./intralinux.sh uninstall
```

---

### 🎨 GUI Desktop Configuration (GNOME)

```bash
./intralinux.sh enable-gui   # Enables Gnome proxy and routes to localhost ports
./intralinux.sh disable-gui  # Disables Gnome system proxy
```
