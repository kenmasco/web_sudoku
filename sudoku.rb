require "sinatra"
require_relative './lib/sudoku'
require_relative './lib/cell'
require_relative './helpers/application.rb'

enable :sessions

def random_sudoku
    # we're using 9 numbers, 1 to 9, and 72 zeros as an input
    # it's obvious there may be no clashes as all numbers are unique
    seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
    sudoku = Sudoku.new(seed.join)
    # then we solve this (really hard!) sudoku
    sudoku.solve!
    # and give the output to the view as an array of chars
    sudoku.to_s.chars
end

def puzzle(sudoku)    
  numbers = sudoku.dup
  50.times { numbers[rand(0..80)] = 0 }
  numbers
end

get "/" do
  prepare_to_check_solution
  generate_new_puzzle_if_necessary
  @current_solution = session[:current_solution] || session[:puzzle]
  @solution = session[:solution]
  @puzzle = session[:puzzle]
  erb :index
end

get '/solution' do
  @current_solution = session[:solution]
  @puzzle = session[:puzzle]
  @solution = session[:solution]
  erb :index
end

post "/" do
  cells = box_order_to_row_order params["cell"]
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end 

def generate_new_puzzle_if_necessary
  return if session[:current_solution]
  sudoku = random_sudoku
  session[:solution] = sudoku
  session[:puzzle] = puzzle(sudoku)
  session[:current_solution] = session[:puzzle]
end

def prepare_to_check_solution
  @check_solution = session[:check_solution]
  session[:check_solution] = nil
end

def box_order_to_row_order(cells)
  boxes = cells.each_slice(9).to_a
  (0..8).to_a.inject([]) do |memo, i|
    first_box_index = i / 3 * 3
    three_boxes = boxes[first_box_index, 3]
    three_rows_of_three = three_boxes.map do |box|
      row_number_in_a_box = i % 3
      first_cell_in_the_row_index = row_number_in_a_box * 3
      box[first_cell_in_the_row_index, 3]
      end
    memo += three_rows_of_three.flatten
  end
end



