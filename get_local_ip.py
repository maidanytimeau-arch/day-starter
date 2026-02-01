#!/usr/bin/env python3
"""
Get Local IP Address Helper
Finds your Mac's IP on the local network
"""

import subprocess
import sys

def get_local_ip():
    """Get local IP from network interfaces"""
    try:
        # Try netstat
        result = subprocess.run(
            ["netstat", "-rn"],
            capture_output=True,
            text=True,
            timeout=5
        )

        if result.returncode == 0:
            for line in result.stdout.split('\n'):
                if 'default' in line and 'en0' in line:
                    parts = line.split()
                    for i, part in enumerate(parts):
                        # Look for IPv4 address pattern
                        if part and '.' in part:
                            print(f"Local IP: {part}")
                            return True
    except Exception as e:
        pass

    return False

def show_system_settings_instructions():
    """Show how to find IP in System Settings"""
    print("📱 Find your Mac's local IP:")
    print("")
    print("Method 1: System Settings")
    print("  1. Open: System Settings → Network")
    print("  2. Look for: 'Wi-Fi address' or 'Your local IP'")
    print("  3. It will look like: 192.168.x.x")
    print("")
    print("Method 2: Terminal (if netstat available)")
    print("  Run: netstat -rn | grep default")
    print("  Look for IP in the line starting with 'default'")
    print("")

def main():
    print("🔍 Looking for local IP address...")
    print("")

    found = get_local_ip()

    if not found:
        print("❌ Could not determine local IP automatically")
        print("")
        show_system_settings_instructions()
    else:
        print("✅ Local IP found above")
        print("")
        print("Use this IP on your phone (same WiFi):")
        print("http://[LOCAL-IP]:5000")

if __name__ == "__main__":
    main()
