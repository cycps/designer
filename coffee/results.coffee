root = exports ? this

dsg = ""

getParameterByName = (name) =>
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
    regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
    results = regex.exec(location.search)
    decodeURIComponent(results[1].replace(/\+/g, " "))

#Entry point
root.go = ->
    
  dsg = getParameterByName("xp")
  $("#title").html(dsg)
  console.log("do you know the muffin man?")
  ($.get "/addie/"+dsg+"/analyze/rawData", (raw) =>
    console.log("raw data read success")
    console.log(raw)
    g = new Dygraph(
      document.getElementById("theResults"),
      raw,
      {
        strokeWidth: 2,
        labelsDiv: "theLegend",
        labelsSeparateLines: true,
        strokeBorderWidth: 1,
        highlightSeriesOpts: {
          strokeWidth: 3,
          strokeBorderWidth: 1,
          highlightCircleSize: 4,
        }
      }
    )
    true
  ).fail (data) =>
    console.log("raw data read fail " + data.status)


