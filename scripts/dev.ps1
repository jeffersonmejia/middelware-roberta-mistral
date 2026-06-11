$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

& "$ProjectRoot\.venv\Scripts\python.exe" -m uvicorn main:app `
  --host 127.0.0.1 `
  --port 8000 `
  --reload `
  --reload-dir $ProjectRoot

