# Meal-Planning
This PowerShell script will ingest a static file of meals and randomize them and then put them on a monthly calendar so you can budget and plan for groceries and meals for your family.  Meal planning saves huge $$$ because you will buy all of your groceries ahead of time and will not be stumped as to what to cook and when to cook it.  You can even buy your groceries for the week online that way you are not tricked into buying other things as you wander through a store.

Parameters:
  Month - Month you would like to process
  Year - Year you would like to process (for Jan of next year)
  
  You can pass in just the Month and it will process that month for the current year
  You can pass in Month and Year to process a future or past month and year
  You can leave the Month and Year parameters blank and it will process your current month

Notes:
The randomization does not yet factor in previous or future meals on the given calendar.  For Example, if it schedules Chicken Tacos for Tuesday, it doesn't take into account that it just scheduled Chicken or Mexican the day before.

Future Improvements:
Ability to determine if you've had the meal in the past two weeks and not duplicate that meal
Ability to determine if you've had a certain meal in the past week and not generate another similar meal for that week
Ability to use left overs for another meal in that same week
