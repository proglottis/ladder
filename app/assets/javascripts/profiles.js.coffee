jQuery ->
  percentageFormatter = (x) -> x * 100.0 + "%"

  $('.tournament.plot').each (i, element) ->
    element_id = $(element).attr('id')
    data = $.parseJSON($(element).attr('data-ratings'))
    options = {
      series: {
        lines: { show: true }
      },
      yaxis: {
        min: 0.0,
        max: 0.0,
        tickFormatter: percentageFormatter
      },
      xaxis: {
        min: 500.0,
        max: 3000.0
      }
    }
    plot_data = $.map(data, (rating, i) ->
      distribution = new NormalDistribution(rating['rating'], rating['rating_deviation'])
      range = distribution.getRange()
      range_points = range.getPoints()
      options.xaxis.min = Math.min(options.xaxis.min, range_points[0])
      options.xaxis.max = Math.max(options.xaxis.max, range_points[range_points.length - 1])
      pdfs = distribution.density(range)
      options.yaxis.max = Math.max(options.yaxis.max, jstat.max(pdfs) * 1.1)
      data = []
      $.each(pdfs, (i) ->
        data.push([range_points[i], pdfs[i]])
      )
      return {
        data: data,
        hoverable: true,
        clickable: false,
        label: rating['user_name']
      }
    )
    plot = new Plot(element_id + ' .plot', options)
    plot.setData(plot_data)
    plot.render()
