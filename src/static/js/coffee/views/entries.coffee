class EntriesView extends Backbone.View
    initialize: ->
        #@listenTo @collection, 'add', @addOne
        @listenTo @collection, 'reset', @addAll

    addOne: (m) ->
        #console.log 'adding one', m.toJSON()
        view = new EntryView model: m
        @$el.prepend view.render().el
        @

    addAll: ->
        #console.log 'entriesview addAll called!!'
        @$el.remove()
        @collection.each(@addOne, @)
        @

    onClose: ->
        @collection.models.forEach (model) ->
            model.unbind()

    render: ->
        #console.log 'entriesView render called', arguments, 'this.$el', this.$el
        @collection.each (model) =>
          @addOne model
        @

window.App.EntriesView = EntriesView
