param ([string]$Month,[string]$Year)
#Thanks to whomever built the following calendar
#https://codepen.io/knyttneve/pen/QVqyNg

$path = $MyInvocation.MyCommand.Path
$folder = Split-Path $path -Parent
$Quarter = "$("{0:0}" -f [Math]::ceiling((Get-date -f MM)/3) )"
$meals = gc "$folder\Meals.txt" | where-object {$_ -like "*$Quarter*"} #We only want entries in the meals that can be cooked during this time period
$meals_array = 0..($meals.count - 1)
#Write-host $meals
#pause
if (!($Month))
{
	$FullDate = Get-Date
}
else
{
	if (!($Year))
	{
		#Get current year
		$Year = Get-Date -format yyyy
	}
	$FullDate = $Month+"-01-"+$Year
}
$year_num = Get-Date($FullDate) -format yyyy
$month_num = Get-Date($FullDate) -format MM
$month_string = Get-Date($FullDate) -format MMMM
$DaysInMonth = [datetime]::DaysInMonth($year_num,$month_num)
$FirstDay = (Get-Date -Year $year_num -Month $month_num -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -format "ddd")

#Find the column where the first day of the month starts
Switch ($FirstDay) {
	"Sun" {$StartDayColumn="1"}
	"Mon" {$StartDayColumn="2"}
	"Tue" {$StartDayColumn="3"}
	"Wed" {$StartDayColumn="4"}
	"Thu" {$StartDayColumn="5"}
	"Fri" {$StartDayColumn="6"}
	"Sat" {$StartDayColumn="7"}
}

#Randomly generate the order of the meals
$meal_order = $meals_array | get-random -count $DaysInMonth

<#
foreach ($meal_number in $meal_order)
{
	Write-Host $meals[$meal_number]
}
#>

$html_doc = "
<!DOCTYPE html>
<html>
<head>
<style>
html,
body {
  width: 100%;
  height: 100%;
}
body {
  background: #f5f7fa;
  padding: 40px 0;
  box-sizing: border-box;
  font-family: Montserrat, sans-serif;
  color: #51565d;
}

.calendar {
  display: grid;
  width: 100%;
  grid-template-columns: repeat(7, minmax(120px, 1fr));
  grid-template-rows: 50px;
  grid-auto-rows: 120px;
  overflow: auto;
}
.calendar-container {
  width: 90%;
  margin: auto;
  overflow: hidden;
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
  border-radius: 10px;
  background: #fff;
  max-width: 1200px;
}
.calendar-header {
  text-align: center;
  padding: 20px 0;
  background: linear-gradient(to bottom, #fafbfd 0%, rgba(255, 255, 255, 0) 100%);
  border-bottom: 1px solid rgba(166, 168, 179, 0.12);
}
.calendar-header h1 {
  margin: 0;
  font-size: 18px;
}
.calendar-header p {
  margin: 5px 0 0 0;
  font-size: 13px;
  font-weight: 600;
  color: rgba(81, 86, 93, 0.4);
}
.calendar-header button {
  background: 0;
  border: 0;
  padding: 0;
  color: rgba(81, 86, 93, 0.7);
  cursor: pointer;
  outline: 0;
}

.day {
  border-bottom: 1px solid rgba(166, 168, 179, 0.12);
  border-right: 1px solid rgba(166, 168, 179, 0.12);
  text-align: right;
  padding: 14px 20px;
  letter-spacing: 1px;
  font-size: 12px;
  box-sizing: border-box;
  color: #98a0a6;
  position: relative;
  pointer-events: none;
  z-index: 1;
}
.day:nth-of-type(7n + 7) {
  border-right: 0;
}
.day:nth-of-type(n + 1):nth-of-type(-n + 7) {
  grid-row: 2;
}
.day:nth-of-type(n + 8):nth-of-type(-n + 14) {
  grid-row: 3;
}
.day:nth-of-type(n + 15):nth-of-type(-n + 21) {
  grid-row: 4;
}
.day:nth-of-type(n + 22):nth-of-type(-n + 28) {
  grid-row: 5;
}
.day:nth-of-type(n + 29):nth-of-type(-n + 35) {
  grid-row: 6;
}
.day:nth-of-type(7n + 1) {
  grid-column: 1/1;
}
.day:nth-of-type(7n + 2) {
  grid-column: 2/2;
}
.day:nth-of-type(7n + 3) {
  grid-column: 3/3;
}
.day:nth-of-type(7n + 4) {
  grid-column: 4/4;
}
.day:nth-of-type(7n + 5) {
  grid-column: 5/5;
}
.day:nth-of-type(7n + 6) {
  grid-column: 6/6;
}
.day:nth-of-type(7n + 7) {
  grid-column: 7/7;
}
.day-name {
  font-size: 12px;
  text-transform: uppercase;
  color: #99a1a7;
  text-align: center;
  border-bottom: 1px solid rgba(166, 168, 179, 0.12);
  line-height: 50px;
  font-weight: 500;
}
.day--disabled {
  color: rgba(152, 160, 166, 0.6);
  background-color: #ffffff;
  background-image: url(''data:image/svg+xml,%3Csvg width='40' height='40' viewBox='0 0 40 40' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='%23f9f9fa' fill-opacity='1' fill-rule='evenodd'%3E%3Cpath d='M0 40L40 0H20L0 20M40 40V20L20 40'/%3E%3C/g%3E%3C/svg%3E'');
  cursor: not-allowed;
}

.task {
  border-left-width: 3px;
  padding: 8px 12px;
  margin: 10px;
  border-left-style: solid;
  font-size: 14px;
  position: relative;
}

.task--Meal {
  background: #4786ff;
  border: 0;
  border-radius: 4px;
  grid-column: 1/span 1;
  grid-row: 1;
  align-self: end;
  color: #fff;
  box-shadow: 0 10px 14px rgba(71, 134, 255, 0.4);
}
</style>
</head>
<body>
<div class='calendar-container'>
  <div class='calendar-header'>
    <h1>$month_string</h1>
	<p>$year_num</p></div>
  <div class='calendar'><span class='day-name'>Sun</span><span class='day-name'>Mon</span><span class='day-name'>Tue</span><span class='day-name'>Wed</span><span class='day-name'>Thu</span><span class='day-name'>Fri</span><span class='day-name'>Sat</span>`r`n"

#Fill in greyed out days
for($i=1;$i -lt $StartDayColumn;$i++)
{
	$html_doc+="    <div class='day day--disabled'> </div>`r`n"
}
#Fill in Day Numbers
for ($j=1;$j -le $DaysInMonth;$j++)
{
	$html_doc+="    <div class='day'>$j</div>`r`n"
}
     
$m = 0
#In the final row of the calendar, we have some filler fields that need to be put in.  Decide where these start.
$EndFillerStart = 7 - (35 - $DaysInMonth - ($StartDayColumn - 1)) + 1
#Cycle through calendar rows (there are 6 rows)
for ($r=2;$r -le 6;$r++)
{
	#Cycle through calendar columns (there are 7 columns for each day of the week)
	for ($c=1;$c -le 7;$c++)
	{
		#First row only
		if ($r -eq 2)
		{
			#Start populating when it reaches the start column
			if ($c -ge $StartDayColumn)
			{
				#It's a little tricky here to get the meal name from the random list, but it involves grabbing the random number list and using that number
				#to grab the meal name in the meal array
				$meal_name_array = ($meals[$meal_order[$m]]).Split(",")
				$meal_name = $meal_name_array[0]
				$meal_description = $meal_name_array[1]
				$meal_type = $meal_name_array[2]
				$html_doc+= "    <section class='task task--Meal' style='grid-column: $c/span 1; grid-row: $r;'>$meal_name</section>`r`n"
				$m++
			}
		}
		elseif ($r -eq 6)
		{
			#Fill the end of the calendar with blanks
			if ($c -ge $EndFillerStart)
			{
				$html_doc+="    <div class='day day--disabled'> </div>`r`n"
			}
			else
			{
				#It's a little tricky here to get the meal name from the random list, but it involves grabbing the random number list and using that number
				#to grab the meal name in the meal array
				$meal_name_array = ($meals[$meal_order[$m]]).Split(",")
				$meal_name = $meal_name_array[0]
				$meal_description = $meal_name_array[1]
				$meal_type = $meal_name_array[2]
				$html_doc+= "    <section class='task task--Meal' style='grid-column: $c/span 1; grid-row: $r;'>$meal_name</section>`r`n"
				$m++
			}
		}
		else
		{
			#It's a little tricky here to get the meal name from the random list, but it involves grabbing the random number list and using that number
			#to grab the meal name in the meal array
			$meal_name_array = ($meals[$meal_order[$m]]).Split(",")
			$meal_name = $meal_name_array[0]
			$meal_description = $meal_name_array[1]
			$meal_type = $meal_name_array[2]
			$html_doc+= "    <section class='task task--Meal' style='grid-column: $c/span 1; grid-row: $r;'>$meal_name</section>`r`n"
			$m++
		}
	}
}

$html_doc+="</div></div></body></html>"

$html_doc | out-file "$folder\$month_string$year_num.html"

Start-Process "chrome.exe" "$folder\$month_string$year_num.html"
