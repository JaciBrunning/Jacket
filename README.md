# Jacket
The worst best cipher ever
  
## Why
I want to encode secret messages on my school's leavers jackets.  
  
## How it works
Some inspiration for this program was taken from the Enigma machine. The notable features that I try to mirror and improve upon are
the Rotors, Rotor Configurations (*enigma has 3 models of each rotor*), and the Plugboard.  
I wanted the following features in the Cipher algorithm:  
- Single Key (Same key for encode and decode, unlike public/private key)
  - The key would be on 1 person's jacket, allowing the rest to be unlocked
- Key should store complete Rotor positions, Rotor configurations and Plugboard pairs
  - No ``` Random.new(seed) ```
- Key can not be longer than 13 characters, or contain punctuation
- Key and cipher must match this Regex to be valid ``` [a-zA-Z0-9\s] ```
  - Silly school leavers jacket requirements are silly
  
  
### Character Map
The whole process is based around the following Character Map:  
``` abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ```.  
This is kind of like the Keyboard on the enigma machine, converting a byte index to a char, generating pairs other miscellaneous things. This character
map is 62 chars long
  
### Random Key Generation
The random key is the first component to be generated, and looks a little something like ``` a6huWJgfuYG ```. Let's break it down:  
- **(0...3)** : [a6hu]
  - These are the Rotor Positions. Each rotor has a maximum value of the length of the Character Map (62), allowing it to be represented with a single char.
  Rotors will automatically overflow to the next when shifted, and route based on the Rotor Configuration of that index
- **(3...7)** : [WJgfuYG]
  - The plugboard configuration. This is passed into a convoluted function to determine Plugboard pairs
  
Each key is 12 bytes. Keys longer than 12 bytes will be substringed into the first 12 characters  
  
### Rotor Mapping  
Rotor Mapping is similar to the Enigma machine, with some notable changes. Jacket uses 4 rotors in ascending order, each starting at an index defined by the key (0-61 incl.).
When a rotor overflows, it is reset to 0 and the next rotor gains an index. For example, if ``` rotor[0] == 62 ```, ```rotor[0] = 0``` and ```rotor[1] += 1```. This check is then done
on every other Rotor. If all Rotors overflow, they are reset to the ``` [0, 0, 0, 0] ``` state to start again. Rotors are not semetrical, so ```encode```
and ```decode``` have to be 2 separate functions.  
  
### Rotor Cipher
The index of the rotor determines the Rotor Configuration to use, that is, the pairs of characters on the rotor. These are determined after the ```__END__``` tag on the ```jacket.rb``` file, 
with each line being a different mapping. Every 2nd character is mapped to the character before it. For example, in the first configuration (0), the 
character 's' matches to 'n', 'A' matches to '6' and so on. Each time a Rotor is shifted, its configuration changes to ensure a different pair each time.  
  
The data flow of the rotors goes from 0 to 3 ascending. The output from Rotor 0 is passed to Rotor 1, 1 to 2, and 2 to 3, and then passed to the plugboard. To decode, this 
method is simply reversed.  
  
### Plugboard Generation
The 8 character Plugboard 'seed' in the random key determines the plugboard pair configuration through a very convoluted function.  
First, we need to get a ton of integers. This can be done through Base36 decoding, but first we need at least the same amount of the 
Character Map, divided by 2 (for a pair). This winds up being 31.  
To get these integers, we do some permutations.  
- For each character, append it to a string variable. Do this 8 times, each time appending the string variable to an array of strings. This results in 
64 cyclic strings of lengths 1 to 8. This will be called the seed array
- Duplicate the Character Map (selection cache) and start a new 'pairs' array. 
- 31 times, select the nth item of the seed array and coerce it to a Base36 integer. 
- Take the size of the Selection Cache and put it through a Logarithm in Base 2. This gives the amount of bytes required to generate a number 
between 0 and the Selection Cache's size (i.e. an index), called the Shift Length
- Break down the binary of the Base36 int of the current 'seed' into even sections of the Shift Length. (0b01100011 becomes [0b11, 0b110] with split size 4). 
Map this array so that any integers larger than the Selection Cache size are overflowed back to 0 (this is a simple modulo)
- Take each of the separated binary and average them. This gives us an index to use for pair mapping. 
- Shift the first entry of the Selection Cache out (get & delete), and do the same for the averaged index in the previous step. These two characters are now a plugboard
pair and the Selection Cache has become 2 indexes smaller. This process should repeat until all pairs are made  
  
  
With a larger Random Key size, Plugboard Pairs could be generated more easily (and with more combinations), but wouldn't fit the criteria of the project.  

### Plugboard Cipher
Once plugboard types have been generated, the actual cipher is really simple. Sending the character coming out of the Rotor Cipher into the plugboard pairs
will result in a new character from the plugboard. Keep in mind the plugboard never changes (per key) and is reversible, so if ``` a & n ``` is a pair, ``` a ``` will always map 
to ``` n ```, and ``` n ``` will always map to ``` a ```. This is why the Rotors exist, as a plugboard on its own would be a boring and easily crackable cipher  
  
## How good is it? 
Good enough
