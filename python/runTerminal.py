import subprocess as terminal

output = terminal.run(args=['Powershell', 'Write-Host "HOLAMUNDO"'], capture_output=True, text=True)
print(output.stdout)