#BroadcastSync.rb"
#syncs slave Sonic Pi machines
#coded by Robin Newman,Feb 2021
#utilises script broadcastOSC.py
use_debug false
use_cue_logging false
use_osc_logging false
titlecode="00 BroadcastSync"
use_osc "localhost",8000
computer=get(:computer) #this computer number
computer = 1 if computer == nil #use 1 if computer: not specified
define :config do
  ########## Allocate channels to be played by each computer here
  #computer number               1      2     3     4     5     6     7     8
  osc "/triggerBroadcast",99,    0,     0,    0,    0,    0,    0,    0,    0
  #osc "/triggerBroadcast",99,    0,     1,    1,    1,   "[0,1,2,3,4]",    1,    1,    1
  sleep 0.2
end
#qt is scale factor for amplitude. Set using :attentuate value
qt=get(:attenuate)
qt=1 if (qt == nil ) #in case attenuate has not been set
qt=[[qt,0].max,1].min

st=0 #start section of multi tempo music
#set_audio_latency! 234 #adjust for latency of computer relative to the others #this value for Mac
#play data sustain and release fracions and synth for each part
s=(ring 1);r=(ring 1);synth=(ring "piano") #parameters for the run. (s,r sustain release fractions)

amp=1

define :decode do |dl|#return selected channels in an integer array
  puts "entry",dl #print current entry
  if dl.is_a? Numeric
    return Array(dl)
  else
    return dl[1..-2].split(",").map {|str| str.to_i}
  end
end

define :bosc do |num,nv,dv,s,r,synth,tempo,amp,cueval,tr=0| #cueval used to separate tempo sections
  nv.length.times do
    tick
    if nv.look.respond_to?(:each) #deal with chords (played without gap between notes)
      nv.look.each do |v|
        osc "/triggerBroadcast", num, note(v)+tr,  (dv.look),s,r,synth,tempo,amp
      end
    else
      if nv.look!=:r #ignore rests
        osc "/triggerBroadcast", num, note(nv.look)+tr,(dv.look),s,r,synth,tempo,amp
      end
    end
    with_bpm tempo do;sleep dv.look;end
  end
  cue cueval
end

with_fx :reverb,room: 0.8,mix: 0.6 do #add some reverb to playback
  
  live_loop :pl do
    use_real_time
    b = sync"/osc*/broadcast"
    if b[0]==99 #99 is channel code to receive channel data lists
      op=[] #start output list
      b.each do |x| #check each element and process using decode
        op << (decode x)
      end
      #op now contains all machine channel list with array elements for each machine
      op[computer]=["none found"] if op[computer]==nil
      set :channel,op[computer]
    elsif b[0]==10
      sleep 2
      osc_send "localhost",4560,"/playnext",b[1] #send info back to calling buffer
      sleep 0.2
      stop
    end
    channel=get(:channel)
    puts "title code #{titlecode}: tempo #{b[6]}"
    puts "channels for computer no #{computer} #{channel}"
    if channel.include? b[0]
      use_synth b[5].to_sym
      use_bpm b[6]
      play b[1],sustain: b[2]*b[3],release: b[2]*b[4],amp: b[7]
    end
  end
end
config #allocate channels to computers
in_thread do
  n=[72,:r]*10 #adjust 10 to 100 for a longer run
  d=[1]*20 #adjust 20 to 200 for a longer run
  bosc 0,n,d,0.5,0.2,"pluck",120,amp*qt,:cont
  
end
sync :cont
sleep 0.2
osc "/triggerBroadcast",10,"finished00" #kill player for first part in program above

