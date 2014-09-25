class Entry extends Backbone.Model
  defaults:
    week_id: ''
    date: getTodaysDate()
    text: 'New worklog'
    tags: 'progress'
  urlRoot: '/entry'
  update: ->
    attrs = @changedAttributes()
    console.log('attrs', attrs, "text in?", "text" of attrs)
    if attrs
        console.log('something changed for', @toJSON())

class Entries extends Backbone.Collection
  url: '/entries',
  model: Entry,
  getHistory: ->
    @history = {}
    _.each @models, (model) =>
      year = (new Date model.get('date')).getFullYear()
      if not @history[year]?
        @history[year] = []
      #weeks = _.pluck @toJSON(), 'week_id'
      week_id = model.get 'week_id'
      @history[year].push model.attributes

  #setup: ->
  #  @week = @models.toDict('week_id')
  #  @

#Array::toDict = (key) ->
#  dict = []
#  (dict[obj.get(key)] ||= []).push obj for obj in @
#  dict

window.App = {}
window.App.Entry = Entry
window.App.Entries = Entries
