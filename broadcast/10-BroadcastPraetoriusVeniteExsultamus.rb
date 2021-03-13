#10-BroadcastPraetoriusVEniteExsutlamus.rb
#Broadcast version of Praetorius Venite Exultaums
#coded by Robin Newman,Feb 2021
#utilises script broadcastOSC.py
use_debug false
use_cue_logging false
use_osc_logging false
titlecode="10 Praetorius Venite Exsultamus"
use_osc "localhost",8000
computer=get(:computer) #this computer number
computer = 1 if computer == nil #use 1 if computer: not specified

define :config do
########## Allocate channels to be played by each computer here
#computer number              1     2     3     4     5     6     7     8
osc "/triggerBroadcast",99,   0,    1,    2,    0,    4,    5,    6,    7
osc "/triggerBroadcast",99,   "[0,1,2,3]",9,9,9,"[4,5,6,7]"#,    1,    2,    0,    4,    5,    6,    7
end
#qt is scale factor for amplitude. Set using :attentuate value
qt=get(:attenuate)
qt=1 if (qt == nil ) #in case attenuate has not been set
qt=[[qt,0].max,1].min

st=0 #start section of multi tempo music
#set_audio_latency! 234 #adjust for latency of computer relative to the others
#play data sustain and release fracions and synth for each part
s=(ring 0.95);r=(ring 0.05);synth=(ring "tri","tri","tri","tri","blade","blade","blade","saw") #parameters for the run. (s,r sustain release fractions)

amp=(ring 0.8,0.6,0.6,0.8,0.8,0.8,0.8,0.25,1.2)

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

with_fx :reverb,room: 0.8,mix: 0.6 do #add som reverb to playback
  
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
    if b[0]==20
      use_bpm b[6]
      case b[1]
      when note(:D3)
        sample :drum_bass_hard,amp: b[7]
      when note(:Fs3)
        sample :drum_cymbal_closed,amp: b[7]
      when note(:A3)
        sample :drum_cymbal_pedal,amp: b[7]
      when note(:D4)
        sample :drum_snare_soft,amp: b[7]
      when note(:C4)
        sample :bd_haus,amp: b[7]
      when note(:F3)
        sample :drum_tom_hi_soft,amp: b[7]
      when note(:G3)
        sample :drum_tom_mid_soft,amp: b[7]
      when note(:Bf3)
        sample :drum_tom_low_soft,amp: b[7]
      end
    end
  end
end

config #setup computer channel allocations
sleep 0.2#belt and braces: allow a short time to make sure received and procdssed


tempo=240
a1=[]
b1=[]
a1[0]=[:G4,:D5,:D5,:D5,:D5,:F5,:F5,:F5,:E5,:D5,:D5,:D5,:r,:D5,:D5,:D5,:D5,:F5,:F5,:E5,:E5,:D5,:D5,:C5,:C5,:C5,:D5,:E5,:F5,:F5,:Ef5,:D5,:D5,:A4,:r,:r,:G4,:Bf4,:C5,:D5,:C5,:Bf4,:A4,:G4,:F4,:E4,:D4,:E4,:F4,:G4,:A4,:Bf4,:C5,:C5,:D5,:G4,:A4,:Bf4,:C5,:D5,:C5,:Bf4,:A4,:Bf4,:C5,:G4,:G4,:G4,:E4,:F4,:E4,:D4,:F4,:F4,:F4,:D4,:F4,:E4,:A4,:Bf4,:C5,:A4,:r,:G4,:A4,:Bf4,:G4,:D5,:E5,:F5,:D5,:Bf4,:C5,:D5,:Bf4,:Bf4,:A4,:Bf4,:A4,:G4,:E4,:F4,:E4,:F4,:G4,:F4,:G4,:A4,:Bf4,:A4,:Bf4,:C5,:D5,:C5,:D5,:E5,:F5,:E5,:D5,:C5,:Bf4,:A4,:G4,:A4,:Bf4,:F4,:r,:D4,:E4,:F4,:E4,:F4,:G4,:A4,:G4,:A4,:Bf4,:C5,:Bf4,:C5,:D5,:E5,:D5,:Cs5,:D5,:G4,:D5,:D5,:D5,:D5,:F5,:F5,:F5,:E5,:D5,:D5,:D5,:r,:D5,:D5,:D5,:D5,:F5,:F5,:E5,:E5,:D5,:D5,:C5,:C5,:C5,:D5,:E5,:F5,:F5,:Ef5,:D5,:D5,:A4,:B4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G4,:D5,:D5,:D5,:D5,:F5,:F5,:F5,:E5,:D5,:D5,:D5,:r,:D5,:D5,:D5,:D5,:F5,:F5,:E5,:E5,:D5,:D5,:C5,:C5,:C5,:D5,:E5,:F5,:F5,:Ef5,:D5,:D5,:A4,:B4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G4,:D5,:D5,:D5,:D5,:F5,:F5,:F5,:E5,:D5,:D5,:D5,:r,:D5,:D5,:D5,:D5,:F5,:F5,:E5,:E5,:D5,:D5,:C5,:C5,:C5,:D5,:E5,:F5,:F5,:Ef5,:D5,:D5,:A4,:B4,:r,:G4,:D5,:E5,:F5,:D5,:r,:G4,:D5,:E5,:F5,:D5,:r,:Bf4,:Bf4,:D5,:C5,:Bf4,:A4,:Bf4,:A4,:G4,:Fs4,:E4,:Fs4,:G4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:Bf4,:Ef5,:D5,:C5,:B4,:C5,:G4,:G4,:r,:F4,:Bf4,:A4,:G4,:Fs4,:G4,:G4,:D4,:r,:r,:r,:A4,:Bf4,:A4,:Bf4,:C5,:D5,:C5,:D5,:Bf4,:C5,:Bf4,:A4,:r,:r,:r,:r,:r,:r,:r,:r,:G4,:D5,:D5,:D5,:D5,:F5,:F5,:F5,:E5,:D5,:D5,:D5,:r,:D5,:D5,:D5,:D5,:F5,:F5,:E5,:E5,:D5,:D5,:C5,:C5,:C5,:D5,:E5,:F5,:F5,:Ef5,:D5,:D5,:A4,:B4,:r]
b1[0]=[3.0,2.0,2.0,2.0,1.0,4.0,2.0,1.5,0.5,4.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,2.0,6.0,2.0,4.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,1.0,0.5,0.5,1.0,1.0,1.5,0.5,0.5,0.5,2.0,1.0,1.0,0.5,0.5,1.0,1.0,4.0,1.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,1.0,1.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,1.0,1.0,2.0,2.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.5,0.5,0.5,0.5,1.5,0.5,0.5,0.5,2.0,2.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,2.0,4.0,3.0,2.0,2.0,2.0,1.0,4.0,2.0,1.5,0.5,4.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,2.0,6.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,3.0,2.0,2.0,2.0,1.0,4.0,2.0,1.5,0.5,4.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,2.0,6.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,3.0,2.0,2.0,2.0,1.0,4.0,2.0,1.5,0.5,4.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,2.0,6.0,2.0,4.0,2.0,2.0,1.5,0.5,2.0,2.0,1.0,1.0,1.5,0.5,2.0,2.0,1.0,1.0,1.0,1.5,0.5,2.0,1.0,1.0,1.0,1.0,0.5,0.5,2.0,4.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,4.0,6.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,6.0,2.0,2.0,2.0,1.0,1.0,2.0,4.0,2.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,2.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,3.0,2.0,2.0,2.0,1.0,4.0,2.0,1.5,0.5,4.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,2.0,6.0,2.0,8.0,8.0]
c1=[tempo]
in_thread do
  for i in st..a1.length-1
    in_thread do
      bosc 0,a1[i],b1[i],s[0],r[0],synth[0],c1[i],amp[0]*qt,:cont0
    end
    sync :cont0
  end
    sleep 0.2
  osc "/triggerBroadcast",10,"finished10"
end

a2=[]
b2=[]
a2[0]=[:r,:D4,:A3,:D4,:D4,:Bf3,:F4,:F4,:D4,:E4,:F4,:r,:Bf3,:C4,:D4,:r,:r,:F4,:D4,:G4,:D4,:A4,:G4,:G4,:r,:D4,:A4,:A4,:D4,:D4,:G4,:Fs4,:G4,:Fs4,:G4,:r,:r,:D4,:F4,:G4,:A4,:G4,:F4,:E4,:D4,:C4,:Bf3,:A3,:G3,:A3,:Bf3,:Bf3,:C4,:D4,:A3,:C4,:C4,:C4,:F3,:C4,:G3,:D4,:D4,:D4,:G3,:D4,:A3,:r,:A3,:Bf3,:C4,:G3,:G3,:A3,:Bf3,:Bf3,:G3,:A3,:Bf3,:F3,:C4,:G3,:r,:Bf3,:Bf3,:Bf3,:C4,:G3,:D4,:D4,:C4,:Bf3,:C4,:D4,:D4,:A3,:A3,:A3,:D4,:r,:D4,:A3,:D4,:D4,:Bf3,:F4,:F4,:D4,:E4,:F4,:r,:Bf3,:C4,:D4,:r,:r,:F4,:D4,:G4,:D4,:A4,:G4,:G4,:r,:D4,:A4,:A4,:D4,:D4,:G4,:Fs4,:G4,:Fs4,:G4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:D4,:A3,:D4,:D4,:Bf3,:F4,:F4,:D4,:E4,:F4,:r,:Bf3,:C4,:D4,:r,:r,:F4,:D4,:G4,:D4,:A4,:G4,:G4,:r,:D4,:A4,:A4,:D4,:D4,:G4,:Fs4,:G4,:Fs4,:G4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:D4,:A3,:D4,:D4,:Bf3,:F4,:F4,:D4,:E4,:F4,:r,:Bf3,:C4,:D4,:r,:r,:F4,:D4,:G4,:D4,:A4,:G4,:G4,:r,:D4,:A4,:A4,:D4,:D4,:G4,:Fs4,:G4,:Fs4,:G4,:r,:r,:D4,:G4,:G4,:G3,:D4,:E4,:F4,:D4,:G4,:G3,:D4,:G3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:Bf3,:Ef4,:D4,:C4,:B3,:C4,:C4,:G3,:C4,:G4,:F4,:F4,:Bf3,:r,:r,:r,:r,:r,:D4,:G3,:C4,:D4,:r,:r,:r,:r,:r,:r,:r,:E4,:F4,:E4,:F4,:G4,:A4,:G4,:A4,:F4,:G4,:F4,:Ef4,:D4,:G4,:Fs4,:r,:D4,:A3,:D4,:D4,:Bf3,:F4,:F4,:D4,:E4,:F4,:r,:Bf3,:C4,:D4,:r,:r,:F4,:D4,:G4,:D4,:A4,:G4,:G4,:r,:D4,:A4,:A4,:D4,:D4,:G4,:Fs4,:G4,:Fs4,:G4,:r]
b2[0]=[2.0,3.0,2.0,1.0,1.5,0.5,4.0,2.0,1.5,0.5,2.0,1.0,2.0,1.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,3.0,1.0,2.0,1.0,1.0,2.0,3.0,2.0,1.0,4.0,2.0,4.0,2.0,8.0,4.0,2.0,2.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,3.0,1.0,2.0,2.0,2.0,3.0,1.0,1.0,1.0,2.0,2.0,3.0,1.0,1.0,1.0,2.0,4.0,2.0,1.0,1.0,2.0,2.0,1.0,1.0,4.0,4.0,1.0,1.0,4.0,4.0,4.0,4.0,2.0,1.0,1.0,3.0,1.0,2.0,2.0,1.5,0.5,0.5,0.5,2.0,1.0,1.0,1.0,4.0,4.0,2.0,3.0,2.0,1.0,1.5,0.5,4.0,2.0,1.5,0.5,2.0,1.0,2.0,1.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,3.0,1.0,2.0,1.0,1.0,2.0,3.0,2.0,1.0,4.0,2.0,4.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,2.0,3.0,2.0,1.0,1.5,0.5,4.0,2.0,1.5,0.5,2.0,1.0,2.0,1.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,3.0,1.0,2.0,1.0,1.0,2.0,3.0,2.0,1.0,4.0,2.0,4.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,3.0,2.0,1.0,1.5,0.5,4.0,2.0,1.5,0.5,2.0,1.0,2.0,1.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,3.0,1.0,2.0,1.0,1.0,2.0,3.0,2.0,1.0,4.0,2.0,4.0,2.0,8.0,4.0,8.0,2.0,2.0,1.0,1.0,1.5,0.5,2.0,2.0,1.0,1.0,2.0,4.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,2.0,2.0,6.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,2.0,4.0,8.0,8.0,2.0,1.0,1.0,4.0,2.0,2.0,4.0,8.0,8.0,8.0,8.0,4.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,0.5,0.5,2.0,2.0,8.0,2.0,3.0,2.0,1.0,1.5,0.5,4.0,2.0,1.5,0.5,2.0,1.0,2.0,1.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,3.0,1.0,2.0,1.0,1.0,2.0,3.0,2.0,1.0,4.0,2.0,4.0,2.0,8.0,8.0]
c2=[tempo]
in_thread do
  for i in st..a2.length-1
    in_thread do
      bosc 1,a2[i],b2[i],s[1],r[1],synth[1],c2[i],amp[1]*qt,:cont1
    end
    sync :cont1
  end
end

a3=[]
b3=[]
a3[0]=[:Bf4,:A4,:A4,:A4,:Bf4,:A4,:Bf4,:C5,:C5,:Bf4,:Bf4,:A4,:r,:Bf4,:Bf4,:Bf4,:Bf4,:C5,:C5,:C5,:C5,:Bf4,:C5,:D5,:E5,:F5,:F5,:F5,:F5,:D5,:D5,:C5,:Bf4,:A4,:Bf4,:A4,:Bf4,:C5,:D5,:D5,:r,:G4,:Bf4,:C5,:D5,:C5,:Bf4,:A4,:G4,:F4,:E4,:D4,:E4,:F4,:G4,:A4,:D4,:G4,:F4,:F4,:E4,:F4,:E4,:F4,:E4,:E4,:F4,:G4,:A4,:G4,:A4,:Bf4,:A4,:r,:A4,:Bf4,:C5,:C5,:A4,:Bf4,:C5,:G4,:G4,:A4,:Bf4,:G4,:D5,:E5,:F5,:D5,:Bf4,:C5,:D5,:Bf4,:D5,:C5,:D5,:C5,:C5,:G4,:A4,:G4,:A4,:Bf4,:C5,:Bf4,:A4,:G4,:F4,:G4,:A4,:Bf4,:A4,:Bf4,:C5,:D5,:C5,:D5,:E5,:F5,:E5,:D5,:C5,:D5,:C5,:Bf4,:A4,:A4,:r,:D4,:E4,:F4,:E4,:F4,:G4,:A4,:G4,:A4,:Bf4,:C5,:D5,:E5,:D5,:Bf4,:A4,:A4,:A4,:Bf4,:A4,:Bf4,:C5,:C5,:Bf4,:Bf4,:A4,:r,:Bf4,:Bf4,:Bf4,:Bf4,:C5,:C5,:C5,:C5,:Bf4,:C5,:D5,:E5,:F5,:F5,:F5,:F5,:D5,:D5,:C5,:Bf4,:A4,:Bf4,:A4,:Bf4,:C5,:D5,:D5,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:Bf4,:A4,:A4,:A4,:Bf4,:A4,:Bf4,:C5,:C5,:Bf4,:Bf4,:A4,:r,:Bf4,:Bf4,:Bf4,:Bf4,:C5,:C5,:C5,:C5,:Bf4,:C5,:D5,:E5,:F5,:F5,:F5,:F5,:D5,:D5,:C5,:Bf4,:A4,:Bf4,:A4,:Bf4,:C5,:D5,:D5,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:Bf4,:A4,:A4,:A4,:Bf4,:A4,:Bf4,:C5,:C5,:Bf4,:Bf4,:A4,:r,:Bf4,:Bf4,:Bf4,:Bf4,:C5,:C5,:C5,:C5,:Bf4,:C5,:D5,:E5,:F5,:F5,:F5,:F5,:D5,:D5,:C5,:Bf4,:A4,:Bf4,:A4,:Bf4,:C5,:D5,:D5,:r,:G4,:D5,:E5,:F5,:D5,:r,:G4,:D5,:E5,:F5,:D5,:Bf4,:A4,:D5,:C5,:D5,:C5,:Bf4,:A4,:G4,:A4,:G4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:F4,:G4,:G4,:G4,:Ef5,:D5,:C5,:Bf4,:C5,:D5,:C5,:Bf4,:C5,:D5,:D5,:D5,:r,:r,:r,:Fs4,:G4,:F4,:G4,:A4,:Bf4,:A4,:Bf4,:G4,:A4,:G4,:Fs4,:r,:r,:r,:r,:r,:r,:r,:r,:Bf4,:A4,:A4,:A4,:Bf4,:A4,:Bf4,:C5,:C5,:Bf4,:Bf4,:A4,:r,:Bf4,:Bf4,:Bf4,:Bf4,:C5,:C5,:C5,:C5,:Bf4,:C5,:D5,:E5,:F5,:F5,:F5,:F5,:D5,:D5,:C5,:Bf4,:A4,:Bf4,:A4,:Bf4,:C5,:D5,:D5,:r]
b3[0]=[4.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,2.0,1.0,0.5,0.5,2.0,8.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,0.5,0.5,2.0,1.0,2.0,3.0,1.0,2.0,2.0,1.0,2.0,1.0,1.5,0.5,1.0,1.0,1.0,1.0,2.0,4.0,2.0,1.0,1.0,2.0,2.0,1.0,1.0,2.0,0.5,0.5,1.0,2.0,2.0,1.0,1.0,2.0,2.0,1.0,1.0,2.0,2.0,3.0,1.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.5,0.5,1.0,1.0,1.0,0.5,0.5,2.0,2.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,2.0,4.0,4.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,2.0,1.0,0.5,0.5,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,2.0,1.0,0.5,0.5,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,4.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,2.0,1.0,0.5,0.5,2.0,6.0,2.0,2.0,1.5,0.5,2.0,2.0,1.0,1.0,1.5,0.5,2.0,3.0,1.0,1.0,2.0,1.0,1.5,0.5,1.0,0.5,0.5,2.0,4.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,2.0,2.0,8.0,3.0,1.0,2.0,2.0,2.0,1.0,1.0,6.0,2.0,1.0,1.0,4.0,2.0,4.0,4.0,2.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,2.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,2.0,1.0,0.5,0.5,2.0,8.0,8.0]
c3=[tempo]
in_thread do
  for i in st..a3.length-1
    in_thread do
      bosc 2,a3[i],b3[i],s[3],r[3],synth[3],c3[i],amp[3]*qt,:cont2
    end
    sync :cont2
  end
end

a4=[]
b4=[]
a4[0]=[:G3,:D3,:D3,:r,:F3,:F3,:F3,:F3,:Bf2,:C3,:D3,:D3,:D3,:r,:Bf2,:Bf2,:F3,:C3,:F3,:C3,:C3,:D3,:E3,:C3,:G3,:D3,:r,:F3,:F3,:Bf2,:F3,:r,:C3,:G3,:D3,:E3,:Fs3,:G3,:A3,:D3,:D3,:G3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G3,:D3,:D3,:r,:F3,:F3,:F3,:F3,:Bf2,:C3,:D3,:D3,:D3,:r,:Bf2,:Bf2,:F3,:C3,:F3,:C3,:C3,:D3,:E3,:C3,:G3,:D3,:r,:F3,:F3,:Bf2,:F3,:r,:C3,:G3,:D3,:E3,:Fs3,:G3,:A3,:D3,:D3,:E3,:Fs3,:G3,:G3,:r,:D3,:D3,:G3,:F3,:Bf3,:Bf3,:Bf3,:A3,:G3,:G3,:F3,:G3,:C3,:F3,:Bf2,:F3,:D3,:F3,:D3,:A3,:D3,:G3,:G3,:C3,:F3,:D3,:G3,:D3,:Ef3,:D3,:C3,:C3,:Bf2,:Bf3,:A3,:G3,:G3,:F3,:Bf2,:Bf3,:Bf3,:Bf3,:G3,:G3,:C4,:F3,:F3,:C3,:C3,:C3,:C3,:G3,:C3,:C3,:D3,:G3,:F3,:F3,:F3,:G3,:E3,:D3,:F3,:G3,:D3,:D3,:G3,:G3,:D3,:D3,:r,:F3,:F3,:F3,:F3,:Bf2,:C3,:D3,:D3,:D3,:r,:Bf2,:Bf2,:F3,:C3,:F3,:C3,:C3,:D3,:E3,:C3,:G3,:D3,:r,:F3,:F3,:Bf2,:F3,:r,:C3,:G3,:D3,:E3,:Fs3,:G3,:A3,:D3,:D3,:E3,:Fs3,:G3,:G3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G3,:D3,:D3,:r,:F3,:F3,:F3,:F3,:Bf2,:C3,:D3,:D3,:D3,:r,:Bf2,:Bf2,:F3,:C3,:F3,:C3,:C3,:D3,:E3,:C3,:G3,:D3,:r,:F3,:F3,:Bf2,:F3,:r,:C3,:G3,:D3,:E3,:Fs3,:G3,:A3,:D3,:D3,:E3,:Fs3,:G3,:G3,:r,:r,:r,:r,:r,:r,:r,:r,:D3,:G3,:A3,:Bf3,:G3,:r,:D3,:G3,:A3,:Bf3,:F3,:G3,:D3,:Bf3,:A3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G3,:Bf3,:A3,:G3,:Fs3,:G3,:G3,:D3,:D3,:Bf3,:A3,:r,:r,:r,:r,:r,:r,:r,:r,:D3,:G3,:F3,:G3,:A3,:Bf3,:A3,:Bf3,:G3,:A3,:G3,:D3,:D3,:D3,:G3,:A3,:r,:r,:r,:G3,:D3,:D3,:r,:F3,:F3,:F3,:F3,:Bf2,:C3,:D3,:D3,:D3,:r,:Bf2,:Bf2,:F3,:C3,:F3,:C3,:C3,:D3,:E3,:C3,:G3,:D3,:r,:F3,:F3,:Bf2,:F3,:r,:C3,:G3,:D3,:E3,:Fs3,:G3,:A3,:D3,:D3,:E3,:Fs3,:G3,:G3,:r]
b4[0]=[4.0,2.0,2.0,2.0,3.0,1.0,1.0,1.0,3.0,1.0,2.0,2.0,4.0,4.0,3.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,1.0,2.0,3.0,1.0,1.0,1.0,1.0,1.0,4.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,2.0,2.0,3.0,1.0,1.0,1.0,3.0,1.0,2.0,2.0,4.0,4.0,3.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,1.0,2.0,3.0,1.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,2.0,4.0,2.0,3.0,1.0,2.0,6.0,2.0,4.0,2.0,2.0,2.0,2.0,4.0,2.0,2.0,2.0,2.0,3.0,1.0,1.0,1.0,2.0,2.0,3.0,1.0,2.0,1.0,1.0,1.0,1.0,1.5,0.5,1.0,1.0,1.0,2.0,1.0,2.0,2.0,8.0,3.0,1.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,3.0,1.0,1.0,1.0,1.5,0.5,1.0,2.0,1.0,4.0,4.0,2.0,2.0,2.0,4.0,4.0,2.0,2.0,2.0,3.0,1.0,1.0,1.0,3.0,1.0,2.0,2.0,4.0,4.0,3.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,1.0,2.0,3.0,1.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,2.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,4.0,2.0,2.0,2.0,3.0,1.0,1.0,1.0,3.0,1.0,2.0,2.0,4.0,4.0,3.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,1.0,2.0,3.0,1.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,2.0,4.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,2.0,2.0,1.5,0.5,2.0,2.0,1.0,1.0,1.5,0.5,2.0,1.0,2.0,1.0,4.0,4.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,2.0,6.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,2.0,4.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,1.0,1.0,2.0,2.0,2.0,2.0,8.0,8.0,4.0,2.0,2.0,2.0,3.0,1.0,1.0,1.0,3.0,1.0,2.0,2.0,4.0,4.0,3.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,1.0,2.0,3.0,1.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,2.0,8.0,4.0]
c4=[tempo]
in_thread do
  for i in st..a4.length-1
    in_thread do
      bosc 3,a4[i],b4[i],s[4],r[4],synth[4],c4[i],amp[4]*qt,:cont3
    end
    sync :cont3
  end
end

a5=[]
b5=[]
a5[0]=[:D4,:D4,:D4,:D4,:Bf3,:C4,:C4,:D4,:D4,:D4,:r,:r,:Bf3,:Bf3,:D4,:Bf3,:A3,:A3,:C4,:C4,:r,:Bf3,:A3,:C4,:C4,:Bf3,:A3,:D4,:D4,:r,:G3,:A3,:Bf3,:C4,:D4,:D4,:D4,:D4,:D4,:B3,:C4,:D4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:D4,:D4,:D4,:D4,:Bf3,:C4,:C4,:D4,:D4,:D4,:r,:r,:Bf3,:Bf3,:D4,:Bf3,:A3,:A3,:C4,:C4,:r,:Bf3,:A3,:C4,:C4,:Bf3,:A3,:D4,:D4,:r,:G3,:A3,:Bf3,:C4,:D4,:D4,:D4,:D4,:D4,:B3,:r,:A3,:A3,:Bf3,:C4,:D4,:C4,:D4,:D4,:D4,:C4,:Bf3,:Bf3,:A3,:Bf3,:C4,:C4,:C4,:Bf3,:A3,:G3,:A3,:A3,:A3,:D4,:Cs4,:D4,:B3,:C4,:D4,:D4,:E4,:C4,:D4,:Bf3,:A3,:G3,:A3,:Bf3,:A3,:Bf3,:D4,:C4,:Bf3,:A3,:Bf3,:A3,:Bf3,:D4,:D4,:D4,:D4,:D4,:E4,:C4,:C4,:G3,:A3,:B3,:B3,:C4,:G3,:C4,:A3,:Bf3,:C4,:C4,:C4,:Bf3,:C4,:D4,:C4,:C4,:D4,:C4,:Bf3,:A3,:G3,:A3,:A3,:G3,:D4,:D4,:D4,:D4,:Bf3,:C4,:C4,:D4,:D4,:D4,:r,:r,:Bf3,:Bf3,:D4,:Bf3,:A3,:A3,:C4,:C4,:r,:Bf3,:A3,:C4,:C4,:Bf3,:A3,:D4,:D4,:r,:G3,:A3,:Bf3,:C4,:D4,:D4,:D4,:D4,:D4,:B3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:D4,:D4,:D4,:D4,:Bf3,:C4,:C4,:D4,:D4,:D4,:r,:r,:Bf3,:Bf3,:D4,:Bf3,:A3,:A3,:C4,:C4,:r,:Bf3,:A3,:C4,:C4,:Bf3,:A3,:D4,:D4,:r,:G3,:A3,:Bf3,:C4,:D4,:D4,:D4,:D4,:D4,:B3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:A3,:Bf3,:G3,:D4,:Bf3,:C4,:D4,:Bf3,:D4,:C4,:Bf3,:A3,:D4,:Cs4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:D3,:Bf3,:A3,:G3,:Fs3,:G3,:G3,:D3,:r,:r,:r,:r,:r,:r,:r,:D4,:Bf3,:A3,:Bf3,:C4,:D4,:C4,:D4,:Bf3,:C4,:Bf3,:A3,:A3,:D4,:D4,:Cs4,:r,:r,:r,:D4,:D4,:D4,:D4,:Bf3,:C4,:C4,:D4,:D4,:D4,:r,:r,:Bf3,:Bf3,:D4,:Bf3,:A3,:A3,:C4,:C4,:r,:Bf3,:A3,:C4,:C4,:Bf3,:A3,:D4,:D4,:r,:G3,:A3,:Bf3,:C4,:D4,:D4,:D4,:D4,:D4,:B3,:r]
b5[0]=[4.0,2.0,1.0,2.0,1.0,4.0,2.0,6.0,2.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,1.0,2.0,1.0,1.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,1.0,1.5,0.5,0.5,0.5,2.0,2.0,1.0,1.0,2.0,3.0,1.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,4.0,2.0,6.0,2.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,1.0,2.0,1.0,1.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,1.0,1.5,0.5,0.5,0.5,2.0,2.0,1.0,1.0,2.0,8.0,2.0,3.0,1.0,2.0,2.0,2.0,2.0,3.0,1.0,4.0,2.0,3.0,1.0,4.0,2.0,1.0,2.0,1.0,3.0,0.5,0.5,1.0,1.0,1.0,1.0,2.0,2.0,1.5,0.5,1.0,1.0,2.0,1.0,1.0,1.0,1.0,0.5,0.5,2.0,1.0,1.0,2.0,1.0,4.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,1.0,1.0,2.0,3.0,1.0,1.0,1.0,1.0,1.0,2.0,1.5,0.5,1.0,1.0,1.5,0.5,1.0,2.0,1.0,4.0,1.0,1.0,1.0,1.0,1.0,0.5,0.5,2.0,2.0,4.0,4.0,2.0,1.0,2.0,1.0,4.0,2.0,6.0,2.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,1.0,2.0,1.0,1.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,1.0,1.5,0.5,0.5,0.5,2.0,2.0,1.0,1.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,4.0,2.0,1.0,2.0,1.0,4.0,2.0,6.0,2.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,1.0,2.0,1.0,1.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,1.0,1.5,0.5,0.5,0.5,2.0,2.0,1.0,1.0,2.0,8.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,2.0,1.0,1.0,2.0,1.0,1.0,1.5,0.5,2.0,3.0,1.0,1.0,2.0,1.0,4.0,2.0,2.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,2.0,2.0,2.0,2.0,2.0,2.0,1.0,1.0,2.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,1.0,2.0,2.0,1.0,2.0,2.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,4.0,2.0,6.0,2.0,4.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,1.0,2.0,1.0,1.0,1.0,2.0,0.5,0.5,1.0,1.0,2.0,1.0,1.5,0.5,0.5,0.5,2.0,2.0,1.0,1.0,2.0,8.0,8.0]
c5=[tempo]
in_thread do
  for i in st..a5.length-1
    in_thread do
      bosc 4,a5[i],b5[i],s[5],r[5],synth[5],c5[i],amp[5]*qt,:cont4
    end
    sync :cont4
  end
end

a6=[]
b6=[]
a6[0]=[:G3,:A3,:A3,:A3,:G3,:C4,:Bf3,:A3,:A3,:Bf3,:G3,:A3,:r,:D3,:D3,:D3,:D4,:C4,:C4,:G3,:C4,:D4,:Bf3,:C4,:C4,:Bf3,:Bf3,:Ef4,:C4,:D4,:C4,:Bf3,:C4,:D4,:D3,:D3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G3,:A3,:A3,:A3,:G3,:C4,:Bf3,:A3,:A3,:Bf3,:G3,:A3,:r,:D3,:D3,:D3,:D4,:C4,:C4,:G3,:C4,:D4,:Bf3,:C4,:C4,:Bf3,:Bf3,:Ef4,:C4,:D4,:C4,:Bf3,:C4,:D4,:D3,:D3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G3,:A3,:A3,:A3,:G3,:C4,:Bf3,:A3,:A3,:Bf3,:G3,:A3,:r,:D3,:D3,:D3,:D4,:C4,:C4,:G3,:C4,:D4,:Bf3,:C4,:C4,:Bf3,:Bf3,:Ef4,:C4,:D4,:C4,:Bf3,:C4,:D4,:D3,:D3,:r,:Bf3,:Bf3,:A3,:G3,:A3,:G3,:A3,:Bf3,:C4,:D4,:Bf3,:C4,:A3,:Bf3,:G3,:A3,:F3,:Bf3,:A3,:D4,:r,:D4,:D4,:D4,:C4,:A3,:C4,:G3,:r,:D4,:D4,:D4,:C4,:A3,:Bf3,:G3,:r,:A3,:F3,:G3,:C4,:C4,:C4,:Bf3,:Bf3,:A3,:G3,:F3,:F3,:G3,:A3,:A3,:A3,:G3,:A3,:Bf3,:A3,:D4,:C4,:Bf3,:C4,:D4,:Bf3,:Cs4,:D4,:Cs4,:D4,:G3,:A3,:A3,:A3,:G3,:C4,:Bf3,:A3,:A3,:Bf3,:G3,:A3,:r,:D3,:D3,:D3,:D4,:C4,:C4,:G3,:C4,:D4,:Bf3,:C4,:C4,:Bf3,:Bf3,:Ef4,:C4,:D4,:C4,:Bf3,:C4,:D4,:D3,:D3,:r,:r,:r,:r,:r,:G3,:D4,:E4,:F4,:C4,:r,:G3,:Bf3,:A3,:G3,:A3,:A3,:Bf3,:G3,:G3,:A3,:r,:r,:r,:r,:r,:E4,:F4,:C4,:r,:G3,:Bf3,:A3,:G3,:A3,:A3,:Bf3,:G3,:G3,:A3,:D4,:D4,:C4,:D4,:C4,:Bf3,:C4,:Bf3,:A3,:G3,:F3,:G3,:A3,:Bf3,:A3,:Bf3,:r,:r,:r,:r,:r,:r,:r,:A3,:Bf3,:A3,:Bf3,:C4,:D4,:C4,:D4,:Bf3,:C4,:Bf3,:A3,:r,:r,:D4,:Bf3,:Bf3,:G3,:Ef4,:D4,:C4,:B3,:C4,:C4,:G3,:G3,:Ef4,:D4,:D4,:D4,:r,:r,:r,:Cs4,:D4,:C4,:D4,:D4,:C4,:Bf3,:C4,:D4,:r,:G3,:A3,:A3,:A3,:G3,:C4,:Bf3,:A3,:A3,:Bf3,:G3,:A3,:r,:D3,:D3,:D3,:D4,:C4,:C4,:G3,:C4,:D4,:Bf3,:C4,:C4,:Bf3,:Bf3,:Ef4,:C4,:D4,:C4,:Bf3,:C4,:D4,:D3,:D3,:r]
b6[0]=[4.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,1.0,1.0,3.0,1.0,1.0,1.0,2.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,1.0,1.0,3.0,1.0,1.0,1.0,2.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,1.0,1.0,3.0,1.0,1.0,1.0,2.0,2.0,8.0,2.0,3.0,1.0,4.0,2.0,2.0,0.5,0.5,1.0,1.0,1.5,0.5,1.5,0.5,1.5,0.5,1.0,1.0,1.0,2.0,4.0,1.0,1.0,1.0,1.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,1.0,2.0,2.0,1.5,0.5,2.0,1.0,1.0,1.0,1.0,4.0,1.0,1.0,2.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,1.0,2.0,1.0,4.0,4.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,1.0,1.0,3.0,1.0,1.0,1.0,2.0,2.0,8.0,4.0,8.0,8.0,8.0,1.0,1.0,1.5,0.5,2.0,2.0,2.0,1.0,2.0,0.5,0.5,2.0,1.0,2.0,1.0,4.0,4.0,4.0,8.0,8.0,2.0,1.0,1.0,2.0,2.0,2.0,1.0,2.0,0.5,0.5,2.0,1.0,2.0,1.0,2.0,1.0,1.0,3.0,1.0,1.0,0.5,0.5,4.0,4.0,2.0,2.0,1.5,0.5,1.0,2.0,1.0,4.0,4.0,8.0,8.0,8.0,8.0,2.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,2.0,4.0,2.0,2.0,2.0,1.0,1.0,6.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,2.0,8.0,4.0,1.0,1.0,2.0,1.5,0.5,1.0,1.0,2.0,2.0,8.0,2.0,2.0,2.0,1.0,2.0,1.0,1.5,0.5,2.0,2.0,6.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,1.0,1.0,3.0,1.0,1.0,1.0,2.0,2.0,8.0,8.0]
c6=[tempo]
in_thread do
  for i in st..a6.length-1
    in_thread do
      bosc 5,a6[i],b6[i],s[5],r[5],synth[5],c6[i],amp[5]*qt,:cont5
    end
    sync :cont5
  end
end

a7=[]
b7=[]
a7[0]=[:G2,:D3,:D3,:D3,:G3,:F3,:F2,:Bf2,:A2,:G2,:G2,:D3,:r,:Bf2,:Bf2,:G2,:Bf2,:F2,:F2,:C3,:C3,:G2,:Bf2,:F2,:F2,:Bf2,:Bf2,:C3,:G2,:D3,:G2,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G2,:D3,:D3,:D3,:G3,:F3,:F2,:Bf2,:A2,:G2,:G2,:D3,:r,:Bf2,:Bf2,:G2,:Bf2,:F2,:F2,:C3,:C3,:G2,:Bf2,:F2,:F2,:Bf2,:Bf2,:C3,:G2,:D3,:G2,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G2,:D3,:D3,:D3,:G3,:F3,:F2,:Bf2,:A2,:G2,:G2,:D3,:r,:Bf2,:Bf2,:G2,:Bf2,:F2,:F2,:C3,:C3,:G2,:Bf2,:F2,:F2,:Bf2,:Bf2,:C3,:G2,:D3,:G2,:r,:G2,:G2,:D3,:E3,:F3,:C3,:G3,:F3,:D3,:Ef3,:C3,:D3,:Bf2,:C3,:A2,:Bf2,:C3,:D3,:G2,:G3,:G3,:G3,:F3,:D3,:F3,:F2,:r,:C3,:C3,:C3,:Bf2,:G2,:G2,:A2,:D3,:G2,:A2,:D3,:D3,:D3,:C3,:A2,:Bf2,:G2,:r,:A2,:D3,:C3,:Bf2,:F2,:F2,:C3,:G2,:D3,:C3,:Bf2,:A2,:G2,:A2,:Bf2,:G2,:A2,:G2,:A2,:D3,:G2,:D3,:D3,:D3,:G3,:F3,:F2,:Bf2,:A2,:G2,:G2,:D3,:r,:Bf2,:Bf2,:G2,:Bf2,:F2,:F2,:C3,:C3,:G2,:Bf2,:F2,:F2,:Bf2,:Bf2,:C3,:G2,:D3,:G2,:r,:r,:r,:r,:r,:G2,:D3,:E3,:F3,:D3,:r,:G2,:D3,:E3,:F3,:D3,:G3,:C3,:Ef3,:D3,:r,:r,:r,:r,:A2,:D3,:E3,:F3,:D3,:r,:G2,:D3,:E3,:F3,:D3,:G3,:C3,:Ef3,:D3,:G3,:G3,:A3,:Bf3,:A3,:G3,:F3,:E3,:D3,:C3,:Bf2,:A2,:G2,:A2,:Bf2,:F2,:G2,:Bf2,:F2,:Bf2,:r,:r,:r,:r,:r,:r,:D3,:G2,:C3,:D3,:r,:r,:D3,:Ef3,:D3,:C3,:B2,:C3,:C3,:G2,:C3,:C3,:D3,:D3,:D3,:r,:r,:r,:A2,:D3,:C3,:D3,:E3,:F3,:Ef3,:F3,:D3,:G3,:Ef3,:D3,:G2,:D3,:D3,:D3,:G3,:F3,:F2,:Bf2,:A2,:G2,:G2,:D3,:r,:Bf2,:Bf2,:G2,:Bf2,:F2,:F2,:C3,:C3,:G2,:Bf2,:F2,:F2,:Bf2,:Bf2,:C3,:G2,:D3,:G2,:r]
b7[0]=[4.0,2.0,1.0,2.0,1.0,4.0,2.0,3.0,1.0,2.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,2.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,4.0,2.0,3.0,1.0,2.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,2.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,4.0,2.0,3.0,1.0,2.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,2.0,2.0,8.0,8.0,2.0,3.0,1.0,4.0,2.0,2.0,1.0,1.0,1.5,0.5,1.5,0.5,1.5,0.5,1.5,0.5,1.5,0.5,2.0,1.0,1.0,1.0,1.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,2.0,2.0,2.0,2.0,1.0,1.0,1.5,0.5,2.0,4.0,2.0,2.0,2.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,2.0,4.0,4.0,2.0,1.0,2.0,1.0,4.0,2.0,3.0,1.0,2.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,2.0,2.0,8.0,8.0,4.0,8.0,8.0,8.0,2.0,2.0,1.5,0.5,2.0,2.0,1.0,1.0,1.5,0.5,2.0,1.0,2.0,1.0,4.0,4.0,4.0,8.0,8.0,2.0,2.0,1.5,0.5,2.0,2.0,1.0,1.0,1.5,0.5,2.0,1.0,2.0,1.0,2.0,3.0,1.0,1.0,1.0,1.0,0.5,0.5,1.0,0.5,0.5,1.0,0.5,0.5,1.0,1.0,2.0,2.0,2.0,2.0,4.0,4.0,4.0,8.0,8.0,8.0,8.0,2.0,2.0,4.0,2.0,2.0,4.0,2.0,2.0,6.0,2.0,2.0,2.0,1.0,1.0,2.0,6.0,2.0,1.0,1.0,2.0,8.0,4.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,4.0,2.0,8.0,4.0,2.0,1.0,2.0,1.0,4.0,2.0,3.0,1.0,2.0,2.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,3.0,2.0,1.0,2.0,2.0,8.0,8.0,8.0]
c7=[tempo]
in_thread do
  for i in st..a7.length-1
    in_thread do
      bosc 6,a7[i],b7[i],s[6],r[6],synth[6],c7[i],amp[6]*qt,:cont6
    end
    sync :cont6
  end
end

a8=[]
b8=[]
a8[0]=[:G4,:Fs4,:Fs4,:Fs4,:G4,:A4,:A4,:A4,:G4,:F4,:E4,:D4,:D4,:G4,:D4,:G4,:G4,:Fs4,:r,:D4,:F4,:Bf3,:F4,:F4,:C4,:E4,:G4,:G4,:F4,:F4,:F4,:F4,:F4,:F4,:C4,:r,:D4,:D4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G4,:Fs4,:Fs4,:Fs4,:G4,:A4,:A4,:A4,:G4,:F4,:E4,:D4,:D4,:G4,:D4,:G4,:G4,:Fs4,:r,:D4,:F4,:Bf3,:F4,:F4,:C4,:E4,:G4,:G4,:F4,:F4,:F4,:F4,:F4,:F4,:C4,:r,:D4,:D4,:r,:Fs4,:Fs4,:G4,:A4,:A4,:A4,:F4,:F4,:G4,:F4,:F4,:E4,:F4,:D4,:E4,:F4,:D4,:C4,:F4,:F4,:F4,:E4,:Fs4,:G4,:G4,:G4,:A4,:A4,:G4,:F4,:G4,:F4,:Ef4,:Ef4,:D4,:F4,:Ef4,:D4,:D4,:C4,:D4,:F4,:F4,:F4,:F4,:F4,:G4,:G4,:r,:A4,:G4,:E4,:G4,:E4,:D4,:E4,:G4,:Fs4,:G4,:A4,:A4,:A4,:G4,:G4,:Fs4,:G4,:A4,:A4,:G4,:G4,:Fs4,:E4,:Fs4,:Fs4,:G4,:G4,:Fs4,:Fs4,:Fs4,:G4,:A4,:A4,:A4,:G4,:F4,:E4,:D4,:D4,:G4,:D4,:G4,:G4,:Fs4,:r,:D4,:F4,:Bf3,:F4,:F4,:C4,:E4,:G4,:G4,:F4,:F4,:F4,:F4,:F4,:F4,:C4,:r,:D4,:D4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G4,:Fs4,:Fs4,:Fs4,:G4,:A4,:A4,:A4,:G4,:F4,:E4,:D4,:D4,:G4,:D4,:G4,:G4,:Fs4,:r,:D4,:F4,:Bf3,:F4,:F4,:C4,:E4,:G4,:G4,:F4,:F4,:F4,:F4,:F4,:F4,:C4,:r,:D4,:D4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:G3,:D4,:E4,:F4,:D4,:G3,:D4,:E4,:F4,:D4,:A4,:G4,:F4,:F4,:G4,:E4,:E4,:r,:r,:r,:r,:r,:r,:r,:r,:r,:D4,:Ef4,:D4,:D4,:E4,:F4,:F4,:D4,:D4,:D4,:r,:r,:r,:r,:r,:r,:r,:r,:F4,:D4,:G4,:F4,:D4,:F4,:E4,:F4,:G4,:A4,:G4,:A4,:F4,:G4,:F4,:E4,:r,:r,:r,:G4,:Fs4,:Fs4,:Fs4,:G4,:A4,:A4,:A4,:G4,:F4,:E4,:D4,:D4,:G4,:D4,:G4,:G4,:Fs4,:r,:D4,:F4,:Bf3,:F4,:F4,:C4,:E4,:G4,:G4,:F4,:F4,:F4,:F4,:F4,:F4,:C4,:r,:D4,:D4,:r]
b8[0]=[4.0,2.0,1.0,2.0,1.0,2.0,2.0,1.5,0.5,0.5,0.5,1.0,2.0,1.0,1.0,1.0,1.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,2.0,2.0,1.5,0.5,0.5,0.5,1.0,2.0,1.0,1.0,1.0,1.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,8.0,8.0,2.0,3.0,1.0,2.0,3.0,1.0,2.0,3.0,2.0,2.0,1.0,4.0,2.0,2.0,4.0,2.0,2.0,3.0,2.0,1.0,1.0,1.0,2.0,2.0,3.0,1.0,2.0,1.0,1.0,1.0,1.0,1.5,0.5,1.0,1.0,2.0,4.0,2.0,2.0,2.0,4.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,3.0,1.0,1.0,1.0,1.5,0.5,1.0,2.0,1.0,1.0,1.0,4.0,2.0,1.0,2.0,0.5,0.5,1.0,1.0,4.0,4.0,2.0,1.0,2.0,1.0,2.0,2.0,1.5,0.5,0.5,0.5,1.0,2.0,1.0,1.0,1.0,1.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,4.0,4.0,2.0,1.0,2.0,1.0,2.0,2.0,1.5,0.5,0.5,0.5,1.0,2.0,1.0,1.0,1.0,1.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,8.0,8.0,4.0,8.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,1.0,1.5,0.5,2.0,3.0,1.0,1.5,0.5,2.0,4.0,1.0,2.0,2.0,2.0,1.0,2.0,2.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,2.0,2.0,2.0,3.0,2.0,1.0,2.0,2.0,3.0,1.0,8.0,4.0,8.0,8.0,8.0,8.0,4.0,2.0,1.0,1.0,2.0,2.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,2.0,2.0,8.0,8.0,4.0,2.0,1.0,2.0,1.0,2.0,2.0,1.5,0.5,0.5,0.5,1.0,2.0,1.0,1.0,1.0,1.0,4.0,2.0,3.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,1.0,1.0,2.0,1.0,2.0,1.0,2.0,2.0,2.0,8.0,8.0,8.0]
c8=[tempo]
in_thread do
  for i in st..a8.length-1
    in_thread do
      bosc 7,a8[i],b8[i],s[7],r[7],synth[7],c8[i],amp[7]*qt,:cont7
    end
    sync :cont7
  end
end

a9=[]
b9=[]
a9[0]=[:D3,:r,:Fs3,:A3,:D4,:A3,:r,:C4,:r,:F3,:F3,:r,:G3,:r,:G3,:D3,:r,:r,:F3,:r,:F3,:G3,:F3,:F3,:F3,:G3,:r,:G3,:Bf3,:F3,:r,:A3,:r,:A3,:F3,:F3,:Bf3,:A3,:G3,:A3,:Bf3,:G3,:A3,:G3,:A3,:r,:G3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:D3,:r,:Fs3,:A3,:D4,:A3,:r,:C4,:r,:F3,:F3,:r,:G3,:r,:G3,:D3,:r,:r,:F3,:r,:F3,:G3,:F3,:F3,:F3,:G3,:r,:G3,:Bf3,:F3,:r,:A3,:r,:A3,:F3,:F3,:Bf3,:A3,:G3,:A3,:Bf3,:G3,:A3,:G3,:A3,:r,:G3,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:r,:D3,:r,:Fs3,:A3,:D4,:A3,:r,:C4,:r,:F3,:F3,:r,:G3,:r,:G3,:D3,:r,:r,:F3,:r,:F3,:G3,:F3,:F3,:F3,:G3,:r,:G3,:Bf3,:F3,:r,:A3,:r,:A3,:F3,:F3,:Bf3,:A3,:G3,:A3,:Bf3,:G3,:A3,:G3,:A3,:r,:G3,:r,:r,:G3,:r,:G3,:D4,:r,:r,:C4,:C4,:C4,:D4,:A3,:Bf3,:G3,:A3,:F3,:G3,:E3,:F3,:D3,:G3,:r,:Fs3,:G3,:Bf3,:Bf3,:Bf3,:A3,:A3,:r,:F3,:F3,:F3,:E3,:r,:C3,:F3,:G3,:r,:D4,:D4,:D4,:C4,:Bf3,:A3,:G3,:F3,:E3,:D3,:E3,:r,:D3,:D4,:D4,:D4,:C4,:C4,:A3,:Bf3,:D4,:C4,:C4,:C4,:C3,:D3,:E3,:E3,:D3,:E3,:F3,:E3,:F3,:G3,:E3,:r,:D3,:r,:D3,:r,:Fs3,:A3,:D4,:A3,:r,:C4,:r,:F3,:F3,:r,:G3,:r,:G3,:D3,:r,:r,:F3,:r,:F3,:G3,:F3,:F3,:F3,:G3,:r,:G3,:Bf3,:F3,:r,:A3,:r,:A3,:F3,:F3,:Bf3,:A3,:G3,:A3,:Bf3,:G3,:A3,:G3,:A3,:r,:G3,:r,:r,:r,:r,:r,:r,:Bf3,:A3,:r,:A3,:A3,:D4,:E4,:F4,:C4,:D4,:r,:C4,:Bf3,:C4,:D4,:D4,:r,:r,:r,:r,:r,:G3,:A3,:Bf3,:C4,:A3,:r,:A3,:D4,:E4,:F4,:C4,:D4,:r,:C4,:Bf3,:C4,:D4,:A3,:r,:Bf3,:Bf3,:F3,:Bf3,:A3,:r,:G3,:G3,:F3,:E3,:D3,:F3,:Ef3,:D3,:C3,:D3,:C3,:D3,:r,:r,:r,:r,:r,:r,:r,:r,:D3,:G3,:F3,:G3,:A3,:Bf3,:A3,:Bf3,:G3,:A3,:G3,:Fs3,:r,:r,:A3,:G3,:r,:G3,:r,:r,:G3,:Ef4,:D4,:G3,:Ef4,:r,:D4,:C4,:Bf3,:A3,:A3,:A3,:r,:r,:A3,:r,:Bf3,:G3,:r,:A3,:r,:r,:r,:D3,:Fs3,:A3,:D4,:A3,:r,:C4,:r,:F3,:F3,:r,:G3,:r,:G3,:D3,:r,:r,:F3,:r,:F3,:G3,:F3,:F3,:F3,:G3,:r,:G3,:Bf3,:F3,:r,:A3,:r,:A3,:F3,:F3,:Bf3,:A3,:G3,:A3,:Bf3,:G3,:A3,:G3,:A3,:r,:G3,:r]
b9[0]=[2.0,2.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,1.0,0.5,0.5,1.5,0.5,1.0,1.0,2.0,2.0,2.0,2.0,2.0,2.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,2.0,2.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,1.0,0.5,0.5,1.5,0.5,1.0,1.0,2.0,2.0,2.0,2.0,2.0,2.0,4.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,2.0,2.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,1.0,0.5,0.5,1.5,0.5,1.0,1.0,2.0,2.0,2.0,2.0,2.0,2.0,4.0,2.0,1.0,1.0,2.0,2.0,2.0,2.0,2.0,1.0,1.0,1.5,0.5,1.5,0.5,1.5,0.5,1.5,0.5,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,2.0,2.0,1.0,1.0,1.0,1.0,0.5,0.5,0.5,0.5,1.0,0.5,0.5,2.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,1.5,0.5,0.5,0.5,1.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,1.0,0.5,0.5,1.5,0.5,1.0,1.0,2.0,2.0,2.0,2.0,2.0,2.0,8.0,8.0,8.0,8.0,2.0,2.0,2.0,2.0,1.0,1.0,1.5,0.5,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,2.0,4.0,8.0,4.0,2.0,1.0,1.0,1.5,0.5,2.0,2.0,2.0,2.0,1.5,0.5,2.0,2.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,2.0,1.0,1.0,1.0,0.5,0.5,2.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,4.0,8.0,8.0,8.0,8.0,2.0,1.0,1.0,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,1.0,1.0,2.0,4.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,4.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0,4.0,2.0,2.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,2.0,2.0,1.0,1.0,2.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,2.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,1.0,0.5,0.5,1.5,0.5,1.0,1.0,2.0,2.0,2.0,2.0,8.0,8.0]
c9=[tempo]
in_thread do
  for i in st..a9.length-1
    in_thread do
      bosc 20,a9[i],b9[i],s[8],r[8],synth[8],c9[i],amp[8]*qt,:cont20
    end
    sync :cont20
  end
end
