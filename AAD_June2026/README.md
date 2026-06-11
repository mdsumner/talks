# Modern data accessibility and virtualization

**Cloud native: Zarr, chunks and virtualization in Python, GDAL, and R**

A short (5-minute) presentation given at the Australian Antarctic Division, June 2026.

## Contents

- `zarr_virtualization_talk.pptx` — the finished slide deck
- `zarr_talk.js` — the source script that generates the deck using [pptxgenjs](https://gitbrent.github.io/PptxGenJS/)

## Slides

1. Title
2. June 2026 — the Zarr ecosystem is moving fast (earthmover.io context)
3. What is Zarr?
4. VZarr: virtualization at the chunk level
5. VRT: virtualization at the file level
6. Multi-language support
7. What this enables
8. Digital integration working group

## Regenerating the deck

```bash
npm install -g pptxgenjs
node zarr_talk.js
```

Requires the earthmover screenshot image at the path referenced in the script — swap in your own or comment out slide 2.

## Topics covered

- Zarr as chunked, compressed, cloud-native array storage
- Chunks as compressed opaque bytes — meaningless without metadata
- Byte references: `(path, byte-offset, byte-length)` as the key abstraction
- GDAL VRT as file-level virtualization and pivot point to chunk-level refs
- kerchunk / VirtualiZarr (Python) and the R+GDAL parallel: `gdal mdim get-refs`, rhdf5 chunk iteration, pizzarr, zaro, blocklist
- Icechunk: transaction-robust, version-able Zarr — Rust-powered, xarray-centric
- Real datasets: BRAN2023 (~70 TB), GHRSST (~2 TB/variable), sea ice NSIDC+AMSR2 (~20 GB)

## Packages mentioned

| Package | Language | Role |
|---|---|---|
| [VirtualiZarr](https://github.com/zarr-developers/VirtualiZarr) | Python | Build virtual Zarr stores from existing files |
| [kerchunk](https://github.com/fsspec/kerchunk) | Python | Original reference store builder |
| [Icechunk](https://github.com/earth-mover/icechunk) | Python/Rust | Transactional Zarr store |
| [gdal mdim get-refs](https://github.com/OSGeo/gdal/pull/11600) | GDAL CLI | Extract chunk byte refs to Parquet/GPKG |
| [pizzarr](https://github.com/keller-mark/pizzarr) | R | Zarr reader for R |
| [zaro](https://github.com/hypertidy/zaro) | R | Pure-R Zarr reader via Arrow FS |
| [blocklist](https://github.com/hypertidy/blocklist) | R | kerchunk-Parquet reference store builder |
| [rhdf5](https://bioconductor.org/packages/rhdf5) | R | HDF5 interface incl. `H5Dchunk_iter` |

## Author

Michael Sumner — Research Software Engineer, Australian Antarctic Division  
[github.com/mdsumner](https://github.com/mdsumner) · [hypertidy.org](https://hypertidy.org)
