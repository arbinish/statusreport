#!/usr/bin/env python

from flask import Flask, make_response, request
from datetime import date, datetime, timedelta
import json
from flask.ext.sqlalchemy import SQLAlchemy


class AppJSONEncoder(json.JSONEncoder):

    def default(self, obj):
        if isinstance(obj, datetime) or isinstance(obj, date):
            return int(obj.strftime('%s')) * 1000
        return json.JSONEncoder.default(self, obj)

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///reports.db'
db = SQLAlchemy(app)
app.json_encoder = AppJSONEncoder


class Entry(db.Model):
    __tablename__ = 'entries'
    id = db.Column(db.Integer, primary_key=True)
    week_id = db.Column(db.Integer, db.ForeignKey('weeks.id'))
    date = db.Column(db.DateTime)
    text = db.Column(db.Text(convert_unicode=True))
    tags = db.Column(db.String(128))

    def __repr__(self):
        return u'Entry <{0}>'.format(self.id)

    def toJSON(self):
        return {'id': self.id, 'week_id': self.week_id,
                'date': self.date, 'text': self.text,
                'tags': self.tags}


class Week(db.Model):
    __tablename__ = 'weeks'
    id = db.Column(db.Integer, primary_key=True)
    start_date = db.Column(db.DateTime, unique=True)
    end_date = db.Column(db.DateTime, unique=True)
    week_id = db.Column(db.Integer)
    entries = db.relationship('Entry', backref='department')

    def __repr__(self):
        return u'Week <{0}>'.format(self.start_date.strftime('%V'))

    def toJSON(self):
        return {'id': self.id, 'week_id': self.week_id, 'start': self.start_date,
                'end': self.end_date}


@app.route('/')
def index():
# Ideally this should be served as a template from templates dir, but for demo
# purpose this is sufficient
    return INDEX


@app.route('/weeks')
def show_weeks():
    response = make_response(json.dumps([e.toJSON() for e in Week.query.all()],
                                        cls=AppJSONEncoder))
    response.headers['Content-type'] = 'application/json'
    return response


@app.route('/entries')
def show_entries():
    response = make_response(json.dumps([e.toJSON() for e in Entry.query.order_by(Entry.date).all()],
                                        cls=AppJSONEncoder))
    response.headers['Content-type'] = 'application/json'
    return response


def get_date(edate):
    return date.fromtimestamp(int(edate) / 1000)


def add_week(edate):
    week_id = int(edate.strftime('%V'))
    w = Week.query.filter(Week.week_id == week_id).all()
    if w:
        return w.pop()
    delta = edate.isoweekday() - 1
    monday = edate - timedelta(days=delta)
    #friday = monday + timedelta(days=4)
    weekend = monday + timedelta(days=6, hours=23, minutes=59, seconds=59)
    w = Week(start_date=monday, end_date=weekend, week_id=week_id)
    app.logger.info('Adding week entry: week_id {0}'.format(week_id))
    try:
        db.session.add(w)
        db.session.commit()
    except:
        db.session.rollback()
    return w


@app.route('/entry', methods=['POST'])
def add_entry():
    data = request.get_json()
    app.logger.info('data is: {0}'.format(data))
    _date = data.get('date')
    _etext = data.get('text')
    _etags = data.get('tags')
    if not _etext:
        return 'Missing text', 400
    _edate = get_date(_date)
    _eweek = add_week(_edate)
    #_eweekid = int(_edate.strftime("%V"))
    _eweekid = _eweek.id
    _entry = Entry(week_id=_eweekid, date=_edate, text=_etext, tags=_etags)
    try:
        db.session.add(_entry)
        db.session.commit()
    except:
        db.session.rollback()
    resp = make_response(json.dumps(_entry.toJSON(), cls=AppJSONEncoder))
    resp.headers['Content-type'] = 'application/json'
    return resp


@app.route('/week')
def getweek():
    return datetime.now().strftime('%V')


@app.route('/entry/<int:id>', methods=['GET', 'PUT', 'DELETE'])
def edit_entry(id):

    if request.method == 'GET':
        resp = make_response(json.dumps(
            Entry.query.get_or_404(id).toJSON(),
            cls=AppJSONEncoder))
        resp.headers['Content-type'] = 'application/json'
        return resp

    if request.method == 'DELETE':
        _entry = Entry.query.get_or_404(id)
        db.session.delete(_entry)
        db.session.commit()
        return 'Deleted', 204

    data = request.get_json()
    app.logger.info('[PUT] data: {0}'.format(data))
    _entry = Entry.query.get_or_404(id)
    for e in ('text', 'tags', 'date'):
        if e == 'date':
            setattr(_entry, e, get_date(data.get(e)))
            _week = add_week(get_date(data.get(e)))
            _entry.week_id = _week.id
        else:
            setattr(_entry, e, data.get(e))
    try:
        db.session.commit()
        response = make_response(json.dumps(_entry.toJSON(),
                                            cls=AppJSONEncoder))
        response.headers['Content-type'] = 'application/json'
        return response
    except Exception as e:
        db.session.rollback()
        return e, 400

if __name__ == '__main__':
    INDEX = open('index.html').read()
    CURRENT_YEAR = datetime.now().year
    CURRENT_MONTH = datetime.now().month
    app.run(debug=True, host='0.0.0.0', port=9887)
