class PlayerPresenter
  constructor: (@player) ->

  name: ->
    @player.name || "TBA"

  image_tag: ->
    if @player.image_url
      "<img width=\"16\" height=\"16\" src=\"#{@player.image_url}\"/>"
    else
      ""

  profile_tag: ->
    "<b>#{@image_tag()}#{@name()}</b>"

class MatchPresenter
  constructor: (@match) ->

  match_tag: ->
    player1 = new PlayerPresenter(@match.player1)
    player2 = new PlayerPresenter(@match.player2)
    "#{player1.profile_tag()}<br>vs<br>#{player2.profile_tag()}"

initChampionshipGraph = (id, url) ->
  g = new dagreD3.Digraph()

  $.get(url).success (bracket)->
    for match in bracket
      presenter = new MatchPresenter(match)
      g.addNode("match_#{match.id}", label: presenter.match_tag(), width: 200)

    for match in bracket
      if match.winners_match_id
        g.addEdge(null, "match_#{match.id}", "match_#{match.winners_match_id}")

    layout = dagreD3.layout().rankDir("LR")

    renderer = new dagreD3.Renderer().layout(layout)
    renderer.run(g, d3.select("##{id} g"))

    bbox = d3.select("##{id}").node().children[0].getBBox()
    d3.select("##{id}")
      .attr("height", bbox.height + 40)
      .attr("width", bbox.width + 40)
      .attr("viewBox", "0 0 " + (bbox.width + 40) + " " + (bbox.height + 40))
      .attr("preserveAspectRatio", "xMinYMin meet")

initChampionshipGraphs = ->
  $('.championships svg.bracket').each ->
    initChampionshipGraph(@id, $(@).data('url'))

jQuery -> initChampionshipGraphs()
$(document).on 'page:load', initChampionshipGraphs
