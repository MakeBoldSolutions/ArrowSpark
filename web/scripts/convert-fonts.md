# Converting the theme fonts to WOFF2

The site serves the Make Bold fonts as WOFF2 from `web/public/fonts/`. They are converted once
from the TTF sources kept unchanged in `web/theme/make-bold/assets/fonts/`, and the output is
committed. Re-run this only when the theme's fonts change.

Requires Python 3 with `fonttools` and `brotli` (`pip install fonttools brotli`). From `web/`:

```sh
for f in theme/make-bold/assets/fonts/*.ttf; do
  python -m fontTools.ttLib.woff2 compress -o "public/fonts/$(basename "$f" .ttf).woff2" "$f"
done
```

The conversion is lossless (same glyphs, same variable axes); no subsetting is applied.
`src/styles/global.css` declares the `@font-face` rules for these files with the same families,
weights and styles as the theme's `tokens/fonts.css`.
