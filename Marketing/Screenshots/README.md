# Localized screenshot system

The generated lifestyle photographs contain no marketing text. Headlines, supporting copy, dates, currency and proof points live in the locale manifest and are composited at render time.

Run:

```powershell
py -3 Marketing/Screenshots/render_screenshots.py
```

The default output is ten 1260 × 2736 JPEGs for the current 6.9-inch iPhone screenshot well. Apple accepts several other 6.9-inch resolutions and automatically scales this set to smaller iPhone display wells. Produce a separate 2064 × 2752 iPad layout rather than stretching these compositions.

To add a locale, copy `manifest.en-GB.json`, translate natural phrases with native review, adapt dates/currency/proof examples, then pass that manifest to the renderer. The renderer wraps text but every output still requires visual QA for truncation, bidi layout, cultural fit and thumbnail legibility.

Generated photography was produced with the built-in image-generation tool using these reusable scene prompts:

- Household bill: calm editorial home scene, diverse woman reviewing a bill, upper-left negative space, no text/logos/device.
- Freelancer renewal: Black freelancer reviewing insurance and invoices, upper-right negative space, no text/logos/device.
- Family return: East Asian parent preparing a product return, upper-left negative space, no text/logos/device.

Do not upload screenshots until the depicted feature exists in the reviewed build. Replace the code-rendered device proof panel with simulator captures during final production.
