$ ->

  shortcuts =
    "2": "L783461256"
    "3": "330893481"
    "4": "M718460675"

  for key, value of shortcuts
    ( (value) ->
      Mousetrap.bind ["alt+#{key}"], (e) ->
        e.preventDefault() if e.preventDefault
        $(':focus').val value
    )(value)

  Mousetrap.bind ["alt+1"], (e) ->
    window.location = "/"
