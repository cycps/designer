user = ""

$(document).ready () =>
  ($.get "/gatekeeper/thisUser", (data) =>
    user = data
    $("#user_ctrl").html(user)
  ).fail () ->
    console.log("fail to get current user, going back to login screen")
    window.location.href = location.origin
    true
