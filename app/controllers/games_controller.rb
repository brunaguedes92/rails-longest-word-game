require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @score = run_game(params[:word], params[:letters].split(' '), Time.parse(params[:start_time]), Time.now)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    charset = Array('A'..'Z')
    Array.new(grid_size) { charset.sample }
  end

  def word_in_the_grid?(grid, attempt)
    attempt.upcase!
    attempt.split(//).all? do |char|
      grid.delete_at(grid.find_index(char)) if grid.include?(char)
    end
  end

  def an_english_word?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    dict_serialized = open(url).read
    dict = JSON.parse(dict_serialized)
    dict['found']
  end

  def calc_score(grid, attempt, time)
    english_word = an_english_word?(attempt)
    word_in_the_grid = word_in_the_grid?(grid, attempt)
    if english_word && word_in_the_grid
      calc_score = (attempt.size / time) * 10
      return [calc_score, 'Well done!'] if calc_score >= 10
      return [calc_score, 'OK'] if calc_score < 10 && calc_score >= 5

      [calc_score, 'It could be better']
    elsif !word_in_the_grid
      [0, 'Not in the grid']
    elsif !english_word
      [0, 'Not an english word']
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    time = end_time - start_time
    calc_score = calc_score(grid, attempt, time)
    result = {
      time: time,
      calc_score: calc_score[0],
      message: calc_score[1]
    }
    result
  end
end
