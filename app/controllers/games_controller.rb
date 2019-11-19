require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    session[:score] ||= 0
    @letters = []
    num = (6..10).to_a.sample
    num.times { @letters << ('A'..'Z').to_a.sample }
  end

  def score
    @answer = params['answer'].upcase
    @letters = params['letters'].scan(/(?<letters>[A-Z])/).flatten
    @start_time = params['start_time'].to_time
    @end_time = Time.now
    @time = @end_time - @start_time
    @score = 1000
    # @test = true
    @reason = 'Well Done!'

    # check for null string
    if @answer == ''
      # @test = false
      @score = 0
      @reason = 'You did not attempt the question!'
      return
    end

    # check for non-english words
    data = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{@answer}").read)
    if data['found'] == false
      # @test = false
      @score = 0
      @reason = 'You did not use an English word.'
      return
    end

    # check for invalid characters
    @answer.split('').each do |letter|
      if @letters.include?(letter) == false
        # @test = false
        @score = 0
        @reason = 'You used a character which was not provided.'
        return
      end
    end

    # heck for overused letters
    answercount = {}
    lettercount = {}
    @answer.split('').each do |letter|
      if answercount.keys.include?(letter)
        answercount['letter'] += 1
      else
        answercount['letter'] = 0
      end
    end
    @letters.each do |letter|
      if lettercount.keys.include?(letter)
        answercount['letter'] += 1
      else
        lettercount['letter'] = 0
      end
    end
    answercount.keys.each do |letter|
      if answercount[letter] > lettercount[letter]
        # @test = false
        @score = 0
        @reason = 'You have used a character too many times.'
        return
      end
    end

    # evaluate score
    @score = (1000 - (@time * 10) + (@answer.length * 100)).round(0)
    session[:score] += @score
  end
end
