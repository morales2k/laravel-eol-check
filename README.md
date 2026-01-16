# Laravel EOL Status Checker

A bash script to check the Laravel version in your project and display End-of-Life (EOL) support information.

## Features

- 🔍 Automatically detects Laravel version from `composer.lock`
- 📅 Fetches real-time EOL data from endoflife.date API
- 🎨 Color-coded output for easy reading
- ⚠️ Warnings for versions approaching EOL
- 📊 Shows active support and security fix timelines
- 🚀 Provides upgrade recommendations and links

## Requirements

- `bash` (version 4.0+)
- `jq` - JSON parser
- `curl` - HTTP client
- `composer.lock` file in your Laravel project

### Installing Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install jq curl
```

**macOS:**
```bash
brew install jq curl
```

**RHEL/CentOS/Fedora:**
```bash
sudo yum install jq curl
```

## Installation

1. Download the script:
```bash
curl -o check-laravel-eol.sh https://raw.githubusercontent.com/your-repo/check-laravel-eol.sh
```

2. Make it executable:
```bash
chmod +x check-laravel-eol.sh
```

3. Optionally, move to a directory in your PATH:
```bash
sudo mv check-laravel-eol.sh /usr/local/bin/check-laravel-eol
```

## Usage

Navigate to your Laravel project root directory and run:

```bash
./check-laravel-eol.sh
```

Or if installed globally:

```bash
check-laravel-eol
```

## Output Information

The script displays:

1. **Repository Information**
   - Current project path

2. **Laravel Version**
   - Installed version (from composer.lock)
   - Major version number

3. **Support Information**
   - Latest patch release for your major version
   - Release type (LTS or Standard)

4. **Important Dates**
   - Release date
   - Active support end date (bug fixes)
   - Security support end date (security fixes only)
   - Days remaining until each milestone

5. **Recommendations**
   - Status indicators (color-coded)
   - Upgrade suggestions
   - Links to upgrade guides

## Exit Codes

The script returns different exit codes for automation:

- `0` - Success, version is supported
- `1` - Warning, approaching EOL (< 90 days)
- `2` - Critical, version is EOL (no support)

### Using in CI/CD

```bash
#!/bin/bash
./check-laravel-eol.sh

case $? in
    0)
        echo "✓ Laravel version is supported"
        ;;
    1)
        echo "⚠ Warning: Laravel version approaching EOL"
        # Optional: continue but notify team
        ;;
    2)
        echo "✗ Error: Laravel version is EOL - failing build"
        exit 1
        ;;
esac
```

## Example Output

### Supported Version
```
==================================
  Laravel EOL Status Checker
==================================

Analyzing Laravel installation...

Fetching EOL data from endoflife.date...

Repository Information:
  Project Path: /var/www/my-laravel-app

Laravel Version:
  Installed Version: v11.31.0
  Major Version: 11

Support Information:
  Latest 11.x Release: 11.47.0
  Release Type: Standard Release

Important Dates:
  Released: March 12, 2024
  Active Support Until: September 03, 2025 (ENDED)
  Security Fixes Until: March 12, 2026 (57 days remaining)

Recommendations:
  ⚠ Active support has ended (security fixes only)
  Action: Consider upgrading to Laravel 12

  Upgrade Guide: https://laravel.com/docs/12.x/upgrade
  Release Notes: https://laravel.com/docs/12.x/releases
```

### EOL Version
```
==================================
  Laravel EOL Status Checker
==================================

Analyzing Laravel installation...

Fetching EOL data from endoflife.date...

Repository Information:
  Project Path: /var/www/legacy-app

Laravel Version:
  Installed Version: v9.52.0
  Major Version: 9

Support Information:
  Latest 9.x Release: 9.52.21
  Release Type: Standard Release

Important Dates:
  Released: February 08, 2022
  Active Support Until: August 08, 2023 (ENDED)
  Security Fixes Until: February 06, 2024 (END OF LIFE)

Recommendations:
  ⚠ CRITICAL: This version is no longer supported!
  ⚠ No security updates are being released.
  Action: Upgrade to Laravel 12 immediately

  Upgrade Guide: https://laravel.com/docs/12.x/upgrade
  Release Notes: https://laravel.com/docs/12.x/releases
```

## Laravel Support Policy

According to Laravel's official policy:

- **Bug Fixes**: 18 months
- **Security Fixes**: 2 years (24 months)
- **Major Releases**: Annually (around Q1)

### Historical LTS Releases

Laravel previously had LTS (Long Term Support) releases with extended support:
- **Laravel 6 (LTS)**: Bug fixes for 2 years, security fixes for 3 years
- **Laravel 5.5 (LTS)**: Bug fixes for 2 years, security fixes for 3 years

Starting from Laravel 8, all releases follow the standard support timeline.

## Automation Examples

### GitHub Actions Workflow

```yaml
name: Check Laravel EOL

on:
  schedule:
    - cron: '0 0 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  check-eol:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install dependencies
        run: sudo apt-get update && sudo apt-get install -y jq curl
      
      - name: Check Laravel EOL
        id: eol-check
        run: |
          chmod +x ./check-laravel-eol.sh
          ./check-laravel-eol.sh
        continue-on-error: true
      
      - name: Create Issue if EOL
        if: steps.eol-check.outputs.exitcode == 2
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '⚠️ Laravel version is EOL',
              body: 'The Laravel version in this repository has reached end-of-life. Please upgrade.',
              labels: ['security', 'dependencies']
            })
```

### Bash Loop for Multiple Repositories

```bash
#!/bin/bash
# Check all Laravel projects in a directory

PROJECTS_DIR="/var/www"

for project in "$PROJECTS_DIR"/*; do
    if [ -d "$project" ] && [ -f "$project/composer.lock" ]; then
        echo "Checking $project..."
        cd "$project" || continue
        ./check-laravel-eol.sh
        echo ""
        echo "-----------------------------------"
        echo ""
    fi
done
```

## API Source

This script uses the free API from [endoflife.date](https://endoflife.date/), an excellent community-maintained database of EOL dates for various products.

API Endpoint: `https://endoflife.date/api/laravel.json`

## Troubleshooting

### "composer.lock not found"
Make sure you're running the script from the root directory of your Laravel project.

### "Laravel framework not found in composer.lock"
Verify that `laravel/framework` is installed in your project.

### "Failed to fetch EOL data"
Check your internet connection and ensure endoflife.date is accessible.

### Date parsing errors
The script attempts to use both GNU date and BSD date formats. If you encounter issues, ensure the `date` command is available.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - feel free to use and modify as needed.

## Related Resources

- [Laravel Official Documentation](https://laravel.com/docs)
- [Laravel Support Policy](https://laravel.com/docs/master/releases#support-policy)
- [endoflife.date](https://endoflife.date/laravel)
- [Laravel News](https://laravel-news.com/)

## Changelog

### v1.0.0 (2025-01-16)
- Initial release
- Basic EOL checking functionality
- Color-coded output
- Support for all Laravel versions
- Exit codes for automation
