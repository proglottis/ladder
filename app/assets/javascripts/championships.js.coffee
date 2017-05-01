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
  g = new dagreD3.graphlib.Graph()
  g.setGraph({
    rankdir: "LR",
  })
  g.setDefaultEdgeLabel(-> {})

  $.get(url).success (bracket)->
    for match in bracket
      presenter = new MatchPresenter(match)
      g.setNode("match_#{match.id}", labelType: "html", label: presenter.match_tag(), width: 150)

    for match in bracket
      if match.winners_match_id
        g.setEdge("match_#{match.id}", "match_#{match.winners_match_id}")

    render = new dagreD3.render()
    render(d3.select("##{id} g"), g)

    bbox = d3.select("##{id}").node().children[0].getBBox()
    d3.select("##{id}")
      .attr("viewBox", "0 0 " + (bbox.width + 40) + " " + (bbox.height + 40))
      .attr("preserveAspectRatio", "xMinYMin meet")

initChampionshipGraphs = ->
  $('.championships svg.bracket').each ->
    initChampionshipGraph(@id, $(@).data('url'))

$(document).on 'turbolinks:load', initChampionshipGraphs
