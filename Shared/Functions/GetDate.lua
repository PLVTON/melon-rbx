return function()
	return {
		Month = os.date("!*t").month,
		Year = os.date("!*t").year,
		Week = math.floor(os.date("!*t").day/7),
		Day = os.date("!*t").day
	}
end
