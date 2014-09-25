class ReportView extends Backbone.View
  progressTemplate: _.template """
  <div class="entry">
    <h4><%- title %></h4>
    <% _.each(_.keys(progress), function(title) { %>
       <div class="record">
          <h5><%- title %></h5>
      <% _.each(progress[title], function(model) { %>
          <span><%- model.get('text') %></span><br/>
        <% }) %>
      </div>
    <% }) %>
  </div>
  """

  titleTemplate: _.template """
  <h4 style="font-variant: small-caps;font-family: Raleway, 'Helvetica Neue', Helvetica, sans-serif">
  Status Report for the week <%- monday %> &#8213; <%- friday %></h4>
  <hr/>
  """

  template: _.template """
    <div class="entry">
      <h4><%- title %></h4>
      <% _.each(records, function(record) { %>
        <div class="record">
          <span><%- record.get('text') %></span>
        </div>
      <% }) %>
    </div>
  """

  className: "container"

  initialize: (options) ->
    @options = options
    if @options.weekId
      @weekId = @options.weekId
    console.log('weekid', @options)

  render: ->
    if @weekId
      console.log('got weekid', +@weekId)
      thisWeek = window.App.weeks.get +@weekId
    else
      thisWeek = @collection.thisWeek()

    console.log('thisWeek', thisWeek)

    currentReport = window.App.entries.filter (model) ->
        model.get('week_id') == thisWeek.id

    progress = currentReport.filter (model) ->
      model.get('tags').indexOf('progress') != -1

    plan = currentReport.filter (model) ->
      model.get('tags').indexOf('plan') != -1

    currentReport = _.difference currentReport, progress, plan

    progress.forEach (model) ->
      _tags = _.difference (i.trim() for i in model.get('tags').split(',')), "progress"
      model._tags = _tags.pop()

    plan.forEach (model) ->
      _tags =  _.difference (i.trim() for i in model.get('tags').split(',')), "plan"
      model._tags = _tags.pop()


    progress = _.groupBy progress, (model) ->
      model._tags

    plan = _.groupBy plan, (model) ->
      model._tags

    currentReport = _.groupBy currentReport, (model) ->
      model.get('tags')
  
    window.progress = progress
    window.plan = plan
    _today = new Date().getDay()
    #monday = new Date( new Date().getTime() - (_today - 1) * 86400 * 1000 )
    monday = new Date thisWeek.get('start')
    friday = new Date thisWeek.get('end')
    #friday = new Date( new Date().getTime() + (5 - _today) * 86400 * 1000 )

    @$el.html @titleTemplate monday: monday.toDateString(), friday: friday.toDateString()

# show only if there are any progress items
    if _.keys(progress).length
      @$el.append  @progressTemplate progress: progress, title: 'Progress'
    if _.keys(plan).length
      @$el.append  @progressTemplate progress: plan, title: 'Plan'

    for title, models of currentReport
      @$el.append @template title: title,  records: models

    @
