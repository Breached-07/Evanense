# Evanense
A Tor-enabled pentest shell that auto-routes tools through torsocks or proxychains.

**Evanense** is a Ruby-based pentesting shell that automatically routes supported network commands through the Tor network using `torsocks` or `proxychains`. It also includes convenience features like circuit rotation, IP verification, updates, and cross-platform Tor bootstrapping.

---

## 🚀 Features

- 🧅 **Tor Integration** – Auto-routes tools like `curl`, `nmap`, `ffuf`, etc. through Tor.
- 🔁 **Circuit Switching** – Use `nis` to request a new Tor identity.
- 🌍 **Tor IP Check** – View your current Tor exit IP using `torip`.
- 🛠 **Fallback to Proxychains** – If `torsocks` fails, it tries `proxychains`.
- 💾 **Auto Alias Installer** – Use `evanense` from anywhere.
- 📦 **Update from Git** – Run `update` to pull the latest version.
- 🧼 **Uninstall support** *(coming soon)*

---

## 📦 Installation

  Ensure the following are installed (Prequisties):

### For Debian/Ubuntu:

```bash
sudo apt install ruby tor torsocks proxychains netcat curl git 
```
### For macOS (via Homebrew):

```bash
brew install ruby tor torsocks proxychains netcat curl git 
```
### For Arch-based Distros

```bash
sudo pacman -Syu ruby tor torsocks proxychains-ng curl git inetutils gnu-netcat
```
## Clone & Install
```bash
git clone https://github.com/yourusername/evanense.git
cd evanense
./installer.sh
```

#### Then reload your shell:

```bash
source ~/.bashrc       # or ~/.zshrc, ~/.bash_profile, etc.
```

#### ✅ Now launch it with:

```bash
evanense
```

## Tor ControlPort Security Note
  #### The nis feature uses:

```bash
echo -e "AUTHENTICATE\nSIGNAL NEWNYM\nQUIT" | nc 127.0.0.1 9051
```
 #### Make sure you have this in your /etc/tor/torrc for it to work:

```yaml
ControlPort 9051
CookieAuthentication 0
```
⚠️ This is not recommended for production or shared systems. In future versions, we may support hashed passwords or cookie authentication.



