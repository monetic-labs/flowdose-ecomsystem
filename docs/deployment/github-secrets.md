# GitHub Secrets for Deployment

To enable the automated deployment workflows, you need to set up the following secrets in your GitHub repository:

## Required Secrets

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `DO_SSH_PRIVATE_KEY` | SSH private key to access DigitalOcean droplets | `cat ~/.ssh/digitalocean_key` |
| `DIGITALOCEAN_ACCESS_TOKEN` | API token for DigitalOcean | DigitalOcean Dashboard > API > Generate New Token |
| `DO_APP_ID` | DigitalOcean App Platform ID | From App URL or `doctl apps list` |

## How to Add Secrets

1. Go to your GitHub repository
2. Click on "Settings" > "Secrets and variables" > "Actions"
3. Click on "New repository secret"
4. Enter the name and value of the secret
5. Click "Add secret"

## Getting the Values

### DigitalOcean SSH Private Key

```bash
cat ~/.ssh/digitalocean_key
```

Copy the entire output, including the `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----` lines.

### DigitalOcean API Token

1. Go to [DigitalOcean Dashboard](https://cloud.digitalocean.com/account/api/tokens)
2. Click "Generate New Token"
3. Give it a name like "GitHub Actions"
4. Ensure "Write" scope is selected
5. Click "Generate Token"
6. Copy the token (you won't be able to see it again)

### DigitalOcean App ID

If you're using the App Platform:

1. Navigate to your app in the DigitalOcean dashboard
2. The ID is in the URL: `https://cloud.digitalocean.com/apps/[THIS-IS-YOUR-APP-ID]`

Or use the DigitalOcean CLI:

```bash
doctl apps list
```

## Troubleshooting

- If you see "Input required and not supplied: token" error, the `DIGITALOCEAN_ACCESS_TOKEN` secret is missing or incorrect.
- If SSH connections fail, check that the `DO_SSH_PRIVATE_KEY` is correctly formatted and includes the beginning and ending lines.
- If App Platform updates fail, verify that the `DO_APP_ID` is correct. 