class EntryView extends Backbone.View
    tagName: 'dl'
    id: ->
        "m-#{@model.id}"
    template: _.template("""
        <span class="delete-model pull-right">&#x2702;</span>
        <dt contenteditable><%= fmtDate  %></dt>
            <dd contenteditable class="text"><%= text %></dd>
            <% if (tags) { %>
                <span class="delete-tag" data-toggle="tooltip" title="Remove Tag">&nbsp;&#x2717;&nbsp;</span>
                <dd contenteditable class="badge tag" title="Edit Tag"
                        data-placement="right" data-toggle="tooltip"><%= tags %></dd>
            <% } else {%>
                <span class="badge alert-success" title="Add Tag" data-placement="right"
                    data-toggle="tooltip">&#x271b;</span><%} %>""")
    initialize: ->
        @listenTo @model, 'change', @render
        @listenTo @model, 'destroy', @removeView
        @

    removeView: =>
        @remove()
        @model.unbind()
        @

    saveModel: =>
        #console.log 'entryview savemodel: changed attr', @model.changedAttributes(), 'arguments', arguments
        if @model.hasChanged()
            @model.save silent: true
            console.log "+++ model saved!!"
        @render()
        @

    render: (m, o) =>
        #console.log "view render: following options", arguments
        fields = @model.toJSON()
        if not fields
            console.log 'fields empty for this view'
        fields.fmtDate = entryDateFmt @model.get('date')
        @$el.html(@template(fields))
        @$("[data-toggle=tooltip]").tooltip()
        @

    events:
        "click span.badge": "addTag"
        "click .delete-tag": "removeTag"
        "click .delete-model": "clearEntry"
        "focusout dd": "updateInfo"
        "focusout dt": "updateDate"

    updateDate:(e) =>
        _text = $(e.target).text()?.trim()
        _text = _text.split(' - ')
        _d = new Date
        _d.setMonth (+getMonth(_text[0]) - 1)
        _d.setDate +_text[1]
        if isNaN _d
        # bad input date
           @render()
           return @
        _d.setHours 0
        _d.setMinutes 0
        _d.setSeconds 0
        _d.setMilliseconds 0
        if @model.get('date') != _d.getTime()
           @model.set 'date', _d.getTime()
           @model.save()
        false

    updateInfo: (e) =>
        #console.log 'updateInfo called', arguments
        if $(e.target).hasClass('text')
            if not $(e.target).text()?.trim()
                if confirm "Are you sure you want to purge this log?"
                    @$el.off "blur", "dd", ->
                        #console.log 'removing handler'
                    @model.destroy()
                    return false
            else
                #console.log 'entryview text changed. will set model'
                @model.set 'text', _.escape($(e.target).text()?.trim())
        else
            @model.set 'tags', _.escape($(e.target).text()?.trim())
        if @model.hasChanged()
          @model.save()
        return false

    clearEntry: (e) =>
        #console.log 'clear entry'
        @model.destroy()

    removeTag: (e) =>
        #console.log 'unset tag', @model.get 'tags'
        @model.set('tags', '')
        @model.save()
        @

    addTag: (e) =>
        _tag = prompt "Enter a tag"
        if _tag?
            @model.set 'tags', _tag.trim()
            @model.save()
        @

    editEntry: ->
        @

class NewEntryView extends Backbone.View
    tagName: 'dl'
    id: 'new'
    template: _.template("""
        <span class="save-model pull-right" data-toggle="tooltip"
            title="Save entry" data-placement="right">&#x2714;</span>
        <dt contenteditable><%= fmtDate  %></dt>
            <dd contenteditable class="text"><%= text %></dd>
            <% if (tags) { %>
                <span class="delete-tag" data-toggle="tooltip" title="Remove Tag">&nbsp;&#x2717;&nbsp;</span>
                <dd contenteditable class="badge tag" title="Edit Tag"
                        data-placement="right" data-toggle="tooltip"><%= tags %></dd>
            <% } else {%>
                <span class="badge alert-success" title="Add Tag" data-placement="right"
                    data-toggle="tooltip">&#x271b;</span><%} %>""")

    initialize: ->
        #console.log "NewEntryView initialized, this.$el", @$el
        @model = new Entry
        @listenTo @model, 'change', @render
        @listenTo @model, 'destroy', @close
        @

    onClose: ->
        @model.unbind()

    render: ->
        fields = @model.toJSON()
        fields.fmtDate = entryDateFmt @model.get('date')
        @$el.html(@template(fields))
        @$("[data-toggle=tooltip]").tooltip()
        @
    events:
        "click .save-model": "saveModel"
        "click .delete-tag": "removeTag"
        "click span.badge": "addTag"
        "focusout dd": "updateInfo"
        "focusout dt": "updateDate"

    removeTag: (e) =>
        @model.set('tags', '')
        @

    addTag: (e) =>
        _tag = prompt "Enter a tag"
        if _tag?
            @model.set 'tags', _tag.trim()
        @

    updateDate:(e) =>
        _text = $(e.target).text()?.trim()
        _text = _text.split(' - ')
        _d = new Date
        _d.setMonth (+getMonth(_text[0]) - 1)
        _d.setDate +_text[1]
        if isNaN _d
        # bad input date
           @render()
           return @
        _d.setHours 0
        _d.setMinutes 0
        _d.setSeconds 0
        _d.setMilliseconds 0
        if @model.get('date') != _d.getTime()
           @model.set 'date', _d.getTime()
        false

    updateInfo: (e) =>
        #console.log 'updateInfo called', arguments
        if $(e.target).hasClass('text')
            if not $(e.target).text()?.trim()
                if confirm "Are you sure you want to purge this log?"
                    @$el.off "blur", "dd", ->
                        #console.log 'removing handler'
                    @model.destroy()
                    return false
            else
                #console.log 'entryview text changed. will set model'
                @model.set 'text', _.escape($(e.target).text()?.trim())
        else
            @model.set 'tags', _.escape($(e.target).text()?.trim())
        return false

    saveModel: ->
        #console.log 'saving model'
        #console.log 'newentryview changedattr', @model.changedAttributes()
        @model.save {
                text: @$('dd.text').text()?.trim()
                tags:  @$('dd.tag').text()?.trim()
            },
            {
             success: =>
                #console.log 'success callback adding', arguments
                window.App.entries.add @model
                App.app_router.navigate '', trigger: true
                false
             error: =>
                #console.error 'ERROR: cannot save', @model.toJSON()
                false
             }
        @

window.App.EntryView = EntryView
