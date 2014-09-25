class Movie extends Backbone.Model
    defaults:
        name: ''
        year: 2014
        watched: 0

class Movies extends Backbone.Collection
    model: Movie

class MovieView extends Backbone.View
    id: ->
        return @model.cid
    initialize: ->
        #@listenTo @model, "change", @render
        @
    render: ->
        #@$el.append """<input type="text" name="movie" value="#{@model.get('name')}"/>
        @$el.html """<div contenteditable>#{@model.get 'name'}</div>
        <a class="btn btn-primary" href="\#/movie/#{@model.cid}">view</a>"""
        @

    events:
        "change input": "updateName"
        "blur div": "updatedivName"
        "click div": "dummyClick"

    dummyClick: (e) ->
        console.log 'clicked on', e.target

    updatedivName: (e) =>
        z = $(e.target).text()
        console.log 'updating name from', @model.get('name'), 'to', z
        @model.set 'name', z
        @

    updateName: (e) ->
        console.log 'name is', @$el.find('input').val()
        @model.set 'name', @$el.find('input').val()
        console.log 'collection:', @model.collection
        @


class DetailView extends Backbone.View
    render: =>
        watched = +@model.get 'watched'
        console.log 'watched initialily is', watched
        val = 'Not watched'
        if watched
            val = 'Watched'
        @$el.empty()
        @$el.html """<input type="text" name="movie" value="#{@model.get('name')}"/>"""
        @$el.append "<span class=\"btn btn-success\" data-watched=\"#{@model.get 'watched'}\">#{val}</span>"
        @

    events:
        'click span': 'updateStatus'

    updateStatus: (e) =>
        $ele = $(e.target)
        watched = +$ele.data 'watched'
        val = $ele.text()
        console.log 'attrib', watched, 'value is', val
        watched = +(not watched)
        console.log 'now watched is', watched
        val = 'Not watched'
        if watched
            val = 'Watched'
        $ele.attr 'data-watched', watched
        $ele.data 'watched', watched
        $ele.text val
        @model.set
            watched: watched
        @


class MoviesView extends Backbone.View
    id: 'movies'
    render: ->
        @$el.html ""
        @collection.models.forEach (model) =>
            movie = new MovieView model: model
            @$el.append movie.render().el
        @

movies = new Movies
movies.add([
    new Movie
        name: 'Jupiter Ascending',
    new Movie
        name: 'Hercules',
    new Movie
        name: 'Lucy'])

class AppView extends Backbone.View
    initialize: ->
        @moviesView = new MoviesView
            collection: @collection
        window.moviesView = @moviesView
        @moviesView.render()
        @listenTo @collection, "all", @logit

    logit: ->
        console.log 'log event for appview', arguments

    render: ->
        @$el.html @moviesView.render().el
        @

class AppRouter extends Backbone.Router
    initialize: ->
        console.log 'initializing router: collection', movies
        @appView = new AppView
            collection: movies
            el: 'div#main'
        window.appView = @appView

    routes:
        "" : "index"
        "movie/:id": "showdetailView"

    index: ->
        console.log 'index'
        @appView.render()

    showdetailView: (id) ->
        console.log 'clicked on', id
        model = movies.models.filter (m) ->
            return m.cid == id
        if model.length == 0
            console.log "no such movie"
            return @
        model = model[0]
        @detailView.undelegateEvents() if @detailView
        @detailView = new DetailView
            model: model
            el: 'div#main'
        @detailView.render()

window.Movie = Movie
window.Movies = Movies
window.MovieView = MovieView
window.MoviesView = MoviesView
window.movies = movies

appRouter = new AppRouter
Backbone.history.start()