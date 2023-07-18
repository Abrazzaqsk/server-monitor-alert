#!/bin/bash

# Update the package lists
#sudo apt update

# Install required dependencies
#sudo apt install -y wget

# Download the latest version of Alertmanager
wget https://github.com/prometheus/alertmanager/releases/latest/download/alertmanager-*.linux-amd64.tar.gz

# Extract the downloaded package
tar -xzf alertmanager-*.linux-amd64.tar.gz

# Rename the extracted folder
mv alertmanager-*.linux-amd64 alertmanager

# Move Alertmanager files to /usr/local/bin directory
sudo mv alertmanager/alertmanager /usr/local/bin/
sudo mv alertmanager/amtool /usr/local/bin/

# Create a dedicated system user for Alertmanager
sudo useradd --no-create-home --shell /bin/false alertmanager

# Create the required directories for Alertmanager
sudo mkdir /etc/alertmanager
sudo mkdir /var/lib/alertmanager

# Set ownership and permissions for directories
sudo chown alertmanager: /etc/alertmanager
sudo chown alertmanager: /var/lib/alertmanager

# Copy the example configuration file
sudo cp alertmanager/alertmanager.yml /etc/alertmanager/

# Set ownership and permissions for the configuration file
sudo chown alertmanager: /etc/alertmanager/alertmanager.yml

# Create a systemd service file for Alertmanager
cat << EOF | sudo tee /etc/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
ExecStart=/usr/local/bin/alertmanager \
  --config.file /etc/alertmanager/alertmanager.yml \
  --storage.path /var/lib/alertmanager

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Alertmanager
sudo systemctl daemon-reload
sudo systemctl start alertmanager

# Enable Alertmanager to start on boot
sudo systemctl enable alertmanager

# Cleanup downloaded files
rm alertmanager-*.linux-amd64.tar.gz
rm -rf alertmanager

echo "Alertmanager has been installed and started successfully."
