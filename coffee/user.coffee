root = exports ? this

user = ""

thisUser = () =>
  ($.get "/gatekeeper/thisUser", (data) =>
    user = data
    $("#user_ctrl").html(user)
    loadUserDesigns()
  ).fail () ->
    console.log("fail to get current user, going back to login screen")
    window.location.href = location.origin
    true

onFail = (data) =>
  if data.status >= 400
    $("#messages").html(
      "There was a server error<br />"+
      "<span class='suplimental_info'>cypress@deterlab.net has been notified<span>")
    reportServerError(data.status)
  else
    $("#messages").html(
      "Failed to create experiment<br />"+
      "<span class='suplimental_info'>cypress@deterlab.net has been notified<span>")
    reportServerError(data.status)

doLoadDesigns = (ps) =>
  for p in ps
    $("#experiments").append(
      "<div class='xp' id"+p+" onclick=goDesign('"+p+"')>"+p+"</div>"
    )

loadUserDesigns = () =>
  ($.get "/gatekeeper/myDesigns", (data) =>
    console.log(data)
    if data.designs?
      doLoadDesigns(data.designs)
  ).fail (data) =>
    onFail(data)

newXP = () =>
  console.log("newXP")
  $("#new_xp")
    .attr("contenteditable", "true")
    .addClass("exp_new_editing")
    .attr("onkeydown", "newExpKeyPrH(event)")

validateName = (xpname) =>
  validName = /^[$A-Z_][0-9A-Z_$]*$/i
  isValid = validName.test(xpname)
  if !isValid
    $("#messages").html("Invalid Experiment Name")
  else
    $("#messages").html("")
  isValid

root.goDesign = (xpname) =>
  console.log("Going to design "+xpname+" ... ")
  window.location.href = window.location.origin + "/design.html?xp="+xpname

reportServerError = (code) =>
  console.log("Reporting server error " + code)

root.newExpKeyPrH = (evt) =>
    x = evt.which || evt.keyCode
    if x == 13
      evt.preventDefault()
      node = $("#new_xp")
      expname = node[0].innerHTML.trim()
      expname = expname.replace("<br>", "")
      validName = validateName(expname)

      if validName
        ($.post "/gatekeeper/newXP", JSON.stringify({name: expname}), (data) =>
          console.log("newXP success")
          goDesign(expname)
        ).fail (data) =>
          onFail(data)


$(document).ready () =>
  thisUser()

  $("#new_xp").click newXP
