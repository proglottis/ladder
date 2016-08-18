initHistoryGraph = (id, url)->
  d3.json(url, (data) ->

    nv.addGraph(->
      chart = nv.models.lineChart().
        x((d) -> new Date(d.period_at)).
        y((d) -> d.rating - 2.0 * d.rating_deviation).
        color(d3.scale.category10().range())
      chart.useInteractiveGuideline(true)

      chart.xAxis.tickFormat((d) -> d3.time.format("%x")(new Date(d)))
      chart.yAxis.tickFormat(d3.format(".0f"))

      d3.select("#" + id + " svg.plot").
        datum(data).
        transition().duration(500).call(chart)
      nv.utils.windowResize(->
        chart.update()
      )
      chart
    )
  )

initHistoryGraphs = ->
  $('.player').each(() ->
    initHistoryGraph(@id, $("svg.plot", this).data("url"))
  )

$(document).on 'turbolinks:load', initHistoryGraphs
