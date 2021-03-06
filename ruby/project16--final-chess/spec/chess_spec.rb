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

describe "Board" do   let(:board) { Board.new }

	describe "#create_positions" do
		it "has 64 positions" do
			expect(board.position.length).to be(64)
		end

		it "has 32 pieces" do
			expect(board.position.select {|k,v| v != nil }.length).to be(32)
		end

		it "has 16 pawns" do
			expect(board.position.select {|k,v| v != nil }.select { |k,v| v.type == :pawn }.length).to be(16)
		end
	end


	describe "#print_positions" do
		it "has 8 white pawns" do
			expect(board.print_positions.scan(/\u2659/).length).to be(8) 
		end

		it "has 8 black pawns" do
			expect(board.print_positions.scan(/\u265F/).length).to be(8) 
		end

		it "has 1 white and 1 black king" do
			expect(board.print_positions.scan(/\u2654/).length).to be(1)
			expect(board.print_positions.scan(/\u265A/).length).to be(1)
		end

		it "has 1 white and 1 black queen" do
			expect(board.print_positions.scan(/\u2655/).length).to be(1)
			expect(board.print_positions.scan(/\u265B/).length).to be(1)
		end

		it "has 2 white and 2 black knights" do
			expect(board.print_positions.scan(/\u2658/).length).to be(2)
			expect(board.print_positions.scan(/\u265E/).length).to be(2)
		end

		it "has 2 white and 2 black rooks" do
			expect(board.print_positions.scan(/\u2656/).length).to be(2)
			expect(board.print_positions.scan(/\u265C/).length).to be(2)
		end

		it "has 2 white and 2 black bishops" do
			expect(board.print_positions.scan(/\u2657/).length).to be(2)
			expect(board.print_positions.scan(/\u265D/).length).to be(2)
		end
	end
end

describe "Chess" do
	let(:game) { Chess.new([], printout = true, simulated_game = false) }

	# test if all chess pieces that should be on the board are printed out to the user
	def pieces_present(nr_pawn, nr_king, nr_queen, nr_rook, nr_bishop, nr_knight)
		# it "has #{nr_pawn} white pawns" do
			expect(game.board.print_positions.scan(/\u2659/).length + game.board.print_positions.scan(/\u265F/).length).to be(nr_pawn) 
		
		# it "has #{nr_king} king(s)" do
			expect(game.board.print_positions.scan(/\u2654/).length + game.board.print_positions.scan(/\u265A/).length).to be(nr_king)

		# it "has #{nr_queen} queen(s)" do
			expect(game.board.print_positions.scan(/\u2655/).length + game.board.print_positions.scan(/\u265B/).length).to be(nr_queen)

		# it "has #{nr_knight} knight(s)" do
			expect(game.board.print_positions.scan(/\u2658/).length + game.board.print_positions.scan(/\u265E/).length).to be(nr_knight)

		# it "has #{nr_rook} rook(s)" do
			expect(game.board.print_positions.scan(/\u2656/).length + game.board.print_positions.scan(/\u265C/).length).to be(nr_rook)

		# it "has #{nr_bishop} bishop(s)" do
			expect(game.board.print_positions.scan(/\u2657/).length + game.board.print_positions.scan(/\u265D/).length).to be(nr_bishop)
	end

	describe "#make_move" do
		context "for normal chess moves" do
			it "can move a pawn 1 square" do
				args = [[1,2], [1,3], :w]
				game.make_move(args)
				expect(game.board.position[[1,3]].type).to be(:pawn)
				expect(game.board.position[[1,2]]).to be(nil)
				pieces_present(16, 2, 2, 4, 4, 4)
			end

			it "can not move a pawn 3 squares" do
				game.make_move([[1,2], [1,5], :w])
				expect(game.board.position[[1,2]].type).to be(:pawn)
				expect(game.board.position[[1,5]]).to be(nil)
				pieces_present(16, 2, 2, 4, 4, 4)
			end

			it "can not move a pawn vertical on another piece" do
				game.make_move([[1,2], [1,3], :w])
				game.make_move([[1,3], [1,4], :w])
				game.make_move([[1,4], [1,5], :w])
				game.make_move([[1,5], [1,6], :w])
				game.make_move([[1,6], [1,7], :w])
				expect(game.board.position[[1,6]].type).to be(:pawn)
				expect(game.board.position[[1,7]].color).to be(:b)
				pieces_present(16, 2, 2, 4, 4, 4)
			end

			it "can move a knight in all possible directions" do
				game.make_move([[2,1], [1,3], :w])
				game.make_move([[1,3], [3,4], :w])
				game.make_move([[3,4], [5,3], :w])
				game.make_move([[5,3], [6,5], :w])
				game.make_move([[6,5], [7,3], :w]) 
				game.make_move([[7,3], [5,4], :w]) 
				game.make_move([[5,4], [4,6], :w]) 
				game.make_move([[4,6], [3,4], :w]) 
				game.make_move([[3,4], [1,3], :w])                                    
				expect(game.board.position[[1,3]].type).to be(:knight)
				pieces_present(16, 2, 2, 4, 4, 4)
			end

			it "can move a bishop in all possible directions" do
				game.make_move([[4,2], [4,3], :w])
				game.make_move([[3,1], [6,4], :w])
				game.make_move([[6,4], [5,5], :w])         
				game.make_move([[5,5], [4,4], :w])         
				game.make_move([[4,4], [5,3], :w])         
				expect(game.board.position[[5,3]].type).to be(:bishop)
				pieces_present(16, 2, 2, 4, 4, 4)
			end

			it "can move a queen in all possible directions" do
				game.make_move([[5,2], [5,3], :w])
				game.make_move([[5,3], [5,4], :w])         
				# move queen
				game.make_move([[4,1], [5,2], :w])
				game.make_move([[5,2], [5,3], :w])
				game.make_move([[5,3], [7,3], :w])
				game.make_move([[7,3], [8,4], :w])                  
				expect(game.board.position[[8,4]].type).to be(:queen)
				pieces_present(16, 2, 2, 4, 4, 4)
			end

			it "can move a king in all possible directions" do
				game.make_move([[5,2], [5,3], :w])
				game.make_move([[5,3], [5,4], :w])
				game.make_move([[5,4], [5,5], :w])
				game.make_move([[5,5], [5,6], :w])
			   #kings moves
			   game.make_move([[5,1], [5,2], :w])
			   game.make_move([[5,2], [5,3], :w])
			   game.make_move([[5,3], [6,3], :w])
			   game.make_move([[6,3], [6,4], :w])
			   game.make_move([[6,4], [5,4], :w])
			   game.make_move([[5,4], [5,3], :w])
			   game.make_move([[5,3], [6,3], :w])
			   expect(game.board.position[[6,3]].type).to be(:king)
			   pieces_present(16, 2, 2, 4, 4, 4)
			end

			it "can move a rook in all possible directions" do
				game.make_move([[1,2], [1,3], :w])
				game.make_move([[1,3], [1,4], :w])
				game.make_move([[1,4], [1,5], :w])
			   #rook moves
			   game.make_move([[1,1], [1,3], :w])
			   game.make_move([[1,3], [4,3], :w])
			   game.make_move([[4,3], [4,5], :w])
			   game.make_move([[4,5], [3,5], :w])
			   game.make_move([[3,5], [3,3], :w])         
			   expect(game.board.position[[3,3]].type).to be(:rook)
			   pieces_present(16, 2, 2, 4, 4, 4)
			end
		end

		context "for special chess moves" do

			it "can move a pawn 2 squares up or down" do
				game.make_move([[1,2], [1,4], :w])
				game.make_move([[1,7], [1,5], :b])
				expect(game.board.position[[1,4]].type).to be(:pawn)
				expect(game.board.position[[1,5]].type).to be(:pawn)
				pieces_present(16, 2, 2, 4, 4, 4)
			end

			it "can move a pawn en-passant" do
				game.make_move([[1,2], [1,4], :w])
				game.make_move([[2,7], [2,5], :b])
				game.make_move([[2,5], [2,4], :b])
				game.make_move([[1,4], [2,5], :w])
				expect(game.board.position[[2,5]].type).to be(:pawn)
				expect(game.board.position[[2,4]]).to be(nil)
				pieces_present(15, 2, 2, 4, 4, 4)
			end

			it "can take an enemy piece if it is to the left or right and one forward of him" do
				game.make_move([[1,2], [1,4], :w])
				game.make_move([[2,7], [2,5], :b])
				game.make_move([[1,4], [2,5], :w])
				expect(game.board.position[[2,5]].type).to be(:pawn)
				expect(game.board.position[[2,5]].color).to be(:w)
				pieces_present(15, 2, 2, 4, 4, 4)
			end

			it "can switch a king and rook by castling" do
				game.make_move([[5,2], [5,4], :w])
				game.make_move([[6,1], [3,4], :w])
				game.make_move([[7,1], [6,3], :w])
				game.make_move([[5,1], [7,1], :w])				
				expect(game.board.position[[7,1]].type).to be(:king)
				expect(game.board.position[[6,1]].type).to be(:rook)
				pieces_present(16, 2, 2, 4, 4, 4)
			end

			it "can make a pawn into a queen when it reaches the other side" do
				game.make_move([[1,2], [1,4], :w])
				game.make_move([[1,7], [1,5], :b])
				game.make_move([[4,2], [4,4], :w])
				game.make_move([[4,1], [4,2], :w])
				game.make_move([[4,2], [1,5], :w])
				game.make_move([[1,5], [2,5], :w])
				game.make_move([[1,8], [1,5], :b])
				game.make_move([[1,5], [2,5], :b])
				game.make_move([[1,4], [1,5], :w])
				game.make_move([[1,5], [1,6], :w])
				game.make_move([[1,6], [1,7], :w])
				game.make_move([[1,7], [1,8], :w])
				expect(game.board.position[[1,8]].type).to be(:queen)
			end
		end
	end

	describe "#squares_between" do

		it "works with 'to' to the right and top of from" do
			expect(game.send(:squares_between, [3,3], [5,5])).to eql([[4,4]])
		end

		it "works with 'to' to the left and bottom of from" do
			expect(game.send(:squares_between, [3,3], [1,1])).to eql([[2,2]])
		end

		it "works with 'to' to the top of from" do
			expect(game.send(:squares_between, [3,3], [3,7])) =~ ([[3,4], [3,5], [3,6]])
		end

		it "works with 'to' to the bottom of from" do
			expect(game.send(:squares_between, [3,3], [3,1])) =~ ([[3,2]])
		end

		it "works with 'to' to the left of from" do
			expect(game.send(:squares_between, [3,3], [1,3])) =~ ([[2,3]])
		end

		it "works with 'to' to the right of from" do
			expect(game.send(:squares_between, [3,3], [6,3])) =~ ([[4,3], [5,3]])
		end

		it "works with 'to' to the right and bottom of from" do
			expect(game.send(:squares_between, [3,3], [5,1])) =~ ([[4,2]])
		end

		it "works with 'to' to the left and top of from" do
			expect(game.send(:squares_between, [3,3], [1,5])) =~ ([[2,4]])
		end

		it "works with no squares between 'to' and 'from'." do
			expect(game.send(:squares_between, [3,3], [4,4])) =~ ([])
			expect(game.send(:squares_between, [3,3], [3,4])) =~ ([])
			expect(game.send(:squares_between, [3,3], [4,3])) =~ ([])
			expect(game.send(:squares_between, [3,3], [2,3])) =~ ([])
			expect(game.send(:squares_between, [3,3], [2,2])) =~ ([])
			expect(game.send(:squares_between, [3,3], [3,2])) =~ ([])
			expect(game.send(:squares_between, [3,3], [4,2])) =~ ([])
		end
	end

	describe "#check?" do
		context "when game is in check state" do
			it "and it is the white king" do
				game.make_move([[5,2], [5,3], :w])
				game.make_move([[5,3], [5,4], :w])
				game.make_move([[5,4], [5,5], :w])
				game.make_move([[5,5], [5,6], :w])
				game.make_move([[4,7], [5,6], :b])
			   #kings moves
			   game.make_move([[5,1], [5,2], :w])
			   game.make_move([[5,2], [5,3], :w])
			   game.make_move([[5,3], [6,3], :w])
			   game.make_move([[6,3], [6,4], :w])

			   game.make_move([[5,6], [5,5], :b])
			   expect(game.status).to be(:check)
			end

			it "and it is the black king" do
				game.make_move([[4,7], [4,5], :b])
				game.make_move([[3,2], [3,4], :w])
				game.make_move([[3,4], [3,5], :w])
				game.make_move([[4,1], [1,4], :w])

			   expect(game.status).to be(:check)
			end
		end
		
	end

	describe "#checkmate?" do
		context "when game is in checkmate state" do
			it "and black king can't move anywhere" do
				game.make_move([[5,2], [5,4], :w])
				game.make_move([[8,2], [8,4], :w])
				game.make_move([[8,1], [8,3], :w])
				game.make_move([[6,7], [6,5], :b])
				game.make_move([[7,7], [7,5], :b])
				game.make_move([[4,1], [8,5], :w])
				expect(game.status).to be(:checkmate)
			end
		end

		context "when game is not in checkmate state" do
			it "and black king can be saved by pawn sacrificing itself" do
				game.make_move([[5,2], [5,4], :w])
				game.make_move([[8,2], [8,4], :w])
				game.make_move([[8,1], [8,3], :w])
				game.make_move([[6,7], [6,5], :b])
				game.make_move([[4,1], [8,5], :w])
				expect(game.status).to be(:check)
			end

			it "and black king can be saved by pawn taking the queen" do
				game.make_move([[5,2], [5,4], :w])
				game.make_move([[8,2], [8,4], :w])
				game.make_move([[8,1], [8,3], :w])
				game.make_move([[6,7], [6,5], :b])
				game.make_move([[4,1], [8,5], :w])
				game.make_move([[7,7], [7,6], :b])
				game.make_move([[8,5], [7,6], :w])
				expect(game.status).to be(:check)
			end
		end
	end
end














