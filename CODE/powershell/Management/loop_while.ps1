do {
    <# Code to execute at least once, and then repeat as long as the condition is true #>
} while (
    <# Condition that stops the loop if it returns false #> -eq $false
)

While ($true) {
    <# Code to execute repeatedly until the condition is false #>
    if (
        <# Condition that stops the loop if it returns false #> -eq $false
    ) {
        break
    }
}