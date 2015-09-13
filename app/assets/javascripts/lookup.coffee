@Lookup =
  handleResponse: (data) ->
    return Lookup.validateBirthday(data) if data.ok is "validate"
    return Turbolinks.visit data.location if data.ok is "true"
    return Lookup.revert() if data.ok is "invalid"

    removeErrorClass = ->
      $("#lookup-form").removeClass("has-error")

    form = $("#lookup-form")

    form.addClass("has-error")
    setTimeout(removeErrorClass, 1500)
    $("#search-error-message").html data.message

  render: ->
    $("#lookup-form").submit (e)->
      e.preventDefault()
      $form = $(this)
      url = $form.attr("action")
      data = $form.serialize()
      $.post(url, data).done(Lookup.handleResponse)

  validateBirthday: (data) ->
    $("#instructions").html "#{data.name}, please confirm your birthday"
    $("#lookup-form").html """
        <input type="hidden" name="id" value="#{data.id}">
        <input type="date" id="walkthrough_birthday" name="birthday" class="form-control">
        <span class="input-group-btn">
          <button id="walkthrough_confirm_birthday" class="btn btn-lg btn-primary" type="submit">Go!</button>
        </span>
      """
    $("#lookup-form").attr "action", "/walkthrough/confirm_birthday"
    $("#lookup-form").find("#walkthrough_birthday").focus()

  revert: ->
    $("#instructions").html "Type your citation number, drivers license, or name"
    $("#lookup-form").html """
      <input type="text" name="q" class="form-control mousetrap" placeholder="398814619 / L814561589 / John Smith">
      <span class="input-group-btn">
        <button id="walkthrough-search-submit" class="btn btn-lg btn-primary" type="submit">Go!</button>
      </span>
      """
    $("#lookup-form").attr "action", "/walkthrough/search"
    $("#lookup-form").find("input[name=q]").focus()
