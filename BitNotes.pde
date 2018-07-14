/* bitCrushExample<br/>
 * This is an example of using a BitCrush UGen to modify the sound of an Oscil.
 * <p>
 * For more information about Minim and additional features, 
 * visit http://code.compartmental.net/minim/
 */

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*; // for BandPass

Minim minim;
AudioOutput out;
Summer sum;

// this CrushInstrument will play a sine wave bit crushed
// to a certain bit resolution. this results in the audio sounding
// "crunchier".
class CrushInstrument implements Instrument
{
  Oscil sineOsc;
  BitCrush bitCrush;
  
  CrushInstrument(float frequency, float amplitude, float bitRes)
  {
    sineOsc = new Oscil(frequency, amplitude, Waves.SINE);
    
    // BitCrush takes the bit resolution for an argument
    bitCrush = new BitCrush(bitRes, out.sampleRate());
    
    sineOsc.patch(bitCrush);
  }
  
  // every instrument must have a noteOn( float ) method
  void noteOn(float dur)
  {
    bitCrush.patch(out);
  }
  
  // every instrument must have a noteOff() method
  void noteOff()
  {
    bitCrush.unpatch(out);
  }
}

// this CrushingInstrument will play a sine wave and then change the bit resulution of the BitCrush
// over time, based on a starting and ending resolution passed in.
class CrushingInstrument implements Instrument
{
  Oscil sineOsc;
  BitCrush bitCrush;
  Line crushLine;
  
  CrushingInstrument(float frequency, float amplitude, float hiBitRes, float loBitRes)
  {
    sineOsc = new Oscil(frequency, amplitude, Waves.TRIANGLE);
    bitCrush = new BitCrush(hiBitRes, out.sampleRate());
    crushLine = new Line(9.0, hiBitRes, loBitRes);
    
    // our Line will control the resolution of the bit crush
    crushLine.patch(bitCrush.bitRes);
    // patch the osc through the bit crush
    sineOsc.patch(bitCrush);
  }
  
  // called by the note manager when this instrument should play
  void noteOn(float dur)
  {
    // patch the bit crush to the output and active our Line when we want to have the note play
    crushLine.activate();
    bitCrush.patch(out);
  }
  
  // called by the note manager when this instrument should stop playing
  void noteOff()
  {
    // unpatch from the output to stop making sound
    bitCrush.unpatch(out);
  }
}

void initSound(){
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO );
}

void hitSound(){
  out.playNote(0.0, 0.1, new CrushInstrument( intToFrequency((int)random(65,69)), 0.5, 16.0) );
}

void playRandomSong(float length){
  float totalLength = 0;
  int shift = 0;
  int start = (int)random(70, 75);
  while(length > totalLength){
    float notelength = random(100) > 70 ? (random(100) > 70 ? 0.8 : 0.4) : 0.2;
    float pause = random(100) > 80 ? (random(100) > 50 ? 0.4 : 0.2) : 0;
    shift += (int)random(-3,3) * 2;
    out.playNote(totalLength+pause, notelength, new CrushInstrument( intToFrequency(start+shift), random(0.2, 0.5), random(10, 100)));
    totalLength += notelength + pause;
  }
}

void playWinningSong(float length){
  float totalLength = 0;
  int shift = 2;
  int start = (int)random(60, 65);
  while(length > totalLength){
    float notelength = random(100) > 70 ? (random(100) > 70 ? 0.8 : 0.4) : 0.2;
    start+=shift;
    out.playNote(totalLength, notelength, new CrushInstrument( intToFrequency(start), random(0.2, 0.5), random(10, 100)));
    totalLength += notelength;
  }
}

void scoreSound(){
  out.playNote(0.0, 0.1, new CrushInstrument( intToFrequency(40), 0.5, 3.0) );
  out.playNote(0.2, 0.4, new CrushInstrument( intToFrequency(70), 0.5, 16.0) );
}

float intToFrequency(int i){
  return pow(2,((i-49)/12.0))*440.0;
}