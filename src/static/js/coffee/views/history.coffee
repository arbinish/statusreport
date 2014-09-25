class HistoryView extends Backbone.View
  tagName: "ul"
  className: "history"
  template: _.template """
      <h4> Weeks </h4><hr/>
      <% _.each(years, function(year) {
        weekGroup = _.groupBy(history[year], function(entries) {
          return entries.week_id
        });
        weekIds = _.keys(weekGroup);
        for (_id in weekIds) {
          week_id = +weekIds[_id];
          weekStart = weeks.models.filter(function(w) {
            return w.id == week_id
          });
          weekStart = weekStart.pop();
          weekStartDate = new Date(weekStart.get('start')).toDateString(); 
          reportUrl = '#report/' + year + '-' + weekStart.get('id');%>
          <li><a href="<%- reportUrl %>"><%- weekStartDate %></a>
          <span class="badge"><%- weekGroup[week_id].length %></span></li>
      <% }
      }) %>
    """
  render: ->
    window.App.entries.getHistory()
    history = App.entries.history
    weeks = App.weeks
    years = _.keys history
    @$el.html @template weeks: weeks, years: years, history: history
    @

window.App.HistoryView = HistoryView
