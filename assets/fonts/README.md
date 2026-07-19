# Arabic Fonts

This directory should contain the Arabic font files referenced in `pubspec.yaml`:

- `Cairo-Regular.ttf` (weight 400)
- `Cairo-Bold.ttf` (weight 700)
- `Cairo-SemiBold.ttf` (weight 600)
- `Cairo-Medium.ttf` (weight 500)
- `Cairo-Light.ttf` (weight 300)
- `Tajawal-Regular.ttf` (weight 400)
- `Tajawal-Bold.ttf` (weight 700)
- `Tajawal-Medium.ttf` (weight 500)
- `Amiri-Regular.ttf` (weight 400)
- `Amiri-Bold.ttf` (weight 700)

## Free Download Sources

These fonts are open-source (OFL license):

1. **Cairo** - https://github.com/googlefonts/cairo
2. **Tajawal** - https://github.com/googlefonts/tajawal
3. **Amiri** - https://github.com/aliftype/amiri

Download the TTF files and place them in this directory.

## Bundled Fallback

The app uses 'Cairo' as the primary font family. If the fonts are not bundled,
Flutter will fall back to the system font, which on most devices has decent
Arabic support. However, for the best visual experience, you should bundle
the actual font files.

## Setup

```bash
# After cloning the repo:
cd assets/fonts
# Download fonts from the URLs above
# Or use a package manager:

# Using curl
curl -L -o Cairo-Regular.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Regular.ttf
curl -L -o Cairo-Bold.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Bold.ttf
curl -L -o Cairo-SemiBold.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-SemiBold.ttf
curl -L -o Cairo-Medium.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Medium.ttf
curl -L -o Cairo-Light.ttf https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Light.ttf
```

## Note

The .gitignore is set to ignore the .ttf files (to avoid repo bloat), so
they need to be added manually after cloning. Alternatively, uncomment them
from .gitignore and commit them.
