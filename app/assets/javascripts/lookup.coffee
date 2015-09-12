@Lookup =
  render: ->
    $("#lookup-form").submit (e)->
      e.preventDefault()
      form = $(this)
      url = form.attr("action")
      data = form.serialize()

      $.post(url, data)
        .done (data)->
          return window.location.href = data.location if data.ok is "true"

          removeErrorClass = ->
            $("#lookup-form").removeClass("has-error")

          form = $("#lookup-form")

          form.addClass("has-error")
          setTimeout(removeErrorClass, 1500)
          $("#search-error-message").html data.message
