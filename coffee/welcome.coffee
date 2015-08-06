
$(document).ready () =>

  $("#login_form").submit (event) ->
    event.preventDefault()

    ($.post "/gatekeeper/login", $(this).serialize(), (data) =>
      console.log("login success")
      window.location.href = window.location + "user.html"
      
    ).fail () ->
      console.log("login failed")
      $("#login_msg").html(
        "<span style='color: white'> Access Denied </span>"
      )

    true
