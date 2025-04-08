#!/bin/sh

STABLE_VERSION=`curl -sl https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE`
echo "Latest stable version : -${STABLE_VERSION}-"


# Function to download and install ChromeDriver
install_chromedriver() {
    CHROME_URL=$1

    TMP_DIR="/tmp/chromedriver_download"
    mkdir -p $TMP_DIR
    # Download the ChromeDriver zip file
    echo "Download Chrome Driver $CHROME_URL"
    curl -s -o /tmp/chromedriver.zip $CHROME_URL

    # Unzip the downloaded file
    unzip -q /tmp/chromedriver.zip -d $TMP_DIR

    # Move the ChromeDriver binary to /usr/local/bin
    sudo mv $TMP_DIR/*/chromedriver /usr/local/bin/

    # Clean up
    rm -rf /tmp/chromedriver.zip $TMP_DIR

}

# Detect the operating system
OS=$(uname -s)
ARCH=$(uname -m)

case "$OS" in
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            CHROME_URL="https://storage.googleapis.com/chrome-for-testing-public/135.0.7049.42/linux64/chromedriver-linux64.zip"
        else
            echo "Unsupported architecture: $ARCH"
            exit 1
        fi
        ;;
    Darwin)
        if [ "$ARCH" = "arm64" ]; then
            CHROME_URL="https://storage.googleapis.com/chrome-for-testing-public/135.0.7049.42/mac-arm64/chromedriver-mac-arm64.zip"
        elif [ "$ARCH" = "x86_64" ]; then
            CHROME_URL="https://storage.googleapis.com/chrome-for-testing-public/135.0.7049.42/mac-x64/chromedriver-mac-x64.zip"
        else
            echo "Unsupported architecture: $ARCH"
            exit 1
        fi
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Install ChromeDriver
install_chromedriver $CHROME_URL

echo "ChromeDriver ${STABLE_VERSION} installed successfully."
chromedriver --version

