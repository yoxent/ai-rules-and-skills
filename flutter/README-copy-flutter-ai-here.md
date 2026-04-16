# `copy-flutter-ai-here.bat`

Copies Flutter Cursor config from this repository into a target Flutter project.

## Source and Target

- Source is fixed to: `E:\Projects\Tools\aiskills\flutter\.cursor`
- Target is: `<target-project>\.cursor`
- Existing files are overwritten

## Usage

Run from any terminal folder:

```bat
"E:\Projects\Tools\aiskills\flutter\copy-flutter-ai-here.bat" "E:\Projects\Flutter\my-new-app"
```

Or run without arguments to copy into the current terminal folder:

```bat
copy-flutter-ai-here.bat
```

## Recommended Flow

1. Open terminal in `aiskills\flutter`.
2. Run script with the Flutter project path.
3. Verify target contains:
   - `.cursor\rules\...`
   - `.cursor\skills\...`

## Notes

- The script uses a hardcoded source path (adjust the `.bat` if you move this repo).
- Script fails if source and target resolve to the same `.cursor` folder.
- If target `.cursor` does not exist, it is created automatically.
