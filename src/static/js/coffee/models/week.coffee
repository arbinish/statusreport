class Week extends Backbone.Model
    urlRoot: '/week'


class Weeks extends Backbone.Collection
    url: '/weeks'
    model: Week

    thisWeek: ->
      d = (new Date).getTime()
      _model = @models.filter (week) ->
        return week.get('start')  <= d <= week.get('end')
      _model.pop()


window.App ||= {}
window.App.Weeks = Weeks
