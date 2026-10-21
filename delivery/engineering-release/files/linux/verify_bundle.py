"""Verify an extracted internal bundle using only the Python standard library."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import sys


def verify(root):
    root = Path(root).resolve()
    manifest = json.loads((root / 'manifest.json').read_text(encoding='utf-8'))
    seen, errors = set(), []
    entries = manifest.get('files', [])
    if not entries:
        raise ValueError('Empty bundle manifest')
    for entry in entries:
        name = entry['path']
        relative = PurePosixPath(name)
        if relative.is_absolute() or '..' in relative.parts or '\\' in name or ':' in name:
            raise ValueError('Unsafe manifest path: ' + name)
        key = name.casefold()
        if key in seen:
            raise ValueError('Duplicate manifest path: ' + name)
        seen.add(key)
        path = (root / name).resolve()
        if not path.is_relative_to(root):
            raise ValueError('Path escapes bundle: ' + name)
        if not path.is_file():
            errors.append({'path': name, 'error': 'missing'})
            continue
        digest = hashlib.sha256()
        with path.open('rb') as stream:
            for block in iter(lambda: stream.read(1024 * 1024), b''):
                digest.update(block)
        if path.stat().st_size != entry['size'] or digest.hexdigest() != entry['sha256']:
            errors.append({'path': name, 'error': 'size or SHA-256 mismatch'})
    if errors:
        raise ValueError(json.dumps(errors[:20], ensure_ascii=True))
    return {'status': 'PASS', 'files': len(entries), 'edition': manifest.get('edition')}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', default=str(Path(__file__).resolve().parent))
    args = parser.parse_args()
    try:
        print(json.dumps(verify(args.root), ensure_ascii=True))
        return 0
    except (OSError, ValueError, KeyError, TypeError) as error:
        print('Bundle verification failed: ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
