require 'awesome_print'

module Mulligan
  class Deck
    attr_accessor :land_count, :nonland_count, :ramp_count, :low_curve_count, :hand, :deck
    def initialize(params)
      @land_count = params[:land_count]
      @ramp_count = params[:ramp_count]
      @low_curve_count = params[:low_curve_count]
      @nonland_count = 100 - @land_count - @ramp_count - @low_curve_count
      @deck = []
      @land_count.times do
        @deck.push 'land'
      end

      @ramp_count.times do
        @deck.push 'ramp'
      end

      @low_curve_count.times do
        @deck.push('low_curve')
      end

      @nonland_count.times do
        @deck.push 'nonland'
      end

      puts "deck size: #{@deck.size}"
      @deck.shuffle!
      @hand = []
    end

    def show_deck
      ap @deck
    end

    def show_hand
      ap @hand
    end

    def draw
      @hand.push(@deck.pop)
    end

    def dump_hand
      @hand = []
    end

    def cards_in_hand
      @hand.size
    end

    #we define keepable as 4 or more cards with at least 3 lands
    def keepable_hand
      keepable = false
      if @hand.count('land') >= 3 && @hand.count('land') <= 4 && @hand.size > 5
        keepable = true
      elsif
      @hand.count('land') >= 3 && @hand.count('low_curve') >= 1 && @hand.size >= 5
        keepable = true
      elsif
      @hand.count('land') >= 2 && @hand.count('ramp') >= 1 && @hand.size >= 5
      end
      keepable
    end
  end

  class Mulligan
    attr_accessor :mulligan_count, :keepable
    def initialize(params = {:land_count=>35, :ramp_count=>5, :low_curve_count=>10})
      @mulligan_count = 0
      @deck = Deck.new(params)
      @keepable = false
      self.run
      self.results
    end

    def check_hand
      if @deck.keepable_hand
        @keepable = true
      end
    end

    def results
      {keepable: @keepable, cards: @deck.cards_in_hand }
    end

    def run
      7.times do
        @deck.draw
      end

      check_hand

      until @keepable == true || @mulligan_count == 4
        @deck.dump_hand
        draw_count = 7 - @mulligan_count
        draw_count.times do
          @deck.draw
        end

        check_hand
        @mulligan_count += 1
      end
    end
  end

  class Simulator
    attr_accessor :results
    def initialize(iterations, deck_params)
      @results = {keepable: 0}
      iterations.times do
        run = Mulligan.new(deck_params)
        if run.results[:keepable] == true
          @results[:keepable] += 1
        end
      end
    end

    def result
      @results
    end

  end

  class IterativeSimulator
    attr_accessor :land_count, :iterations, :result, :params
    def initialize(iterations, params)
      @results = []
      @params = params
      @iterations = iterations
      initial_land_count = 25
      @land_count = initial_land_count
      run
    end

    def run
      while @land_count < 42 do
        params = {:land_count=>@land_count, :ramp_count=>@params[:ramp_count], :low_curve_count=>@params[:low_curve_count]}
        loop = Simulator.new(@iterations, params)
        res = loop.result
        @results.push("With #{@land_count} lands, #{res[:keepable]} keepable hands == #{res[:keepable].to_f / @iterations.to_f * 100}%")
        @land_count += 1
      end
    end

    def results
      @results
    end
  end
end
