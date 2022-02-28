const esbuild = require('esbuild')
const manifestPlugin = require('esbuild-plugin-manifest')

const args = process.argv.slice(2)

const watch = args.includes('--watch')
const precompile = args.includes('--precompile')

const entryPoints = process.env.ESBUILD_ENTRY_POINTS.split(' ');
const outDir = process.env.ESBUILD_OUTDIR;

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
}

const plugins = [
  // Add and configure plugins here
  manifestPlugin()
]

const generalOptions = {
  bundle: true,
  entryPoints: entryPoints,
  outdir: outDir,
  loader,
  plugins
}

if (watch) {
  const watchOptions = {
    logLevel: process.env.ESBUILD_LOG_LEVEL || 'silent',
    minify: false,
    sourcemap: false,
    watch: true,
  }

  const opts = {...generalOptions, ...watchOptions};

  esbuild.build(opts);
}

if (precompile) {
  const precompileOpts = {
    logLevel: process.env.ESBUILD_LOG_LEVEL || 'info',
    minify: process.env.ESBUILD_MINIFY || true,
    sourcemap: process.env.ESBUILD_SOURCEMAP || true,
    entryNames: '[dir]/[name]-[hash]',
  }

  const opts = {...generalOptions, ...precompileOpts};

  esbuild.build(opts);
}