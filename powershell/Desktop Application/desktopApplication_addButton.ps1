begin {
    Add-Type -AssemblyName PresentationFrameWork
    $window = New-Object System.Windows.Window
    $button = New-Object System.Windows.Controls.Button
}

process {
    $window.Title = 'Desktop Application'
    $window.ResizeMode = 'CanResize'
    $window.WindowStartupLocation = 'CenterScreen'
    $button.Content = "Click Me"
    $button.Add_Click(
        {
            [System.Windows.MessageBox]::Show("I was clicked")
        }
    )
    $window.AddChild($button)
}

end {
    $window.ShowDialog() | Out-Null
}