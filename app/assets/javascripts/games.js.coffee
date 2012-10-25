jQuery ->
  $game_ranks = $('#game_ranks')
  $game_ranks.sortable
    axis: 'y'
    update: (event, ui) ->
      $game_ranks.children('li').each (index, item) ->
        $(item).children('input[name*=position]').val(index + 1)
