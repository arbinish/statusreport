class AppBaseView extends Backbone.View
    initialize: ->
        @searchView = new SearchView
        @entriesView = new EntriesView
            collection: window.App.entries
        #@collection.fetch()
        @

    onClose: ->
        @entriesView.onClose()

    render: ->
        #@$el.html @searchView.el
        @$el.html (new SearchView).el
        #@$el.append @entriesView.render().el
        @$el.append (new EntriesView collection: window.App.entries).render().el
        @

class AppRouter extends Backbone.Router
    initialize: ->
        @$el = $('#main')
        @

    routes:
        "": "index"
        "add": "addEntry"
        "report/:id": "reportHist"
        "report": "report"
        "history": "history"

    index: ->
        fetch = false
        if not window.App.entries.length
          fetch = true 
        @changeView new AppBaseView, [window.App.entries], fetch
        @

    addEntry: =>
        @changeView new NewEntryView, [window.App.entries]
        @

    history: =>
      fetch = false
      if not window.App.entries.length or not window.App.weeks
        fetch = true
      @changeView new HistoryView, [window.App.entries, window.App.weeks], fetch
      @

    report: =>
      fetch = false
      if not window.App.weeks.length or not window.App.entries.length
        fetch = true
      @changeView (new ReportView collection: window.App.weeks), [window.App.weeks, window.App.entries], fetch

    reportHist: (id) ->
        [year, weekId] = id.split('-')
        console.log 'reportHist called. weekId', weekId
        fetch = false
        if not window.App.weeks.length or not window.App.entries.length
          fetch = true
        @changeView (new ReportView collection: window.App.weeks,  weekId: +weekId), [window.App.weeks, window.App.entries], fetch
         
    changeView: (view, collections, fetch=true) ->
        render = _.after collections.length, =>
          @$el.html view.render().el

        if not fetch
          @$el.html view.render().el
          return @

        if _.isEmpty collections
          render
        else
          for collection in collections
            collection.fetch success: render
        @


$(document).ready ->
  app_router = new AppRouter 

  app_router.on "route", (name, params) ->
    root = $('ul.nav.navbar-nav')
    console.log 'router name', name
    ele = root.find('a[href=#]')
    if name == "report" or name == "reportHist"
      ele = root.find('a[href=#report]')
    if name == "addEntry"
      ele = root.find('a[href=#add]')
    if name == "history"
      ele = root.find('a[href=#history]')
    root.find('li.active').removeClass('active')
    ele.parent().addClass('active')


  window.App.weeks = new Weeks
  window.App.entries = new Entries
  window.App.app_router = app_router
  Backbone.history.start()
