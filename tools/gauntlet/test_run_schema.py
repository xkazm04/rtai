"""Integration test. Run with Python and jsonschema installed."""

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from jsonschema import Draft202012Validator


ROOT = Path(__file__).resolve().parents[2]
SCHEMA = ROOT / "project/data/schemas/gauntlet_run.schema.json"


class GauntletRunSchemaTest(unittest.TestCase):
    def test_bot_waves_with_and_without_a_machine_validate_strictly(self):
        output = ROOT / "build/gauntlet/tests"
        output.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=output) as scratch:
            result = Path(scratch) / "result.json"
            subprocess.run(
                [
                    "node", "tools/dev/run.mjs", "gauntlet", "--seed=1",
                    "--bot=average", "--pick=greedy", "--controls=wheel",
                    "--waves=5", f"--result={result}",
                ],
                cwd=ROOT,
                check=True,
            )
            run = json.loads(result.read_bytes())

        waves = run["waves"]
        self.assertEqual(run["profile"], "average")
        self.assertTrue(any("machine" not in wave for wave in waves))
        machine = next(wave["machine"] for wave in waves if "machine" in wave)
        self.assertGreater(machine["ticks"], 0)
        for wave in waves:
            self.assertIn("guard_ticks", wave)
            self.assertIn("cover_ticks", wave)

        schema = json.loads(SCHEMA.read_bytes())
        Draft202012Validator.check_schema(schema)
        validator = Draft202012Validator(schema)
        validator.validate(run)
        machine["unexpected_counter"] = 0
        self.assertFalse(validator.is_valid(run))


if __name__ == "__main__":
    unittest.main()
