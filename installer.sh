#!/bin/bash

# check whether if its in the Evanense directory
if [ "$(basename $(pwd))" != "Evanense" ]; then
  if [ -d Evanense ]; then
    cd Evanense || exit 1
  else
    echo "[!] Evanense directory not found!"
    exit 1
  fi
fi

chmod +x main.rb

# Build alias with full path
EVAN_PATH="$(pwd)/main.rb"
OS="$(uname)"

case "$OS" in
    Linux)
        PLATFORM="linux"
        ;;
    Darwin)
        PLATFORM="macos"
        ;;
    *)
        echo "[!] Unsupported OS: $OS"
        exit 1
        ;;
esac

# Detect current shell
SHELL_NAME=$(basename "$SHELL")

case "$SHELL_NAME" in
    bash)
        if [ "$PLATFORM" = "macos" ]; then
            RC_FILE="$HOME/.bash_profile"
        else
            RC_FILE="$HOME/.bashrc"
        fi
        ALIAS="alias evanense='ruby \"$EVAN_PATH\"'"
        ;;
    zsh)
        RC_FILE="$HOME/.zshrc"
        ALIAS="alias evanense='ruby \"$EVAN_PATH\"'"
        ;;
    fish)
        RC_FILE="$HOME/.config/fish/config.fish"
        ALIAS="function evanense; ruby \"$EVAN_PATH\"; end"
        ;;
    *)
        echo "[!] Unsupported shell: $SHELL_NAME"
        exit 1
        ;;
esac

# Avoid duplicate alias
if ! grep -Fxq "$ALIAS" "$RC_FILE"; then
    echo "$ALIAS" >> "$RC_FILE"
    echo "[+] Alias added to $RC_FILE"
else
    echo "[*] Alias already exists in $RC_FILE — skipping."
fi

echo "[*] Reload your shell or run 'source $RC_FILE' to activate the alias."
echo "[*] Type 'evanense' to launch the shell!"
