begin {
    Add-Type -AssemblyName PresentationFrameWork
    $window = New-Object System.Windows.Window
}

process {
    $window.Title = 'Desktop Application'
    $window.ResizeMode = 'CanResize'
    $window.WindowStartupLocation = 'CenterScreen'
}

end {
    $window.ShowDialog() | Out-Null
}