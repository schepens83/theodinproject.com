require 'spec_helper'

# silence the to be tested program. ie no output to stderr or stdout. 
RSpec.configure do |config|
  original_stderr = $stderr
  original_stdout = $stdout
  config.before(:all) do
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end
  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end

describe "Game" do
  before :each do
    @game = Game.new(ConnectFour.new)
  end

  describe "#new" do

    it "creates 2 players" do
      player1 = @game.current_player.next
      player2 = @game.current_player.next
      player3 = @game.current_player.next
      expect( player1 != player2 && player1 == player3 )
    end
    it { expect( @game.current_player.next ).to be_a Player }

    it "has a game type" do
      expect(@game.game).to be_a ConnectFour
    end
  end
end

describe "Player" do
  before :each do
    @player = Player.new("Clint")
  end
  
  describe "#new" do
    it { expect(@player.symbol).to be_a String }
    it { expect(@player.symbol).to eq("Clint") }  
  end
end

describe "ConnectFour" do
  let(:game) {ConnectFour.new }

  describe "#new" do
    it "has a board" do
      expect(game.board).to be_a Hash
    end
    
    it "creates a board of 6 horizontal and 7 vertical" do
      expect{ game.board.to include?([1,1], [6,7], [1,7], [6,1]) }
    end
  end
  
  describe "#make_move" do
                                                            
    it "validates player input" do
      expect(game.make_move("test")).to match(/invalid input/)
    end
  end

  # describe "create_board" do
  #   it "has 7 * 6 empty signs" do
  #     expect(game.board.to_s.scan(/#{game.empty_sign}/).length).to be(7 * 6)
  #   end
  # end
  
  
  describe "#full_column" do
    let(:empty) { ConnectFour.new }
    let(:full) { ConnectFour.new }
    let(:halffull) { ConnectFour.new }

    before :each do
      (1..7).to_a.each {|i| empty.board[[1,i]] = empty.empty_sign }
      (1..7).to_a.each {|i| full.board[[1,i]] = "\u24C5" }
      (1..3).to_a.each {|i| halffull.board[[1,i]] = "\u24C5" }
    end

    it "returns true when full" do
      expect(full.send(:full_column, 1)).to be true #use send for private methods.
    end

    it "returns false when empty" do
      expect(empty.send(:full_column, 1)).to be false
    end

    it "returns false when half full" do
      expect(halffull.send(:full_column, 1)).to be false
    end
  end

  describe "#drop_chip" do
    let(:player) { double }

    before :each do
      allow(player).to receive(:symbol).and_return("t")
    end

    it "adds a chip to the column" do
      before = game.board.to_s
      game.send(:drop_chip, 1, player)
      after = game.board.to_s
      expect(after.scan(/#{game.empty_sign}/).length < before.scan(/#{game.empty_sign}/).length)
    end

    it "fills from bottom" do
      game.send(:drop_chip, 1, player)
      expect( game.board[[1,6]] ).not_to be(game.board[[1,5]])
    end
  end

  describe "#print_game_status" do
    let(:player) { double }

    before :each do
      allow(player).to receive(:symbol).and_return("t")
    end

    it "should have borders" do
      print = game.print_game_status
      expect(print).to include("--") && include("==")
    end

    it "should have both player and empty sign" do
      game.send(:drop_chip, 1, player)
      print = game.print_game_status
      expect(print).to include(game.empty_sign) && include(player.symbol)
    end
  end

  describe "#print_winner" do
    
    let(:player) { Player.new("t") }
    let(:player2) { Player.new("s") }
    
    context "there is a winner" do
      it "to return the winning player" do
        game.send(:drop_chip, 1, player)
        game.send(:drop_chip, 1, player)
        game.send(:drop_chip, 1, player)
        game.send(:drop_chip, 1, player)
        expect(game.print_winner([player, player2])).to eq("Player #{player.symbol} wins")
      end
    end

    context "there is no winner" do
      it "to be a string" do
        expect(game.print_winner([player, player2])).to be_a(String)
      end

      it "to return no winner" do
        expect(game.print_winner([player, player2])).to eq("no winner")
      end
    end

  end
  
  describe "#winner?" do
    let(:player) { double }
    let(:player2) { double }
    let(:game_no_winner) { ConnectFour.new }
    let(:game_winner_hor) { ConnectFour.new }
    let(:game_winner_vert) { ConnectFour.new }
    let(:game_winner_diag) { ConnectFour.new }
    let(:game_almost_winner) { ConnectFour.new }

    before :each do
      allow(player).to receive(:symbol).and_return("t")
      allow(player2).to receive(:symbol).and_return("s")
    end
    
    context "when no winner" do
      it "returns false" do
        expect(game_no_winner.winner?).to be false
      end
    end
    
    context "when horizontal winner" do
      it "returns true" do
        game_winner_hor.send(:drop_chip, 1, player)
        game_winner_hor.send(:drop_chip, 2, player)
        game_winner_hor.send(:drop_chip, 3, player)
        game_winner_hor.send(:drop_chip, 4, player)
        expect(game_winner_hor.winner?).to be true
      end
    end

    context "when vertical winner" do
      it "returns true" do
        game_winner_hor.send(:drop_chip, 1, player)
        game_winner_hor.send(:drop_chip, 1, player)
        game_winner_hor.send(:drop_chip, 1, player)
        game_winner_hor.send(:drop_chip, 1, player)
        expect(game_winner_hor.winner?).to be true
      end
    end

    context "when diagonal winner" do
      it "returns true if bottom left to top right is a row" do
        game_winner_diag.send(:drop_chip, 1, player)
        game_winner_diag.send(:drop_chip, 2, player2)
        game_winner_diag.send(:drop_chip, 2, player)
        game_winner_diag.send(:drop_chip, 3, player2)
        game_winner_diag.send(:drop_chip, 3, player2)
        game_winner_diag.send(:drop_chip, 3, player)
        game_winner_diag.send(:drop_chip, 4, player2)
        game_winner_diag.send(:drop_chip, 4, player2)
        game_winner_diag.send(:drop_chip, 4, player2)
        game_winner_diag.send(:drop_chip, 4, player)
        expect(game_winner_diag.winner?).to be true
      end

       it "returns true if top left to bottom right is a row" do
        game_winner_diag.send(:drop_chip, 4, player)
        game_winner_diag.send(:drop_chip, 3, player2)
        game_winner_diag.send(:drop_chip, 3, player)
        game_winner_diag.send(:drop_chip, 2, player2)
        game_winner_diag.send(:drop_chip, 2, player2)
        game_winner_diag.send(:drop_chip, 2, player)
        game_winner_diag.send(:drop_chip, 1, player2)
        game_winner_diag.send(:drop_chip, 1, player2)
        game_winner_diag.send(:drop_chip, 1, player2)
        game_winner_diag.send(:drop_chip, 1, player)
        expect(game_winner_diag.winner?).to be true
      end
    end

    context "almost a winner" do
      it "returns false" do
        game_winner_hor.send(:drop_chip, 1, player)
        game_winner_hor.send(:drop_chip, 1, player)
        game_winner_hor.send(:drop_chip, 1, player)
        expect(game_winner_hor.winner?).to be false
      end
    end
  end
end
