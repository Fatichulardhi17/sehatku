const express = require('express');
const os = require('os');
const path = require('path');
const fs = require('fs');

const app = express();
const port = Number(process.env.PORT) || 8080;
const host = process.env.HOST || '0.0.0.0';
const webDir = path.join(__dirname, '..', 'build', 'web');

if (!fs.existsSync(path.join(webDir, 'index.html'))) {
  console.error('build/web belum ada. Jalankan: flutter build web --release');
  process.exit(1);
}

app.disable('x-powered-by');

app.use(
  express.static(webDir, {
    setHeaders(res, filePath) {
      if (filePath.endsWith('flutter_service_worker.js')) {
        res.setHeader('Cache-Control', 'no-cache');
      }
    },
  })
);

// Flutter web memakai hash routing, jadi fallback ini hanya jaring pengaman
// untuk path lain (mis. /health) tanpa merusak aset.
app.get('/health', (_req, res) => res.json({ ok: true }));

app.use((req, res, next) => {
  if (req.method !== 'GET' && req.method !== 'HEAD') return next();
  res.sendFile(path.join(webDir, 'index.html'));
});

app.listen(port, host, () => {
  console.log(`Sehatku berjalan di http://localhost:${port}`);
  for (const list of Object.values(os.networkInterfaces())) {
    for (const net of list ?? []) {
      if (net.family === 'IPv4' && !net.internal) {
        console.log(`Dari HP (jaringan sama): http://${net.address}:${port}`);
      }
    }
  }
});
