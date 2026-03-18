$dsn = @{
        Name = "NAME"
        DsnType = "DSN_TYPE"
        Platform = "32/64-bit"
        DriverName = "DRIVER_NAME"
        SetPropertyValue = @("System = Server", "DefaultLibraries = Default Library")
    }
foreach ($attribute in $dsn) {
    Add-OdbcDsn -Name $attribute.Name -DriverName $attribute.DriverName -Platform $attribute.Platform -DsnType $attribute.DsnType -SetPropertyValue $attribute.SetPropertyValue
}