# Make Bold theme (vendored)

`web/theme/make-bold/` is a byte-for-byte copy of the Make Bold Solutions design system
(token CSS, global stylesheet, readme, fonts and peak mark), taken from the ArrowSpark
showcase mockup package on 2026-10-02. It is the implementation authority for the showcase's
visual language. Nothing in the site imports anything outside this folder for theming.

## Rules

- **Never edit files in `web/theme/make-bold/`.** A theme update replaces the folder as a
  whole and refreshes the hash list below.
- **Extensions live only in `web/src/styles/arrowspark.css`** (game frame, evidence beat rail,
  Journey list), and use theme tokens, never raw color or pixel literals.
  `node web/scripts/check-content.mjs` enforces that no raw hex color or `px` literal appears
  in site source outside that file.
- Components (`web/src/components/ui/*`) re-express the theme's prop sets in scoped CSS
  built on tokens only.
- Fonts are served as WOFF2 from `web/public/fonts/` (converted once from the TTFs here; see
  `web/scripts/convert-fonts.md`). The TTFs stay here as the source.
- Error red (`--critical`) is used only for invalid, blocked or error states.

## Fonts and licences

Be Vietnam Pro and Inter Tight are licensed under the SIL Open Font License 1.1. The licence
texts ship with the site at `web/public/fonts/licenses/OFL-BeVietnamPro.txt` and
`web/public/fonts/licenses/OFL-InterTight.txt`, and are linked from the site's licences page.

## File hashes (SHA-256)

```text
7e7cb663fd30c299e8582cd2789b14a48ffb124a351f0069e29cf53167e847a5  assets/fonts/BeVietnamPro-Black.ttf
2fe6c3f9dbb65f61554d530c16b2eb4ec32ca437dc8f9999a6ec0f6403b30bfe  assets/fonts/BeVietnamPro-Bold.ttf
10fcb42b9cee8e30918843416676ae059e8f77fe439d0c3a4350617ef9f77a75  assets/fonts/BeVietnamPro-ExtraBold.ttf
f493144cb53c78c6f0819bc9b73de274486618ac609bc92b3b79d4efc76f95c6  assets/fonts/BeVietnamPro-Medium.ttf
cb6f53d6fd56316356c55b067474d9621c27b7182b124063b8f6eab6acef63bd  assets/fonts/BeVietnamPro-Regular.ttf
04db63d2a82dd4bb35ba25e00dab1d12febcd0e917856b174b71a24d6f0c9afa  assets/fonts/BeVietnamPro-SemiBold.ttf
6bfc259bb39a54944919f99c62339b30c4029082576af867ae331954f217ac2e  assets/fonts/InterTight-Italic-VariableFont_wght.ttf
4b8ef9ed255ebe7341aa566554c0f3e87ee10ce06d2085f07ccf66f41ef96c28  assets/fonts/InterTight-VariableFont_wght.ttf
4ed415610a2353fde16aec336e730b71e8fba0103eb30a8b24f97f59f58f0177  logo-mark.svg
e4f262d5041532fbb4efab94c457db4c956c74b6e6d14a1f410920990bbe4d0a  readme.md
b53eea45e3d316e21bc5cf1f261ccaa4b36863c3ecf64e2b19618e00a821f19e  styles.css
24df61cfeb85c64f497cea129a545c3536b9d6644d18310abc62b10b5b63ddcb  tokens/base.css
f943192319756ad454558cf7c22b3195c4e002ebe2f199bb3224239e95c1f360  tokens/colors.css
41d612871e329a87bcddf4499bb9a07f7e4e65dc729bcf629f99ac20ca7c9af0  tokens/effects.css
3c8372b5267c8fcdd373dd59e2cfefea8ddbd0070b3e21dcc1caefd0d0560a3c  tokens/fonts.css
ff241a253e7cede7268d075632baa989fd0c6934482e393b86861d5a20c56ae5  tokens/spacing.css
c52b43d540c7bb86523e18ada2d1b66b388c1f2c65e0c2bdbe20d576c84cd6f6  tokens/typography.css
```

Verify with `cd web/theme/make-bold && sha256sum -c` against the list above.
