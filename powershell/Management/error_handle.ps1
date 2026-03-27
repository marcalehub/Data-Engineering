try {
    <#Do this#>
}
catch {
    <#Do this if a terminating exception happens#>
    "An error occurred: $($_) $(Get-Date)" | Out-File -FilePath "error_log.txt" -Append
    Start-Process "./error_log.txt"
    Throw $_ # Re-throw the exception if you want it to propagate further
}
finally {
    <#Do this no matter what happens#>

}