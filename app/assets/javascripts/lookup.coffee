@Lookup =
  render: ->
    $("#lookup-form").submit (e)->
      e.preventDefault()
      form = $(this)
      url = form.attr("action")
      data = form.serialize()

      $.post(url, data)
        .done (data)->
          return Lookup.validateBirthday(data) if data.ok is "validate"
          return Turbolinks.visit data.location if data.ok is "true"

          removeErrorClass = ->
            $("#lookup-form").removeClass("has-error")

          form = $("#lookup-form")

          form.addClass("has-error")
          setTimeout(removeErrorClass, 1500)
          $("#search-error-message").html data.message

  validateBirthday: (data) ->
    # console.log("id", data.id)
    # console.log("birthday", data.birthday)
    # console.log("name", data.name)

    revertHtml = $("#lookup-form").html()
    revertInstructions = $("#instructions").html()

    $("#instructions").html "#{data.name}, please confirm your birthday"
    $("#lookup-form").html """
        <input type="hidden" name="id" value="#{data.id}">
        <input type="date" id="walkthrough_birthday" name="birthday" class="form-control">
        <span class="input-group-btn">
          <button id="walkthrough_confirm_birthday" class="btn btn-lg btn-primary" type="submit">Go!</button>
        </span>
      """

      # .submit (e) ->
      #   console.log 'val', $('#walkthrough_birthday')
      #   if $('#walkthrough_birthday') is data.birthday
      #     $('input[name=id]').val(data.id)
      #   else
      #     e.preventDefault()
      #     e.stopImmediatePropagation()
      #     $("#instructions").html revertInstructions
      #     $("#lookup-form").html revertHtml

      .find("#walkthrough_birthday")
      .focus()
