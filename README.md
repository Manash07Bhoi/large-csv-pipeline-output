# large-csv-pipeline — App-Ready Artifacts

This repository contains only the **lightweight, app-consumable outputs** of the
[large-csv-pipeline](https://github.com/Manash07Bhoi/large-csv-pipeline) project.
Large binary files (SQLite shards, Parquet, raw CSV) are excluded to stay within
GitHub's 100 MB per-file limit.

---

## What's included

| File | Size | Description |
|---|---|---|
| `map.json` | ~2 KB | Shard manifest — lists every shard file, its row range, and path |
| `output_manifest.json` | ~1 KB | Pipeline run summary — status, row counts, validation result |
| `index.db` | 4.7 MB | Lightweight SQLite index for fast id/title lookups (< 100 MB → included) |
| `logs/small_mode.log` | ~1 KB | Per-stage row counts and validation log |

---

## What's excluded and why

| Artifact | Reason |
|---|---|
| `db_shards/videos_part_1.db` (39 MB) | Individual shard — usable directly, but regenerate locally for full dataset |
| `database.db` | Intermediate consolidated SQLite — large, regenerate locally |
| `parquet_output/` | Intermediate Parquet files — large, regenerate locally |
| `extracted_data/` | Raw sliced CSV — large, regenerate locally |

GitHub enforces a **100 MB per-file hard limit** and recommends keeping
repositories under 1 GB. Shards and databases grow with the dataset and would
quickly exceed these limits.

---

## How to regenerate the full dataset locally

### Prerequisites

```bash
git clone https://github.com/Manash07Bhoi/large-csv-pipeline.git
cd large-csv-pipeline
pip install -r pipeline/src/requirements.txt   # or: pip install pandas pyarrow tqdm
```

### Small mode (10 000 rows — fast smoke-test)

```bash
python pipeline/cli.py run "<ZIP_URL>" --small-mode --small-rows 10000
```

Or directly with an existing CSV:

```bash
# outputs go to output_small/
PYTHONPATH=pipeline/src python3 -c "
from pathlib import Path
from small_mode_pipeline import run_small_mode
run_small_mode(
    csv_files=[Path('output/extracted_data/your-dataset.csv')],
    work_small=Path('output_small'),
    table='videos',
    n_rows=10_000,
    shard_mb=50,
    sep='|',
    has_header=False,
)
"
```

### Full pipeline

```bash
bash pipeline/run_persistent.sh "<ZIP_URL>"
```

---

## Developer

Developed by **Roshan**.
