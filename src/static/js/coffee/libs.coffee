month_map =
    0: "Jan"
    1: "Feb"
    2: "Mar"
    3: "Apr"
    4: "May"
    5: "Jun"
    6: "Jul"
    7: "Aug"
    8: "Sept"
    9: "Oct"
    10: "Nov"
    11: "Dec"

entryDateFmt = (d) ->
    _d = new Date d

    "#{month_map[do _d.getMonth]} - #{do _d.getDate}"

getMonth = (m) ->
    for k, v of month_map
        return +k+1 if m == v
    undefined

getTodaysDate = ->
    d = new Date()
    d.setHours(0)
    d.setMinutes(0)
    d.setSeconds(0)
    d.setMilliseconds(0)
    d.getTime()

window.getMonth = getMonth
window.entryDateFmt = entryDateFmt
window.month_map = month_map