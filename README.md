# 🛡️ IntraLinux Secure Shield - Linux CLI & Headless Client

[Turkish (TR)](#-intralinux-güvenli-kalkan---linux-cli-ve-arayüzsüz-istemci-tr) | [English (EN)](#-intralinux-secure-shield---linux-cli-and-headless-client-en)

---

## 🛡️ IntraLinux Güvenli Kalkan - Linux CLI ve Arayüzsüz İstemci (TR)

Bu dizin, **IntraLinux** projesinin Linux işletim sistemleri (Sunucular, Ubuntu, Debian, CentOS vb.) için hazırlanmış olan komut satırı (CLI), arayüzsüz (headless) ve SSH uyumlu istemci sürümünü içerir. 

Sunucularda veya arayüzü olmayan (headless) sistemlerde tek bir komutla aç/kapa yapabilir, arka planda servis olarak çalıştırabilir veya SSH oturumunuzu anında proxy arkasına alabilirsiniz.

### 🌟 Özellikler
* **Çift Protokol Desteği:** 10808 portunda SOCKS5 ve 10809 portunda HTTP Proxy sunucusu.
* **DPI Sansür Engeli Aşma:** Güvenli DoH (DNS-over-HTTPS) çözümü ve TLS SNI paket parçalama teknolojisi ile Discord vb. engelleri aşma.
* **Systemd Servis Desteği:** Bilgisayar açılışında arka planda otomatik olarak başlama yeteneği.
* **SSH Uyumlu Hızlı Proxy:** `eval` komutu ile mevcut terminal oturumunuzu anında proxy arkasına alma.
* **Gnome Masaüstü Entegrasyonu:** GUI arayüzlü Linux sistemlerinde sistem proxy ayarlarını otomatik yapabilme.

### 🚀 Hızlı Başlangıç

1. **Dosyalara Çalıştırma Yetkisi Verin:**
   ```bash
   chmod +x intralinux.sh bin/intra-linuxdpi
   ```

2. **İstemciyi Arka Planda Başlatın:**
   ```bash
   ./intralinux.sh start
   ```

3. **Çalışma Durumunu Kontrol Edin:**
   ```bash
   ./intralinux.sh status
   ```

4. **Durdurmak İçin:**
   ```bash
   ./intralinux.sh stop
   ```

---

### 🖥️ SSH ve Terminal (CLI) İçin Proxy Aktifleştirme
Sunucuda çalışırken wget, curl veya apt-get gibi araçların proxy üzerinden internete çıkmasını istiyorsanız mevcut terminal oturumunuzda şu komutu çalıştırmanız yeterlidir:

* **Terminal Oturumunu Proxy Arkasına Al:**
  ```bash
  eval $(./intralinux.sh env)
  ```
  *(Bu komut `http_proxy`, `https_proxy` ve `all_proxy` ortam değişkenlerini otomatik ayarlar)*

* **Terminal Proxy Ayarlarını İptal Et:**
  ```bash
  eval $(./intralinux.sh unenv)
  ```

---

### ⚙️ Sistem Servisi Olarak Yükleme (Otomatik Başlangıç)
Programın sistem açılışında arka planda otomatik olarak çalışmasını istiyorsanız, onu bir `systemd` servisi olarak kaydedebilirsiniz:

1. **Servis Olarak Kaydet (sudo yetkisi gerekir):**
   ```bash
   sudo ./intralinux.sh install
   ```

2. **Servisi Yönetmek İçin Standart Komutlar:**
   ```bash
   sudo systemctl start intralinux
   sudo systemctl stop intralinux
   sudo systemctl status intralinux
   ```

3. **Servisi Kaldırmak İçin:**
   ```bash
   sudo ./intralinux.sh uninstall
   ```

---

### 🎨 GUI Masaüstü Entegrasyonu (Gnome kullanan sistemler için)
Masaüstü Linux (Ubuntu Desktop, Fedora vb.) kullanıyorsanız, sistem genelindeki proxy ayarlarını tek tıkla yapılandırabilirsiniz:
```bash
./intralinux.sh enable-gui   # Gnome sistem proxy ayarlarını elle SOCKS5/HTTP yönlendirir
./intralinux.sh disable-gui  # Proxy ayarlarını devre dışı bırakır (Varsayılana döner)
```

---
---

## 🛡️ IntraLinux Secure Shield - Linux CLI and Headless Client (EN)

This directory contains the Command Line Interface (CLI), headless, and SSH-friendly client edition of **IntraLinux** built for Linux operating systems (Ubuntu, Debian, CentOS, servers, etc.).

It allows you to start/stop the secure tunnel with a single command, run it as a system service in the background, or instantly proxy your current SSH session.

### 🌟 Features
* **Dual Protocol Proxy:** SOCKS5 on port 10808 and HTTP Proxy on port 10809.
* **DPI Censorship Bypass:** Secure DoH (DNS-over-HTTPS) resolution combined with TLS SNI packet splitting.
* **Systemd Integration:** Install as a system daemon to automatically run on startup.
* **SSH Friendly CLI Proxy:** Instantly inject proxy environment variables to the active shell using `eval`.
* **Gnome Desktop Proxy Configurator:** Quickly update GNOME desktop system proxy preferences.

### 🚀 Quick Start

1. **Grant Executable Permissions:**
   ```bash
   chmod +x intralinux.sh bin/intra-linuxdpi
   ```

2. **Start the Tunnel in Background:**
   ```bash
   ./intralinux.sh start
   ```

3. **Check the Status:**
   ```bash
   ./intralinux.sh status
   ```

4. **Stop the Tunnel:**
   ```bash
   ./intralinux.sh stop
   ```

---

### 🖥️ SSH & Terminal (CLI) Session Proxying
If you want CLI tools like curl, wget, or package managers (apt, yum) to route through the secure tunnel in your current terminal session, run:

* **Proxy the Active Terminal Shell:**
  ```bash
  eval $(./intralinux.sh env)
  ```
  *(This sets the `http_proxy`, `https_proxy`, and `all_proxy` environment variables for your current session)*

* **Disable Terminal Shell Proxy:**
  ```bash
  eval $(./intralinux.sh unenv)
  ```

---

### ⚙️ Installing as a Systemd Service (Autostart)
To run IntraLinux as a system service that launches automatically at system boot, install the systemd daemon:

1. **Install Service (requires sudo privileges):**
   ```bash
   sudo ./intralinux.sh install
   ```

2. **Manage the Service:**
   ```bash
   sudo systemctl start intralinux
   sudo systemctl stop intralinux
   sudo systemctl status intralinux
   ```

3. **Uninstall the Service:**
   ```bash
   sudo ./intralinux.sh uninstall
   ```

---

### 🎨 GUI Desktop Configuration (For GNOME DE)
If you are on a desktop Linux system with Gnome, configure system-wide proxy settings easily:
```bash
./intralinux.sh enable-gui   # Enables Gnome proxy settings and points to localhost ports
./intralinux.sh disable-gui  # Disables Gnome proxy settings
```
