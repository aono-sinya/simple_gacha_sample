require 'csv'

module Gacha
  class Main
    def self.execute
      first_deck = RarityDeck.new('rarity.csv')
      second_deck = CardDeck.new('card.csv', first_deck.lot.id)
      return second_deck.lot
    end
  end

  class RarityDeck
    def initialize(file_name)
      @file_name = file_name
    end
  
    def data
      base = CSV.read(@file_name)
      data = base.map{|b| Rarity.new(*b)}
      return data
    end
  
    def lot
      data = self.data.sort{|a, b| a.wait <=> b.wait}
      sum = self.data.inject(0.0){|s, d| s += d.wait}
      r = rand(0 ... sum)
      res = self.data.inject(0) do |s, d|
        s += d.wait
        if s > r
          break d
        end
        s
      end
      return res
    end
  end

  class Rarity
    attr_reader :id, :name, :wait
    def initialize(id, name, wait)
      @id = id.to_i
      @name = name
      @wait = wait.to_i
    end
  end

  class CardDeck
    def initialize(file_name, rarity_id)
      @file_name = file_name
      @rarity_id = rarity_id
    end

    def data
      base = CSV.read(@file_name)
      data = base.map{|b| Card.new(*b)}
      data = data.select{|d| d.rarity_id == @rarity_id}
      return data
    end

    def lot
      return data.sample
    end
  end

  class Card
    attr_reader :id, :rarity_id, :name
    def initialize(id, rarity_id, name)
      @id = id.to_i
      @rarity_id = rarity_id.to_i
      @name = name
    end
  end
end

10.times do
  card = Gacha::Main.execute
  puts card.name
end
