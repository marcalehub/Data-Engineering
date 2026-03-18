$PATH = Get-Location
$PYTHON = '.exe'
Start-Job {
  & $using:PYTHON `
  -u "$($using:PATH)\FILE_NAME.py"
} | Wait-Job