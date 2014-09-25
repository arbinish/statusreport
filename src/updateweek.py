from main import Week, db
from datetime import datetime, timedelta

start = datetime(2014, 9, 1, 0, 0, 0)
for i in range(1, 52):
    end_date = start + timedelta(days=6, hours=23, minutes=59, seconds=59)
    week = Week(start_date=start, end_date=end_date,
                week_id=end_date.strftime('%V'))
    db.session.add(week)
    start += timedelta(days=7)
db.session.commit()
