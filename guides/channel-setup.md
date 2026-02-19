# Channel Setup Guide
I use this guide when I need to wire messaging channels into the gateway quickly and safely.
I keep it practical: credentials, config location, and working test commands.
## First Checks
Before touching channel config, I verify:
- Gateway service is up
- Outbound network access exists
- I know who owns each platform account
Quick commands:
```bash
openclaw gateway status
openclaw gateway restart
```
## Where Configuration Goes
Most installs keep channel configuration in gateway config files.
Common locations:
- `config/gateway.json`
- `~/.openclaw/config/gateway.json`
- Environment specific files under `config/environments/`
I store secrets in env vars, not committed JSON.
## Generic Config Pattern
```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "defaultChatId": "${TELEGRAM_CHAT_ID}"
    },
    "discord": {
      "enabled": false
    }
  }
}
```
## WhatsApp
I usually choose between two approaches.
### Business API Path
Credentials I need:
- Meta app credentials
- WhatsApp Business Account details
- Phone Number ID
- Access token
- Webhook verify token
Gateway config area:
- `channels.whatsapp`
Example:
```json
{
  "channels": {
    "whatsapp": {
      "enabled": true,
      "provider": "meta-business-api",
      "phoneNumberId": "${WA_PHONE_NUMBER_ID}",
      "accessToken": "${WA_ACCESS_TOKEN}",
      "webhookVerifyToken": "${WA_WEBHOOK_VERIFY_TOKEN}"
    }
  }
}
```
Practical tips:
- Test webhook challenge response first
- Pre approve message templates for production sends
- Track token rotation and expiry in ops notes
### Unofficial Bridge Path
Credentials I need:
- Usually none at first
- Session state generated through QR pairing
Gateway config area:
- `channels.whatsapp` with bridge provider
Example:
```json
{
  "channels": {
    "whatsapp": {
      "enabled": true,
      "provider": "bridge",
      "sessionPath": "./data/whatsapp-session"
    }
  }
}
```
Practical tips:
- Persist session data on durable storage
- Expect occasional re pairing
- Monitor bridge health closely
## Telegram
Telegram is fast to set up and reliable for bot notifications.
Credentials I need:
- Bot token from BotFather
- Chat ID for each destination
How I collect them:
1. Create bot in BotFather with `/newbot`
2. Save token securely
3. Send a message to bot or group
4. Retrieve chat ID
Gateway config area:
- `channels.telegram`
Example:
```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "defaultChatId": "${TELEGRAM_CHAT_ID}",
      "parseMode": "Markdown"
    }
  }
}
```
Practical tips:
- Confirm bot is added to target groups
- Validate both direct and group sends
- Keep a one line API test handy
Validation command:
```bash
curl "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe"
```
## Discord
Discord setup usually fails on permissions, not tokens.
Credentials I need:
- Bot application
- Bot token
- Server ID
- Channel ID
- Required intents and permissions
Gateway config area:
- `channels.discord`
Example:
```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "botToken": "${DISCORD_BOT_TOKEN}",
      "guildId": "${DISCORD_GUILD_ID}",
      "defaultChannelId": "${DISCORD_CHANNEL_ID}"
    }
  }
}
```
Practical tips:
- Enable only intents you need
- Verify bot role can send messages in target channel
- Use IDs, names can be ambiguous
## Slack
Slack needs OAuth config plus signing verification for inbound events.
Credentials I need:
- Slack app, often from manifest
- Bot token `xoxb-...`
- Signing secret
- Channel IDs for routing
Gateway config area:
- `channels.slack`
Example:
```json
{
  "channels": {
    "slack": {
      "enabled": true,
      "botToken": "${SLACK_BOT_TOKEN}",
      "signingSecret": "${SLACK_SIGNING_SECRET}",
      "defaultChannel": "${SLACK_CHANNEL_ID}"
    }
  }
}
```
Practical tips:
- Start with least privilege scopes
- Reinstall app after scope updates
- Verify signature logic before enabling events
## Secrets and Rotation
I never commit live secrets.
I use:
- Environment variables
- Secret manager injection
- Local untracked `.env` for development only
Template:
```bash
TELEGRAM_BOT_TOKEN=...
TELEGRAM_CHAT_ID=...
DISCORD_BOT_TOKEN=...
DISCORD_GUILD_ID=...
DISCORD_CHANNEL_ID=...
SLACK_BOT_TOKEN=...
SLACK_SIGNING_SECRET=...
SLACK_CHANNEL_ID=...
WA_PHONE_NUMBER_ID=...
WA_ACCESS_TOKEN=...
WA_WEBHOOK_VERIFY_TOKEN=...
```
## Quick Validation Matrix
After setup I test:
- Outbound send success
- Inbound event reception, if used
- Routing to at least two targets
- Error logging quality
## Useful Test Commands
Telegram send:
```bash
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="channel test"
```
Slack send:
```bash
curl -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"channel":"'"${SLACK_CHANNEL_ID}"'","text":"channel test"}'
```
Discord send:
```bash
curl -X POST "https://discord.com/api/v10/channels/${DISCORD_CHANNEL_ID}/messages" \
  -H "Authorization: Bot ${DISCORD_BOT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"content":"channel test"}'
```
## Troubleshooting Shortlist
WhatsApp:
- Wrong webhook verification token
- Invalid phone number ID or token scope
Telegram:
- Wrong bot token
- Wrong chat ID
- Bot missing from group
Discord:
- Missing permissions
- Wrong channel ID
- Intents not enabled
Slack:
- Missing scopes
- Signature validation failure
- App not reinstalled after changes
## Final Advice
I keep setup simple, test early, and document every credential source.
That gives me reliable channels with fewer surprises during production use.
