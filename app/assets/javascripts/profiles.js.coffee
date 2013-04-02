$('.tournament.plot').each (index, element) ->
  container = $(element)
  chart_element = container.children('.chart').get(0)
  y_axis_element = container.children('.y_axis').get(0)
  legend_element = container.children('.legend').get(0)
  palette = new Rickshaw.Color.Palette
  ajax_graph = new Rickshaw.Graph.Ajax({
    element: chart_element
    width: 300
    height: 100
    min: 800
    renderer: 'line'
    dataURL: container.data('url')
    onData: (d) ->
      for series in d
        series.color = palette.color()
        series.data = for point in series.data
          {
            x: Date.parse(point.period_at) / 1000.0
            y: Math.round(parseFloat(point.rating) - 2.0 * parseFloat(point.rating_deviation))
          }
        series
    onComplete: ->
      x_axis = new Rickshaw.Graph.Axis.Time
        graph: @graph
      y_axis = new Rickshaw.Graph.Axis.Y
        graph: @graph
        orientation: 'left'
        element: y_axis_element
      hover_detail = new Rickshaw.Graph.HoverDetail
        graph: @graph
        xFormatter: (x) ->
          new Date(x * 1000).toString()
        yFormatter: (y) ->
          y.toFixed(0)
      @graph.update()
  })
