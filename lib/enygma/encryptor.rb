module Enygma
  class Encryptor
    include Confirmation
    attr_reader :filename, :cypher_filename, :offset, :encryption_key,
                :encryption_date, :encrypted

    def initialize(filename, cypher_filename = nil)
      @filename = filename
      @cypher_filename = cypher_filename
      @encryption_key =  rand(10**5).to_s.rjust(5, '0')
      @encryption_date = Time.now.strftime("%d%m%y")
      @offset = Offset.get_offset(@encryption_date)
      @encrypted = ""
    end

    def encrypt
      begin
        plain_characters = Filer.read(@filename)
        plain_characters.each_slice(4) { |batch| encrypt_batch(batch) }
        @cypher_filename = Filer.write(
          @cypher_filename,
          @encrypted,
          @filename,
          "encrypted"
        )

        show_confirmation_message(
          @cypher_filename,
          @encryption_key,
          @encryption_date
        )
      rescue StandardError => e
        puts "Could not open the file you supplied."\
        "Make sure you are correctly typing the correct path. #{e.message}"
      end
    end

    def encrypt_batch(batch)
      key_characters = @encryption_key.split('')
      offset_characters = @offset.split('')
      batch.each_with_index do |_value, index|
        new_index = Rotator.rotate(
          key_characters[index],
          key_characters[index + 1],
          offset_characters[index],
          batch[index]
        ) { |x, y| x + y }

        @encrypted += Enygma::CHARACTER_MAP[new_index]
      end
    end
  end
end