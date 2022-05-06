function Get-UDFWeekofYear{
    Param($date)
        $cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
        $cultureInfo.Calendar.GetWeekOfYear($Date,$cultureInfo.DateTimeFormat.CalendarWeekRule,$cultureInfo.DateTimeFormat.FirstDayOfWeek)
}