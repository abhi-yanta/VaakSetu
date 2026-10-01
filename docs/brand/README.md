# VaakSetu brand mark

**Locked concept:** Option 4 — Voice Bridge lockup. Teal V-stroke + gold S with cable-stay lines (bridge / “Setu”), plus bilingual wordmark **VaakSetu** / **वाक्सेतु**. Same mark family everywhere (app icon, in-app chrome, landing, README). Not the mascot.

Approved preview source: `previews/option-4-approved.png`.

| Asset | Path | Use |
|---|---|---|
| App icon | `app_icon.png` / `mobile/assets/brand/app_icon.png` | Launcher, splash, `AnimatedLogo` |
| Icon-only mark | `mark.png` | AppBar, footer, tight UI |
| Horizontal lockup | `lockup.png` | Landing hero, README header |

Colors: cream `#F7F3EB`, gold/saffron accent, deep teal `#00695C`, slate text `#1E293B`.

## Regenerate Android / iOS launcher icons

`flutter_launcher_icons` is configured in `mobile/pubspec.yaml` to use `assets/brand/app_icon.png`.

```powershell
cd mobile
flutter pub get
dart run flutter_launcher_icons
```

That writes `ic_launcher` mipmaps / adaptive icons from the brand app icon. Rebuild the APK after running it.

If you only need a quick UI preview, in-app assets already point at `assets/brand/` — launcher regeneration is optional until you ship a store build.
