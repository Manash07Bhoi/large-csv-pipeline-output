# large-csv-pipeline-output

Processed dataset metadata produced by
[`large-csv-pipeline`](https://github.com/Manash07Bhoi/large-csv-pipeline).

## What's in this repo

| File | Purpose |
|------|---------|
| `index.db` | Lightweight SQLite index (id + title) used by the UI for fast lookups |
| `map.json` | Shard map: which row ranges live in which shard `.db` file |
| `output_manifest.json` | Dataset summary (row counts, shard sizes, validation status) |
| `logs/` | Per-stage processing logs from the pipeline run |

## Dataset summary

- **Total rows:** 1,307,158
- **Shards:** 26 files (~200 MB each)
- **Source database:** 5119.35 MB
- **Index database:** 1140.35 MB

## Why some files are missing

GitHub rejects any single file larger than **100 MB** on the standard
git transport. The following artifacts are produced by the pipeline
locally but **not** committed here:

- `dataset.zip` — original ZIP download (~1.4 GB)
- `extracted_data/*.csv` — unpacked CSV (~17 GB)
- `parquet_output/` — intermediate Parquet files
- `database.db` — full monolithic SQLite database (~5 GB)
- `db_shards/videos_part_*.db` — 26 shard databases (~200 MB each)
- `index.db` — full row-level index (~1.1 GB, exceeds 100 MB)

Only the small metadata that an application needs at runtime to
discover and address the shards (`map.json`, `output_manifest.json`)
plus the processing logs are committed here.

## Regenerating the full dataset

Clone the pipeline repo and run:

```bash
git clone https://github.com/Manash07Bhoi/large-csv-pipeline.git
cd large-csv-pipeline
pip install -r requirements.txt
python pipeline/cli.py run "<ZIP_URL>"
```

This will reproduce every artifact under `output/` deterministically.
