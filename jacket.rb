class Jacket
  RADIX = 36
  ROTOR_LEN = 4
  CHR_MAP = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split //
  ROTOR_CONFIGS = DATA.read.split("\n")

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
      a = uid[x]
      b = uid[((x+1)%l)]
      c = uid[((x+2)%l)]

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
      ca = config_for_rot(2-i).select {|x| x.include? c}.flatten
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

__END__
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
