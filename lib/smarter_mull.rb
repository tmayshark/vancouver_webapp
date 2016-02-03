require 'awesome_print'
require 'deep_clone'

module Mulligan
  class Deck
    attr_accessor :library
    #deck needs to know how many lands, ramp and low_curve cards it has
    def initialize(params)
      lands = params[:lands]
      ramp = params[:ramp]
      low_curve = params[:low_curve]
      nonland = 100 - lands - ramp - low_curve
      @library = []
      lands.times do
        @library.push 'land'
      end

      ramp.times do
        @library.push 'ramp'
      end

      low_curve.times do
        @library.push('low_curve')
      end

      nonland.times do
        @library.push 'nonland'
      end

    end

    def mash_shuffle
      @library.shuffle!
    end

    def draw
      @library.pop
    end

    def print
      puts @library.size
      ap @library
    end
  end

  def keepable_hand(hand)
    keepable = false
    if hand.count('land') >= 3 && hand.count('land') <= 4 && hand.size > 5
      keepable = true
    elsif hand.count('land') >= 3 && hand.count('low_curve') >= 1 && hand.size >= 5
      keepable = true
    elsif hand.count('land') >= 2 && hand.count('ramp') >= 1 && hand.size >= 5
      keepable = true
    end
    keepable
  end

  #to draw and mull, we need a deck
  def draw_and_mull(deck)
    # set mulls to 0
    mull_count = 0

    # draw initial hand
    deck.mash_shuffle
    hand = []
    7.times do
      hand.push(deck.draw)
    end
    keep_hand = keepable_hand(hand)

    until (keep_hand == true || mull_count == 4)
      hand = []
      draw_count = 7 - mull_count
      draw_count.times do
        hand.push(deck.draw)
      end
      keep_hand = keepable_hand(hand)
      mull_count += 1
    end
    { keepable: keep_hand, cards: hand.size}
  end

  class IterativeSimulation
    include Mulligan
    attr_reader :master_deck, :iterations
    attr_accessor :results
    def initialize(itr, deck_params)
      @iterations = itr
      @master_deck = Deck.new(deck_params)
      @results = []
      perform_loop(@iterations)
    end

    def display_deck
      @master_deck.print
    end

    def perform_loop(iterations)
      iterations.times do
        deck = DeepClone.clone(@master_deck)
        res = draw_and_mull(deck)
        @results.push(res)
      end
    end

    def stats
      kept_hands = 0
      total_cards_in_kept = 0
      @results.each do |result|
        if result[:keepable] == true
          kept_hands += 1
          total_cards_in_kept += result[:cards]
        end
      end
      kept_percentage = (kept_hands.to_f / iterations.to_f * 100).round(4)
      cards_in_kept_average = (total_cards_in_kept / kept_hands.to_f).round(2)
      { percent_kept: kept_percentage, kept_cards: cards_in_kept_average }
    end
  end

  class VariableCountSim
    attr_accessor :stats

    def initialize(itr, ramp, low_curve)
      collected_results = []
      land_count = 20
      if itr > 50000
        itr = 50000
      end

      if itr < 100
        itr = 100
      end

      while land_count < 43 do
        params = {lands: land_count, ramp: ramp, low_curve: low_curve}
        sim = IterativeSimulation.new(itr, params)
        land_count += 1
        run_stats = sim.stats
        collected_results.push({land_count: land_count, stats: run_stats})
      end

      @stats = collected_results
    end

    def results
      @stats
    end
  end
end