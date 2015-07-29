require_relative "jacket"

h = Jacket.encode "Hello World"                       # Encode with a random key
puts h
puts Jacket.decode(h)                                 # Decode with the same key that the word was encoded with

j = Jacket.new

k = "XvVCj7npaRRq"

j.key k                                               # Set the key for the Jacket instance
enc = j.encode "Test String Please Ignore"            # Encode a string with the key
puts enc

j.key k                                               # Set the key, resetting rotors for decoding
puts j.decode enc                                     # Decode the encoded string
