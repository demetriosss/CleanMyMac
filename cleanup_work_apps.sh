#!/bin/bash

# Function to remove applications
remove_app() {
    APP_NAME=$1
    echo "Removing $APP_NAME..."
    sudo rm -rf /Applications/"$APP_NAME".app
    echo "$APP_NAME removed from Applications."
}

# Function to remove associated files
remove_associated_files() {
    APP_KEY=$1
    echo "Searching and removing files related to $APP_KEY..."
    sudo find / -name "*$APP_KEY*" -exec rm -rf {} + 2>/dev/null
    echo "Files related to $APP_KEY removed."
}

# Function to unload and remove launch daemons or services
# Use the hash to remove any functions you desire. 
remove_services() {
    SERVICE_KEY=$1
    echo "Stopping and removing services related to $SERVICE_KEY..."
    sudo launchctl list | grep -i "$SERVICE_KEY" | awk '{print $3}' | while read -r service; do
        sudo launchctl unload -w "$service" 2>/dev/null
    done
    sudo rm -rf /Library/LaunchDaemons/*"$SERVICE_KEY"* /Library/LaunchAgents/*"$SERVICE_KEY"*
    echo "Services related to $SERVICE_KEY removed."
}

# Function to remove Microsoft 365 apps
remove_microsoft_apps() {
    echo "Removing Microsoft 365 apps..."
    sudo rm -rf /Applications/Microsoft*
    sudo find /Library -name "*Microsoft*" -exec rm -rf {} +
    sudo find ~/Library -name "*Microsoft*" -exec rm -rf {} +
    echo "Microsoft 365 apps and related files removed."
}

# Remove specific applications
remove_app "Sophos"
remove_app "ScreenConnect"
remove_app "NinjaRMM"
remove_app "Client"
remove_app "Host"

# Remove associated files for specific apps
remove_associated_files "Sophos"
remove_associated_files "ScreenConnect"
remove_associated_files "Ninja"
remove_associated_files "Microsoft"

# Unload and remove services
remove_services "sophos"
remove_services "screenconnect"
remove_services "ninja"
remove_services "microsoft"

# Reset firewall rules
echo "Resetting firewall rules..."
sudo defaults delete /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo "No firewall rules found."

# Remove VPN or proxy settings
echo "Removing all network services..."
sudo networksetup -listallnetworkservices | tail -n +2 | while read -r service; do
    sudo networksetup -removenetworkservice "$service" 2>/dev/null
done

echo "All specified applications and configurations have been removed. Please restart your MacBook Pro for the changes to take full effect."
