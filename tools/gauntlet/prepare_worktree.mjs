import { cpSync, existsSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';

// Copy the portable imported resources into a private cache. The dev runner checks
// asset hashes and class declarations here and imports missing or stale inputs.
export function seedImportCache(root, tree) {
  const source = join(root, 'project/.godot');
  const target = join(tree, 'project/.godot');
  mkdirSync(target, { recursive: true });
  for (const entry of ['.gdignore', 'imported', 'global_script_class_cache.cfg', 'uid_cache.bin', 'extension_list.cfg']) {
    const path = join(source, entry);
    if (existsSync(path)) cpSync(path, join(target, entry), { recursive: true, dereference: true });
  }
}
