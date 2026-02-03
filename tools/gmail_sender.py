#!/usr/bin/env python3
"""
Gmail OAuth Email Sender for OpenClaw

Setup (one-time):
1. Go to https://console.cloud.google.com/
2. Create a project or select existing
3. Enable Gmail API
4. Create OAuth 2.0 credentials (Desktop app)
5. Download client_secrets.json and save as ~/.openclaw/credentials/gmail_client.json
6. Run this script once to authenticate

Usage:
    python3 gmail_sender.py --to recipient@example.com --subject "Hello" --body "Message here"
    python3 gmail_sender.py --to recipient@example.com --subject "Hello" --body "Message" --attachment file.pdf
"""

import os
import sys
import base64
import argparse
from pathlib import Path
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

# Google libraries
try:
    from google.auth.transport.requests import Request
    from google.oauth2.credentials import Credentials
    from google_auth_oauthlib.flow import InstalledAppFlow
    from googleapiclient.discovery import build
    from googleapiclient.errors import HttpError
except ImportError:
    print("Installing required packages...")
    os.system("pip3 install --user google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client")
    print("Please run the script again.")
    sys.exit(1)

# Gmail API scopes
SCOPES = ['https://www.googleapis.com/auth/gmail.send']

# Credential paths
CREDENTIALS_DIR = Path.home() / '.openclaw' / 'credentials'
CLIENT_SECRETS_FILE = CREDENTIALS_DIR / 'gmail_client.json'
TOKEN_FILE = CREDENTIALS_DIR / 'gmail_token.json'


def get_credentials():
    """Get or refresh Gmail API credentials."""
    CREDENTIALS_DIR.mkdir(parents=True, exist_ok=True)
    
    creds = None
    
    # Load existing token
    if TOKEN_FILE.exists():
        creds = Credentials.from_authorized_user_file(str(TOKEN_FILE), SCOPES)
    
    # Refresh or create new credentials
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not CLIENT_SECRETS_FILE.exists():
                print(f"Error: Client secrets file not found at {CLIENT_SECRETS_FILE}")
                print("\nTo set up Gmail OAuth:")
                print("1. Go to https://console.cloud.google.com/")
                print("2. Create a project and enable Gmail API")
                print("3. Create OAuth 2.0 credentials (Desktop application)")
                print(f"4. Download and save as: {CLIENT_SECRETS_FILE}")
                sys.exit(1)
            
            flow = InstalledAppFlow.from_client_secrets_file(
                str(CLIENT_SECRETS_FILE), SCOPES)
            creds = flow.run_local_server(port=0)
        
        # Save token for future runs
        with open(TOKEN_FILE, 'w') as token:
            token.write(creds.to_json())
        print(f"Credentials saved to {TOKEN_FILE}")
    
    return creds


def create_message(sender, to, subject, body, attachments=None):
    """Create email message."""
    if attachments:
        message = MIMEMultipart()
        message['to'] = to
        message['from'] = sender
        message['subject'] = subject
        
        msg = MIMEText(body)
        message.attach(msg)
        
        for filepath in attachments:
            if not os.path.exists(filepath):
                print(f"Warning: Attachment not found: {filepath}")
                continue
                
            with open(filepath, 'rb') as f:
                part = MIMEBase('application', 'octet-stream')
                part.set_payload(f.read())
            
            encoders.encode_base64(part)
            filename = os.path.basename(filepath)
            part.add_header(
                'Content-Disposition',
                f'attachment; filename= {filename}'
            )
            message.attach(part)
    else:
        message = MIMEText(body)
        message['to'] = to
        message['from'] = sender
        message['subject'] = subject
    
    return {'raw': base64.urlsafe_b64encode(message.as_bytes()).decode()}


def send_email(service, user_id, message):
    """Send email via Gmail API."""
    try:
        result = service.users().messages().send(userId=user_id, body=message).execute()
        print(f"Email sent successfully! Message ID: {result['id']}")
        return result
    except HttpError as error:
        print(f"An error occurred: {error}")
        raise


def main():
    parser = argparse.ArgumentParser(description='Send email via Gmail OAuth')
    parser.add_argument('--to', required=True, help='Recipient email address')
    parser.add_argument('--subject', required=True, help='Email subject')
    parser.add_argument('--body', required=True, help='Email body (can be HTML)')
    parser.add_argument('--from', dest='sender', help='Sender email (defaults to authenticated user)')
    parser.add_argument('--attachment', nargs='+', help='File(s) to attach')
    parser.add_argument('--setup', action='store_true', help='Run OAuth setup only')
    
    args = parser.parse_args()
    
    # Get credentials
    creds = get_credentials()
    
    if args.setup:
        print("OAuth setup complete!")
        return
    
    # Build Gmail service
    service = build('gmail', 'v1', credentials=creds)
    
    # Get sender email if not provided
    if args.sender:
        sender = args.sender
    else:
        # Try to get from credentials profile
        profile = service.users().getProfile(userId='me').execute()
        sender = profile['emailAddress']
    
    # Create and send message
    message = create_message(sender, args.to, args.subject, args.body, args.attachment)
    send_email(service, 'me', message)


if __name__ == '__main__':
    main()
