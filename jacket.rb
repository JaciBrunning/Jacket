class Jacket
  RADIX = 36
  ROTOR_LEN = 4
  CHR_MAP = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split //
  ROTOR_CONFIGS = File.read(File.expand_path("../rotor_config.txt", __FILE__)).split("\n")

  ## DATASET
  def initialize
    @rotors = Array.new(ROTOR_LEN).fill 0
    @plugboard = []
    @pluguid = (0..8).map { CHR_MAP.sample }.join("")
    random
  end

  def random
    @rotors = @rotors.map { rand(CHR_MAP.length) }
    @pluguid = (0..8).map { CHR_MAP.sample }.join("")
    encode_key
  end

  def key k=""
    if k == ""
      encode_key
    else
      decode_key k
    end
  end

  def encode_key
    str = ""
    @rotors.length.times do |i|
      str << CHR_MAP[@rotors[i]]
    end
    str += gen_plugboard(@pluguid)
    str
  end

  def decode_key str
    spl = str.split //
    @rotors.length.times do |i|
      chr = spl.shift
      @rotors[i] = CHR_MAP.index chr
    end
    @pluguid = spl.join("")
    gen_plugboard(@pluguid)
    nil
  end

  # Split a binary integer into multiple binary integers. 0b01100011 becomes [0b11, 0b110]
  def shift_integers uid, length
    uid.to_s(2).split("").each_slice(length).map {|x| x.join("").reverse.to_i(2)}
  end

  def gen_plugboard uid
    l = 8
    uid = uid[0...l]
    arr = []
    l.times do |x|
      str = ""
      l.times do |y|
        str += uid[((x+y)%l)]
        arr << str
      end
    end

    arr = arr.flatten

    selection_cache = CHR_MAP.dup
    pairs = []

    (selection_cache.size / 2).times do |a|
      u = arr[a]
      int = u.to_i(RADIX)
      selections = selection_cache.size;
      lg = (Math.log(selections) / Math.log(2)).ceil
      shft = shift_integers(int, lg).map { |x| x = x%selections; x = 1 if x == 0; x  }
      av = (shft.inject(&:+) / shft.length).ceil

      pa = selection_cache.delete_at(av)
      pairs << [selection_cache.shift, pa]
    end
    @plugboard = pairs
    uid
  end

  def rotors
    @rotors
  end

  def plugboard
    @plugboard
  end

  def reset
    @rotors.fill 0
  end

  def shift_rotors
    @rotors[0] += 1

    @rotors.length.times do |i|
      if @rotors[i] == CHR_MAP.length
        @rotors[i] = 0
        @rotors[(i+1)%(@rotors.length)] += 1
      end
    end
  end

  def to_s
    "#<Jacket key=#{encode_key}>"
  end

  def config_for_rot i
    ROTOR_CONFIGS[@rotors[i]].split("").each_slice(2).map(&:join).map { |x| x.split("") }
  end

  ## ENCODER
  def rotor_cipher c
    @rotors.length.times do |i|
      ca = config_for_rot(i).select {|x| x.include? c}.flatten
      c = ((ca[0] == c) ? ca[1] : ca[0])
    end
    c
  end

  def reverse_rotor_cipher c
    @rotors.length.times do |i|
      ca = config_for_rot(@rotors.length-1-i).select {|x| x.include? c}.flatten
      c = ((ca[0] == c) ? ca[1] : ca[0])
    end
    c
  end

  def plugboard_cipher c
    x = plugboard.select { |x| x.include? c }.flatten
    c = ((x[0] == c) ? x[1] : x[0])
    c
  end

  def encode str, key=""
    decode_key(key) unless key == ""
    ret = ""
    str.split("").each do |char|
      if (char =~ /\s/) != nil
        ret += " "
      else
        c = rotor_cipher(char)
        c = plugboard_cipher c
        ret += c
        shift_rotors                # Prepare for Next
      end
    end
    ret
  end

  def decode str, key=""
    decode_key(key) unless key == ""

    ret = ""
    str.split("").each do |char|
      if (char =~ /\s/) != nil
        ret += " "
      else
        c = plugboard_cipher char
        c = reverse_rotor_cipher(c)
        ret += c
        shift_rotors                # Prepare for Next
      end
    end
    ret
  end

  def self.encode str
    j = Jacket.new
    {:key => j.key, :cipher => j.encode(str)}
  end

  def self.decode cipher
    j = Jacket.new
    j.key(cipher[:key])
    j.decode cipher[:cipher]
  end

end
