import importlib.util
import pathlib
import sys
import unittest


ASSEMBLE_PATH = pathlib.Path(__file__).resolve().parents[1] / "assemble.py"
SPEC = importlib.util.spec_from_file_location("savr_assemble", ASSEMBLE_PATH)
assert SPEC is not None and SPEC.loader is not None
assemble = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = assemble
SPEC.loader.exec_module(assemble)


SAMPLE_MANIFEST = """\
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.rockstargames.gtasa">
    <permission android:name="com.rockstargames.gtasa.PRIVATE" />
    <uses-permission android:name="com.rockstargames.gtasa.PRIVATE" />
    <application android:label="GTA: SA">
        <activity android:name="com.rockstargames.gtasa.GameActivity" />
        <meta-data android:name="APP_NAME" android:value="com.rockstargames.gtasa" />
        <provider android:name="rockstarmobile.Provider"
            android:authorities="com.rockstargames.gtasa.provider" />
    </application>
</manifest>
"""


class PackageVariantTests(unittest.TestCase):
    def tearDown(self):
        assemble.TARGET_PACKAGE_NAME = assemble.PACKAGE_NAME

    def test_default_package_is_byte_for_byte_unchanged(self):
        assemble.TARGET_PACKAGE_NAME = assemble.PACKAGE_NAME
        self.assertEqual(
            assemble.rewrite_manifest_package_identity(SAMPLE_MANIFEST),
            SAMPLE_MANIFEST,
        )

    def test_identity_changes_but_retail_activity_class_does_not(self):
        assemble.TARGET_PACKAGE_NAME = "com.savr.dioramamr"
        rewritten = assemble.patch_manifest(
            SAMPLE_MANIFEST,
            patch_vr_entrypoint=False,
        )

        self.assertIn('package="com.savr.dioramamr"', rewritten)
        self.assertIn('android:name="com.savr.dioramamr.PRIVATE"', rewritten)
        self.assertIn('android:value="com.savr.dioramamr"', rewritten)
        self.assertIn('android:authorities="com.savr.dioramamr.provider"', rewritten)
        self.assertIn('android:label="GTA SA Diorama MR"', rewritten)
        self.assertIn(
            'android:name="com.rockstargames.gtasa.GameActivity"',
            rewritten,
        )


if __name__ == "__main__":
    unittest.main()
