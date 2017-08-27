require 'twitter_ebooks'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  attr_accessor :original, :model, :model_path

  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = ENV['MY_LITTLE_BATMAN_CONSUMER_KEY']
    self.consumer_secret = ENV['MY_LITTLE_BATMAN_CONSUMER_SECRET']
  end

  def on_startup
    load_model!

    # Get the names of characters which can be replaced
    characters = File.foreach('characters.txt').map { |line| line.chomp }

    # Get the Batman words
    batman = File.foreach('bat_characters.txt').map { |line| line.split("\n") }

    scheduler.every '171m' do
      log "Building tweet"

      # Generate a statement using the model
      # I kept the character count down to leave room for long Lovecraft names
      statement = model.make_statement(100)

      # Prepare to collect words and count names which are in the statement
      words = []
      name_count = 0

      # Get each individual word, break it up and check for names
      statement.split(' ').each do |word|
        # Separate out punctuation and anything after it, like 's
        word_bits = word.split(/(?<=\w)(?=[.,?':;])/)
        # If it's a name, add it to the array
        name_count += 1 if characters.include?(word_bits[0])
        words << word_bits
      end

      # If there are names, at least one must be Batman-ified
      if name_count > 0
        has_batman = false
        while has_batman == false
          words.each_with_index do |word_bits, index|
            # Replace a name with Batman 50% of the time
            next unless characters.include?(word_bits[0]) && rand > 0.5
            word_bits[0] = batman.sample
            # We got Batman now! No need to re-run this loop
            has_batman = true
            # If this is the first word, capitalise it appropriately
            next unless index.zero?
            first_word = word_bits[0][0].to_s.split
            first_word[0].capitalize!
            word_bits[0][0] = first_word.join(' ').to_s
          end
        end
      end

      # Join up the punctuation, then the words
      new_words = []
      words.each do |word_bits|
        new_words << word_bits.join
      end
      new_statement = new_words.join(' ')

      log "Tweeting"
      tweet(new_statement)
    end
  end

  private

  def load_model!
    return if @model

    @model_path ||= 'model/ponyville.model'

    log "Loading model #{model_path}"
    @model = Ebooks::Model.load(model_path)
  end
end

# Make a MyBot and attach it to an account
MyBot.new('_mylittlebatman') do |bot|
  log "Instantiating new bot"
  bot.access_token = ENV['SOAP_BOT_TOKEN']
  bot.access_token_secret = ENV['SOAP_BOT_TOKEN_SECRET']
end
