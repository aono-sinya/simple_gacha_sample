require 'csv'

module Gacha
  class Main
    def self.execute
      rarity_deck = RarityDeck.new('rarity.csv')
      lotter = rarity_deck.lot
      card_deck = CardDeck.new('card.csv', lotter.rarity_id, lotter.is_pickup)
      return card_deck.lot
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
      i = 0.0
      lots = data.product([1, 0]).map{|a|
        l = Gacha::Lotter.new(i, i + a[0].wait(a[1]), a[0].id, a[1])
        i +=  a[0].wait(a[1])
        l
      }
      r = rand * 100
      return lots.find{|a| r > a.from && r <= a.to}
    end
  end

  class Rarity
    attr_reader :id, :name, :base_wait, :pickup_wait, :pickup_count
    def initialize(id, name, base_wait, pickup_wait, pickup_count)
      @id = id.to_i
      @name = name
      @base_wait = base_wait.to_f
      @pickup_wait = pickup_wait.to_f
      @pickup_count = pickup_count.to_i
    end

    def wait(is_pickup)
      if is_pickup > 0
        return @pickup_wait * @pickup_count
      else
        return @base_wait - (@pickup_wait * @pickup_count)
      end
    end
  end

  class CardDeck
    def initialize(file_name, rarity_id, is_pickup)
      @file_name = file_name
      @rarity_id = rarity_id
      @is_pickup = is_pickup.to_i > 0
    end

    def data
      base = CSV.read(@file_name)
      data = base.map{|b| Card.new(*b)}
      data = data.select{|d| d.rarity_id == @rarity_id && d.is_pickup == @is_pickup}
      return data
    end

    def lot
      return data.sample
    end
  end

  class Card
    attr_reader :id, :rarity_id, :is_pickup, :name
    def initialize(id, rarity_id, is_pickup, name)
      @id = id.to_i
      @rarity_id = rarity_id.to_i
      @is_pickup = is_pickup.to_i > 0
      @name = name
    end
  end

  class Lotter
    attr_reader :from, :to, :rarity_id, :is_pickup
    def initialize(from, to, rarity_id, is_pickup)
      @from = from
      @to = to
      @rarity_id = rarity_id
      @is_pickup = is_pickup
    end
  end
end

100.times do
  card = Gacha::Main.execute
  puts card.name
end
