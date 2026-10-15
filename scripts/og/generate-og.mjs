// Genera las imágenes Open Graph del site (1200x630, una por idioma) desde og-template.html con Chrome headless:
//   projects/site/src/assets/og-image-{es,en,it}.jpg (las usa SeoService en og:image y twitter:image).
// Uso: node scripts/og/generate-og.mjs   (requiere Chrome o Edge instalado y conexión para las fuentes de Google)
import { execFileSync } from 'node:child_process';
import { existsSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const assets = join(here, '..', '..', 'src', 'web', 'projects', 'site', 'src', 'assets');
const browser = [
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
  '/usr/bin/google-chrome', '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
].find(existsSync);
if (!browser) { console.error('No se encontró Chrome ni Edge.'); process.exit(1); }

const tmp = mkdtempSync(join(tmpdir(), 'og-'));
for (const lang of ['es', 'en', 'it']) {
  const png = join(tmp, `${lang}.png`);
  const jpg = join(assets, `og-image-${lang}.jpg`);
  execFileSync(browser, ['--headless=new', '--hide-scrollbars', '--force-device-scale-factor=1', '--window-size=1200,630',
    '--virtual-time-budget=5000', `--user-data-dir=${join(tmp, 'profile')}`, `--screenshot=${png}`,
    `${pathToFileURL(join(here, 'og-template.html'))}?lang=${lang}`], { stdio: 'ignore' });
  // PNG -> JPG (calidad 88) con System.Drawing: sin dependencias de npm.
  execFileSync('powershell', ['-NoProfile', '-Command', `Add-Type -AssemblyName System.Drawing;
    $img = [System.Drawing.Image]::FromFile('${png}');
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg';
    $p = New-Object System.Drawing.Imaging.EncoderParameters 1;
    $p.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 88L;
    $img.Save('${jpg}', $codec, $p); $img.Dispose()`]);
  console.log(`og-image-${lang}.jpg`);
}
rmSync(tmp, { recursive: true, force: true });
