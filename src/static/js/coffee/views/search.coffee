class SearchView extends Backbone.View
    className: "input-group"
    template: _.template("""<input type="text" id="search" class="form-control">
        <div class="input-group-btn"><button class="btn btn-default">Search</button></div>""")
    initialize: ->
        @render()
        @
    render: ->
        @$el.append @template()
        @