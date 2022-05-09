try
{
    # This is a simple user/pass connection string.
    # Feel free to substitute "Integrated Security=True" for system logins.
    $connString = "Data Source=MST3K\DEVINSTANCE;Database=CWDB;User ID=SA;Password=P@55word"

    #Create a SQL connection object
    $conn = New-Object System.Data.SqlClient.SqlConnection $connString

    #Attempt to open the connection
    $conn.Open()
    if($conn.State -eq "Open")
    {
        # We have a successful connection here
        # Notify of successful connection
        Write-Host "Test connection successful"
        $conn.Close()
    }
    # We could not connect here
    # Notify connection was not in the "open" state
}
catch
{
    # We could not connect here
    # Notify there was an error connecting to the database
}