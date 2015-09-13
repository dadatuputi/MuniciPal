$ ->

  shortcuts =
    "2": "L783461256"
    "3": "330893481"
    "4": "M718460675"
    "5": "6185798636"

  len = 1
  interval = null
  $el = null
  typeItValue = null
  timeout = 35

  typeIt = ->
    $el.val typeItValue.substr(0, len)
    len = len + 1
    if interval and len > typeItValue.length
      $el.focus()
      console.log("clear interval")
      window.clearInterval(interval)

  for key, value of shortcuts
    ( (value) ->
      Mousetrap.bind ["alt+#{key}"], (e) ->
        e.preventDefault() if e.preventDefault
        $el = $("input[name=q], input[type=tel]")
        typeItValue = value
        len = 1
        interval = window.setInterval(typeIt, timeout)
    )(value)

  Mousetrap.bind ["alt+1"], (e) ->
    Turbolinks.visit "/"
