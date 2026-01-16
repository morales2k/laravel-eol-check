# Laravel EOL Checker - Quick Start Guide

## 📋 What You Get

This package includes:
- `check-laravel-eol.sh` - Main script to check Laravel EOL status
- `README.md` - Comprehensive documentation
- Example demo scripts showing different scenarios

## 🚀 Quick Start (3 Steps)

### 1. Install Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get install jq curl
```

**macOS:**
```bash
brew install jq curl
```

### 2. Make Script Executable

```bash
chmod +x check-laravel-eol.sh
```

### 3. Run in Your Laravel Project

```bash
cd /path/to/your/laravel/project
./check-laravel-eol.sh
```

## 📊 Example Outputs

### ✅ Current/Supported Version (Laravel 12)
```
==================================
  Laravel EOL Status Checker
==================================

Repository Information:
  Project Path: /var/www/my-app

Laravel Version:
  Installed Version: v12.44.0
  Major Version: 12

Support Information:
  Latest 12.x Release: 12.44.0
  Release Type: Standard Release

Important Dates:
  Released: February 24, 2025
  Active Support Until: August 16, 2026 (211 days remaining)
  Security Fixes Until: February 24, 2027 (403 days remaining)

Recommendations:
  ✓ Your Laravel version is fully supported
  ✓ You are on the latest major version

  Upgrade Guide: https://laravel.com/docs/12.x/upgrade
  Release Notes: https://laravel.com/docs/12.x/releases
```

### ⚠️ Security-Only Support (Laravel 11)
```
==================================
  Laravel EOL Status Checker
==================================

Repository Information:
  Project Path: /var/www/legacy-app

Laravel Version:
  Installed Version: v11.31.0
  Major Version: 11

Support Information:
  Latest 11.x Release: 11.47.0
  Release Type: Standard Release

Important Dates:
  Released: March 12, 2024
  Active Support Until: September 03, 2025 (ENDED)
  Security Fixes Until: March 12, 2026 (54 days remaining)

Recommendations:
  ⚠ Active support has ended (security fixes only)
  Action: Consider upgrading to Laravel 12

  Upgrade Guide: https://laravel.com/docs/12.x/upgrade
  Release Notes: https://laravel.com/docs/12.x/releases
```

### 🚨 End of Life (Laravel 9)
```
==================================
  Laravel EOL Status Checker
==================================

Repository Information:
  Project Path: /var/www/old-app

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

## 🔄 Common Use Cases

### Check All Projects in a Directory

```bash
#!/bin/bash
for dir in /var/www/*/; do
    if [ -f "$dir/composer.lock" ]; then
        echo "Checking: $dir"
        cd "$dir"
        /path/to/check-laravel-eol.sh
        echo "---"
    fi
done
```

### Run in CI/CD (Exit Codes)

```bash
./check-laravel-eol.sh
EXIT_CODE=$?

if [ $EXIT_CODE -eq 2 ]; then
    echo "FAIL: Laravel version is EOL"
    exit 1
elif [ $EXIT_CODE -eq 1 ]; then
    echo "WARN: Laravel version approaching EOL"
    # Optional: send notification
fi
```

### Schedule Regular Checks (Cron)

```bash
# Check every Monday at 9 AM
0 9 * * 1 cd /var/www/myapp && /usr/local/bin/check-laravel-eol.sh | mail -s "Laravel EOL Check" admin@example.com
```

## 📝 Exit Codes

- `0` - Success (version is supported)
- `1` - Warning (approaching EOL, < 90 days)
- `2` - Critical (version is EOL)

## 🛠️ Troubleshooting

**Issue:** "composer.lock not found"
**Solution:** Run from your Laravel project root directory

**Issue:** "Laravel framework not found"
**Solution:** Ensure `laravel/framework` is in composer.lock

**Issue:** "Failed to fetch EOL data"
**Solution:** Check internet connection and endoflife.date availability

## 🌐 Data Source

This script uses the free API from [endoflife.date](https://endoflife.date/laravel):
- API Endpoint: `https://endoflife.date/api/laravel.json`
- Updated regularly by the community
- Covers all Laravel versions since 5.5

## 📚 Laravel Support Timeline Reference

- **Bug Fixes:** 18 months from release
- **Security Fixes:** 24 months from release
- **Major Releases:** Annually (around Q1)

### Currently Supported Versions (as of January 2026)

| Version | Released | Active Support | Security Fixes | Status |
|---------|----------|----------------|----------------|---------|
| 12.x | Feb 2025 | Aug 2026 | Feb 2027 | ✅ Fully Supported |
| 11.x | Mar 2024 | Sep 2025 | Mar 2026 | ⚠️ Security Only |
| 10.x | Feb 2023 | Aug 2024 | Feb 2025 | 🚨 EOL |
| 9.x | Feb 2022 | Aug 2023 | Feb 2024 | 🚨 EOL |

## 🎯 Best Practices

1. **Run monthly** - Check your Laravel versions regularly
2. **Plan upgrades early** - Start planning 6 months before active support ends
3. **Test thoroughly** - Always test upgrades in staging first
4. **Use in CI/CD** - Automate checks in your deployment pipeline
5. **Monitor alerts** - Set up notifications for approaching EOL dates

## 📞 Support & Contributing

- Issues: Open on GitHub
- Contributions: Pull requests welcome
- Questions: Check the main README.md

## 📄 License

MIT License - Free to use and modify

---

**Quick Links:**
- [Full Documentation](README.md)
- [Laravel Documentation](https://laravel.com/docs)
- [Laravel Upgrade Guide](https://laravel.com/docs/master/upgrade)
- [endoflife.date API](https://endoflife.date/docs/api)
