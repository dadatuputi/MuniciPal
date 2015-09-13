@Reminder =
  render: ->
    $("#sms-reminder-form").submit (e)->
      e.preventDefault()
      $("#reminder-button").attr("disabled", true)
      form = $(this)
      url = form.attr("action")
      data = form.serialize()

      $.post(url, data)
        .done (data)->
          removeResponseClass = ->
            form = $("#sms-reminder-form")
            form.removeClass("has-error") if form.has("has-error")
            form.removeClass("has-success") if form.has("has-success")

          $("#reminder-button").attr("disabled", false)
          form = $("#sms-reminder-form")
          form.find("input[type=tel]").val("")
          if data.ok is "false"
            form.addClass("has-error")
            setTimeout(removeResponseClass, 1500)
          else
            form.addClass("has-success")
            setTimeout(removeResponseClass, 1500)

          $("#sms-message").html data.message
